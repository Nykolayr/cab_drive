const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

const kFcmTokensCollection = "fcm_tokens";
const kPushNotificationsCollection = "ff_push_notifications";
const kUserPushNotificationsCollection = "ff_user_push_notifications";
const kSchedulerIntervalMinutes = 1;
const firestore = admin.firestore();

const kPushNotificationRuntimeOpts = {
  timeoutSeconds: 540,
  memory: "2GB",
};

exports.addFcmToken = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    return "Failed: Unauthenticated calls are not allowed.";
  }
  const userDocPath = data.userDocPath;
  const fcmToken = data.fcmToken;
  const deviceType = data.deviceType;
  if (
    typeof userDocPath === "undefined" ||
    typeof fcmToken === "undefined" ||
    typeof deviceType === "undefined" ||
    userDocPath.split("/").length <= 1 ||
    fcmToken.length === 0 ||
    deviceType.length === 0
  ) {
    return "Invalid arguments encoutered when adding FCM token.";
  }
  if (context.auth.uid != userDocPath.split("/")[1]) {
    return "Failed: Authenticated user doesn't match user provided.";
  }
  const existingTokens = await firestore
    .collectionGroup(kFcmTokensCollection)
    .where("fcm_token", "==", fcmToken)
    .get();
  var userAlreadyHasToken = false;
  for (var doc of existingTokens.docs) {
    const user = doc.ref.parent.parent;
    if (user.path != userDocPath) {
      // Should never have the same FCM token associated with multiple users.
      await doc.ref.delete();
    } else {
      userAlreadyHasToken = true;
    }
  }
  if (userAlreadyHasToken) {
    return "FCM token already exists for this user. Ignoring...";
  }
  await getUserFcmTokensCollection(userDocPath).doc().set({
    fcm_token: fcmToken,
    device_type: deviceType,
    created_at: admin.firestore.FieldValue.serverTimestamp(),
  });
  return "Successfully added FCM token!";
});

exports.sendPushNotificationsTrigger = functions
  .runWith(kPushNotificationRuntimeOpts)
  .firestore.document(`${kPushNotificationsCollection}/{id}`)
  .onCreate(async (snapshot, _) => {
    try {
      // Ignore scheduled push notifications on create
      const scheduledTime = snapshot.data().scheduled_time || "";
      if (scheduledTime) {
        return;
      }

      await sendPushNotifications(snapshot);
    } catch (e) {
      console.log(`Error: ${e}`);
      await snapshot.ref.update({ status: "failed", error: `${e}` });
    }
  });

exports.sendUserPushNotificationsTrigger = functions
  .runWith(kPushNotificationRuntimeOpts)
  .firestore.document(`${kUserPushNotificationsCollection}/{id}`)
  .onCreate(async (snapshot, _) => {
    try {
      // Ignore scheduled push notifications on create
      const scheduledTime = snapshot.data().scheduled_time || "";
      if (scheduledTime) {
        return;
      }

      // Don't let user-triggered notifications to be sent to all users.
      const userRefsStr = snapshot.data().user_refs || "";
      if (userRefsStr) {
        await sendPushNotifications(snapshot);
      }
    } catch (e) {
      console.log(`Error: ${e}`);
      await snapshot.ref.update({ status: "failed", error: `${e}` });
    }
  });

exports.sendScheduledPushNotifications = functions.pubsub
  .schedule(`every ${kSchedulerIntervalMinutes} minutes synchronized`)
  .onRun(async (_) => {
    const minutesToMilliseconds = (minutes) => minutes * 60 * 1000;
    function currentTimeDownToNearestMinute() {
      // Add a second to the current time to avoid minute boundary issues.
      const currentTime = new Date(new Date().getTime() + 1000);
      // Remove seconds and milliseconds to get the time down to the minute.
      currentTime.setSeconds(0, 0);
      return currentTime;
    }

    // Determine the cutoff times for this round of push notifications.
    const intervalMs = minutesToMilliseconds(kSchedulerIntervalMinutes);
    const upperCutoffTime = currentTimeDownToNearestMinute();
    const lowerCutoffTime = new Date(upperCutoffTime.getTime() - intervalMs);
    // Send push notifications that we've scheduled.
    const scheduledNotifications = await firestore
      .collection(kPushNotificationsCollection)
      .where("scheduled_time", ">", lowerCutoffTime)
      .where("scheduled_time", "<=", upperCutoffTime)
      .get();
    for (var snapshot of scheduledNotifications.docs) {
      try {
        await sendPushNotifications(snapshot);
      } catch (e) {
        console.log(`Error: ${e}`);
        await snapshot.ref.update({ status: "failed", error: `${e}` });
      }
    }
    // Send push notifications that users have scheduled.
    const scheduledUserNotifications = await firestore
      .collection(kUserPushNotificationsCollection)
      .where("scheduled_time", ">", lowerCutoffTime)
      .where("scheduled_time", "<=", upperCutoffTime)
      .get();
    for (var snapshot of scheduledUserNotifications.docs) {
      try {
        // Don't let user-triggered notifications to be sent to all users.
        const userRefsStr = snapshot.data().user_refs || "";
        if (userRefsStr) {
          await sendPushNotifications(snapshot);
        }
      } catch (e) {
        console.log(`Error: ${e}`);
        await snapshot.ref.update({ status: "failed", error: `${e}` });
      }
    }
  });

async function sendPushNotifications(snapshot) {
  console.log(`[sendPushNotifications] Starting for ${snapshot.ref.path}`);
  const notificationData = snapshot.data();
  const title = notificationData.notification_title || "";
  const body = notificationData.notification_text || "";
  const imageUrl = notificationData.notification_image_url || "";
  const sound = notificationData.notification_sound || "";
  const parameterData = notificationData.parameter_data || "";
  const targetAudience = notificationData.target_audience || "";
  const initialPageName = notificationData.initial_page_name || "";
  const userRefsStr = notificationData.user_refs || "";
  const batchIndex = notificationData.batch_index || 0;
  const numBatches = notificationData.num_batches || 0;
  const status = notificationData.status || "";

  console.log(`[sendPushNotifications] title: ${title}, body: ${body}`);
  console.log(`[sendPushNotifications] userRefsStr: ${userRefsStr}`);

  if (status !== "" && status !== "started") {
    console.log(`Already processed ${snapshot.ref.path}. Skipping...`);
    return;
  }

  if (title === "" || body === "") {
    console.log(`[sendPushNotifications] ERROR: Empty title or body`);
    await snapshot.ref.update({ status: "failed", error: "Empty title or body" });
    return;
  }

  const userRefs = userRefsStr === "" ? [] : userRefsStr.trim().split(",");
  console.log(`[sendPushNotifications] userRefs count: ${userRefs.length}`);

  // Map token -> document reference (for cleanup)
  var tokenToDocRef = new Map();
  var tokens = new Set();
  if (userRefsStr) {
    for (var userRef of userRefs) {
      console.log(`[sendPushNotifications] Fetching tokens for user: ${userRef}`);
      const userTokens = await firestore
        .doc(userRef)
        .collection(kFcmTokensCollection)
        .get();
      console.log(`[sendPushNotifications] Found ${userTokens.docs.length} token docs for ${userRef}`);
      userTokens.docs.forEach((tokenDoc) => {
        const fcmToken = tokenDoc.data().fcm_token;
        if (fcmToken) {
          console.log(`[sendPushNotifications] Adding token: ${fcmToken.substring(0, 20)}...`);
          tokens.add(fcmToken);
          tokenToDocRef.set(fcmToken, tokenDoc.ref);
        }
      });
    }
  } else {
    var userTokensQuery = firestore.collectionGroup(kFcmTokensCollection);
    // Handle batched push notifications by splitting tokens up by document
    // id.
    if (numBatches > 0) {
      userTokensQuery = userTokensQuery
        .orderBy(admin.firestore.FieldPath.documentId())
        .startAt(getDocIdBound(batchIndex, numBatches))
        .endBefore(getDocIdBound(batchIndex + 1, numBatches));
    }
    const userTokens = await userTokensQuery.get();
    userTokens.docs.forEach((tokenDoc) => {
      const data = tokenDoc.data();
      const audienceMatches =
        targetAudience === "All" || data.device_type === targetAudience;
      if (audienceMatches && data.fcm_token) {
        tokens.add(data.fcm_token);
        tokenToDocRef.set(data.fcm_token, tokenDoc.ref);
      }
    });
  }

  const tokensArr = Array.from(tokens);
  console.log(`[sendPushNotifications] Total unique tokens: ${tokensArr.length}`);

  if (tokensArr.length === 0) {
    console.log(`[sendPushNotifications] ERROR: No FCM tokens found for users`);
    await snapshot.ref.update({ status: "failed", error: "No FCM tokens found", num_sent: 0 });
    return;
  }

  var messageBatches = [];
  for (let i = 0; i < tokensArr.length; i += 500) {
    const tokensBatch = tokensArr.slice(i, Math.min(i + 500, tokensArr.length));
    const messages = {
      notification: {
        title,
        body,
        ...(imageUrl && { imageUrl: imageUrl }),
      },
      data: {
        initialPageName,
        parameterData,
      },
      android: {
        notification: {
          ...(sound && { sound: sound }),
        },
      },
      apns: {
        payload: {
          aps: {
            ...(sound && { sound: sound }),
          },
        },
      },
      tokens: tokensBatch,
    };
    messageBatches.push(messages);
  }

  console.log(`[sendPushNotifications] Sending ${messageBatches.length} batch(es)`);

  var numSent = 0;
  var errors = [];
  var tokensToDelete = [];

  for (const messages of messageBatches) {
    const batchTokens = messages.tokens;
    const response = await admin.messaging().sendEachForMulticast(messages);
    console.log(`[sendPushNotifications] Batch result: ${response.successCount} success, ${response.failureCount} failed`);
    numSent += response.successCount;

    if (response.failureCount > 0) {
      response.responses.forEach((resp, idx) => {
        if (!resp.success) {
          const failedToken = batchTokens[idx];
          const errorCode = resp.error?.code || "";
          const errorMsg = resp.error?.message || "Unknown error";
          errors.push(errorMsg);
          console.log(`[sendPushNotifications] Token ${idx} failed: ${errorMsg} (code: ${errorCode})`);

          // Delete invalid tokens (not found, unregistered, invalid)
          if (errorCode === "messaging/registration-token-not-registered" ||
              errorCode === "messaging/invalid-registration-token" ||
              errorMsg.includes("not found") ||
              errorMsg.includes("not registered")) {
            const docRef = tokenToDocRef.get(failedToken);
            if (docRef) {
              tokensToDelete.push(docRef);
              console.log(`[sendPushNotifications] Marking token for deletion: ${failedToken.substring(0, 20)}...`);
            }
          }
        }
      });
    }
  }

  // Delete invalid tokens from Firestore
  if (tokensToDelete.length > 0) {
    console.log(`[sendPushNotifications] Deleting ${tokensToDelete.length} invalid token(s)`);
    await Promise.all(tokensToDelete.map(ref => ref.delete()));
    console.log(`[sendPushNotifications] Invalid tokens deleted successfully`);
  }

  console.log(`[sendPushNotifications] Total sent: ${numSent}`);
  await snapshot.ref.update({
    status: numSent > 0 ? "succeeded" : "failed",
    num_sent: numSent,
    num_tokens_cleaned: tokensToDelete.length,
    ...(errors.length > 0 && { errors: errors.slice(0, 5).join("; ") })
  });
}

function getUserFcmTokensCollection(userDocPath) {
  return firestore.doc(userDocPath).collection(kFcmTokensCollection);
}

function getDocIdBound(index, numBatches) {
  if (index <= 0) {
    return "users/(";
  }
  if (index >= numBatches) {
    return "users/}";
  }
  const numUidChars = 62;
  const twoCharOptions = Math.pow(numUidChars, 2);

  var twoCharIdx = (index * twoCharOptions) / numBatches;
  var firstCharIdx = Math.floor(twoCharIdx / numUidChars);
  var secondCharIdx = Math.floor(twoCharIdx % numUidChars);
  const firstChar = getCharForIndex(firstCharIdx);
  const secondChar = getCharForIndex(secondCharIdx);
  return "users/" + firstChar + secondChar;
}

function getCharForIndex(charIdx) {
  if (charIdx < 10) {
    return String.fromCharCode(charIdx + "0".charCodeAt(0));
  } else if (charIdx < 36) {
    return String.fromCharCode("A".charCodeAt(0) + charIdx - 10);
  } else {
    return String.fromCharCode("a".charCodeAt(0) + charIdx - 36);
  }
}
exports.onUserDeleted = functions.auth.user().onDelete(async (user) => {
  let firestore = admin.firestore();
  let userRef = firestore.doc("users/" + user.uid);
});
