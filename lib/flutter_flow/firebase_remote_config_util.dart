import 'package:firebase_remote_config/firebase_remote_config.dart';

Future initializeFirebaseRemoteConfig() async {
  try {
    await FirebaseRemoteConfig.instance.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(hours: 1),
    ));
    await FirebaseRemoteConfig.instance.setDefaults(const {
      'poll':
          'https://firebasestorage.googleapis.com/v0/b/ydrive-a35d2.firebasestorage.app/o/политика_конфеденциальности_приложение.pdf?alt=media&token=061471ea-ed01-4bf8-87b4-3693a45391b8',
      'usl':
          'https://firebasestorage.googleapis.com/v0/b/ydrive-a35d2.firebasestorage.app/o/условия%20использования.pdf?alt=media&token=dc68fba9-2d07-4d19-8732-2e5836391528',
    });
    await FirebaseRemoteConfig.instance.fetchAndActivate();
  } catch (error) {
    print(error);
  }
}

String getRemoteConfigString(String key) =>
    FirebaseRemoteConfig.instance.getString(key);

bool getRemoteConfigBool(String key) =>
    FirebaseRemoteConfig.instance.getBool(key);

int getRemoteConfigInt(String key) => FirebaseRemoteConfig.instance.getInt(key);

double getRemoteConfigDouble(String key) =>
    FirebaseRemoteConfig.instance.getDouble(key);
