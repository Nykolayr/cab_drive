import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/bottom/image_view/image_view_widget.dart';
import 'dart:ui';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import 'message_card_model.dart';
export 'message_card_model.dart';

class MessageCardWidget extends StatefulWidget {
  const MessageCardWidget({
    super.key,
    required this.messageDoc,
    required this.chat,
  });

  final MessagesRecord? messageDoc;
  final ChatsRecord? chat;

  @override
  State<MessageCardWidget> createState() => _MessageCardWidgetState();
}

class _MessageCardWidgetState extends State<MessageCardWidget> {
  late MessageCardModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MessageCardModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.messageDoc?.sender != currentUserReference)
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(10.0, 0.0, 30.0, 0.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 1.0,
                  child: custom_widgets.ReadMessage(
                    width: double.infinity,
                    height: 1.0,
                    messageId: widget.messageDoc!.reference.id,
                    action: () async {
                      await widget.messageDoc!.reference
                          .update(createMessagesRecordData(
                        read: true,
                      ));
                    },
                  ),
                ),
                Stack(
                  alignment: const AlignmentDirectional(0.0, 1.0),
                  children: [
                    Align(
                      alignment: const AlignmentDirectional(-1.0, 0.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).primaryBackground,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(18.0),
                            topRight: Radius.circular(18.0),
                            bottomLeft: Radius.circular(8.0),
                            bottomRight: Radius.circular(18.0),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.messageDoc?.listImages != null &&
                                (widget.messageDoc?.listImages)!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.all(1.0),
                                child: Stack(
                                  alignment:
                                      const AlignmentDirectional(1.0, 1.0),
                                  children: [
                                    if (widget.messageDoc?.listImages.length ==
                                        1)
                                      InkWell(
                                        splashColor: Colors.transparent,
                                        focusColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () async {
                                          await showModalBottomSheet(
                                            isScrollControlled: true,
                                            backgroundColor: Colors.transparent,
                                            context: context,
                                            builder: (context) {
                                              return WebViewAware(
                                                child: Padding(
                                                  padding:
                                                      MediaQuery.viewInsetsOf(
                                                          context),
                                                  child: ImageViewWidget(
                                                    indexCurrent: 0,
                                                    alllistImage: widget
                                                        .messageDoc!.listImages,
                                                  ),
                                                ),
                                              );
                                            },
                                          ).then(
                                              (value) => safeSetState(() {}));
                                        },
                                        child: Hero(
                                          tag: widget.messageDoc!.listImages
                                              .firstOrNull!,
                                          transitionOnUserGestures: true,
                                          child: ClipRRect(
                                            borderRadius:
                                                const BorderRadius.only(
                                              topLeft: Radius.circular(17.0),
                                              topRight: Radius.circular(17.0),
                                              bottomLeft: Radius.circular(7.0),
                                              bottomRight:
                                                  Radius.circular(17.0),
                                            ),
                                            child: CachedNetworkImage(
                                              fadeInDuration: const Duration(
                                                  milliseconds: 5),
                                              fadeOutDuration: const Duration(
                                                  milliseconds: 5),
                                              imageUrl: widget.messageDoc!
                                                  .listImages.firstOrNull!,
                                              width: double.infinity,
                                              height: 300.0,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (widget.messageDoc?.listImages.length ==
                                        2)
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Flexible(
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                await showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  context: context,
                                                  builder: (context) {
                                                    return WebViewAware(
                                                      child: Padding(
                                                        padding: MediaQuery
                                                            .viewInsetsOf(
                                                                context),
                                                        child: ImageViewWidget(
                                                          indexCurrent: 0,
                                                          alllistImage: widget
                                                              .messageDoc!
                                                              .listImages,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ).then((value) =>
                                                    safeSetState(() {}));
                                              },
                                              child: Hero(
                                                tag: widget.messageDoc!
                                                    .listImages.firstOrNull!,
                                                transitionOnUserGestures: true,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(17.0),
                                                    bottomLeft:
                                                        Radius.circular(7.0),
                                                  ),
                                                  child: CachedNetworkImage(
                                                    fadeInDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    fadeOutDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    imageUrl: widget
                                                        .messageDoc!
                                                        .listImages
                                                        .firstOrNull!,
                                                    width: double.infinity,
                                                    height: 170.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Flexible(
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                await showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  context: context,
                                                  builder: (context) {
                                                    return WebViewAware(
                                                      child: Padding(
                                                        padding: MediaQuery
                                                            .viewInsetsOf(
                                                                context),
                                                        child: ImageViewWidget(
                                                          indexCurrent: 1,
                                                          alllistImage: widget
                                                              .messageDoc!
                                                              .listImages,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ).then((value) =>
                                                    safeSetState(() {}));
                                              },
                                              child: Hero(
                                                tag: widget.messageDoc!
                                                    .listImages.lastOrNull!,
                                                transitionOnUserGestures: true,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    topRight:
                                                        Radius.circular(17.0),
                                                    bottomRight:
                                                        Radius.circular(17.0),
                                                  ),
                                                  child: CachedNetworkImage(
                                                    fadeInDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    fadeOutDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    imageUrl: widget.messageDoc!
                                                        .listImages.lastOrNull!,
                                                    width: double.infinity,
                                                    height: 170.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ].divide(const SizedBox(width: 1.0)),
                                      ),
                                    if (widget.messageDoc?.listImages.length ==
                                        3)
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          InkWell(
                                            splashColor: Colors.transparent,
                                            focusColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: () async {
                                              await showModalBottomSheet(
                                                isScrollControlled: true,
                                                backgroundColor:
                                                    Colors.transparent,
                                                context: context,
                                                builder: (context) {
                                                  return WebViewAware(
                                                    child: Padding(
                                                      padding: MediaQuery
                                                          .viewInsetsOf(
                                                              context),
                                                      child: ImageViewWidget(
                                                        indexCurrent: 0,
                                                        alllistImage: widget
                                                            .messageDoc!
                                                            .listImages,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ).then((value) =>
                                                  safeSetState(() {}));
                                            },
                                            child: Hero(
                                              tag: widget.messageDoc!.listImages
                                                  .firstOrNull!,
                                              transitionOnUserGestures: true,
                                              child: ClipRRect(
                                                borderRadius:
                                                    const BorderRadius.only(
                                                  topLeft:
                                                      Radius.circular(17.0),
                                                  bottomLeft:
                                                      Radius.circular(7.0),
                                                ),
                                                child: CachedNetworkImage(
                                                  fadeInDuration:
                                                      const Duration(
                                                          milliseconds: 5),
                                                  fadeOutDuration:
                                                      const Duration(
                                                          milliseconds: 5),
                                                  imageUrl: widget.messageDoc!
                                                      .listImages.firstOrNull!,
                                                  width: 260.0,
                                                  height: 300.0,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Flexible(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    await showModalBottomSheet(
                                                      isScrollControlled: true,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      context: context,
                                                      builder: (context) {
                                                        return WebViewAware(
                                                          child: Padding(
                                                            padding: MediaQuery
                                                                .viewInsetsOf(
                                                                    context),
                                                            child:
                                                                ImageViewWidget(
                                                              indexCurrent: 1,
                                                              alllistImage: widget
                                                                  .messageDoc!
                                                                  .listImages,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ).then((value) =>
                                                        safeSetState(() {}));
                                                  },
                                                  child: Hero(
                                                    tag: widget
                                                        .messageDoc!.listImages
                                                        .elementAtOrNull(1)!,
                                                    transitionOnUserGestures:
                                                        true,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(
                                                        topRight:
                                                            Radius.circular(
                                                                17.0),
                                                      ),
                                                      child: CachedNetworkImage(
                                                        fadeInDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        fadeOutDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        imageUrl: widget
                                                            .messageDoc!
                                                            .listImages
                                                            .elementAtOrNull(
                                                                1)!,
                                                        width: double.infinity,
                                                        height: 150.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    await showModalBottomSheet(
                                                      isScrollControlled: true,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      context: context,
                                                      builder: (context) {
                                                        return WebViewAware(
                                                          child: Padding(
                                                            padding: MediaQuery
                                                                .viewInsetsOf(
                                                                    context),
                                                            child:
                                                                ImageViewWidget(
                                                              indexCurrent: 2,
                                                              alllistImage: widget
                                                                  .messageDoc!
                                                                  .listImages,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ).then((value) =>
                                                        safeSetState(() {}));
                                                  },
                                                  child: Hero(
                                                    tag: widget.messageDoc!
                                                        .listImages.lastOrNull!,
                                                    transitionOnUserGestures:
                                                        true,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(
                                                        bottomRight:
                                                            Radius.circular(
                                                                17.0),
                                                      ),
                                                      child: CachedNetworkImage(
                                                        fadeInDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        fadeOutDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        imageUrl: widget
                                                            .messageDoc!
                                                            .listImages
                                                            .lastOrNull!,
                                                        width: double.infinity,
                                                        height: 150.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ].divide(
                                                  const SizedBox(height: 1.0)),
                                            ),
                                          ),
                                        ].divide(const SizedBox(width: 1.0)),
                                      ),
                                    if (widget.messageDoc?.listImages.length ==
                                        4)
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          InkWell(
                                            splashColor: Colors.transparent,
                                            focusColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: () async {
                                              await showModalBottomSheet(
                                                isScrollControlled: true,
                                                backgroundColor:
                                                    Colors.transparent,
                                                context: context,
                                                builder: (context) {
                                                  return WebViewAware(
                                                    child: Padding(
                                                      padding: MediaQuery
                                                          .viewInsetsOf(
                                                              context),
                                                      child: ImageViewWidget(
                                                        indexCurrent: 0,
                                                        alllistImage: widget
                                                            .messageDoc!
                                                            .listImages,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ).then((value) =>
                                                  safeSetState(() {}));
                                            },
                                            child: Hero(
                                              tag: widget.messageDoc!.listImages
                                                  .firstOrNull!,
                                              transitionOnUserGestures: true,
                                              child: ClipRRect(
                                                borderRadius:
                                                    const BorderRadius.only(
                                                  topLeft:
                                                      Radius.circular(17.0),
                                                  bottomLeft:
                                                      Radius.circular(7.0),
                                                ),
                                                child: CachedNetworkImage(
                                                  fadeInDuration:
                                                      const Duration(
                                                          milliseconds: 5),
                                                  fadeOutDuration:
                                                      const Duration(
                                                          milliseconds: 5),
                                                  imageUrl: widget.messageDoc!
                                                      .listImages.firstOrNull!,
                                                  width: 260.0,
                                                  height: 300.0,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Flexible(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    await showModalBottomSheet(
                                                      isScrollControlled: true,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      context: context,
                                                      builder: (context) {
                                                        return WebViewAware(
                                                          child: Padding(
                                                            padding: MediaQuery
                                                                .viewInsetsOf(
                                                                    context),
                                                            child:
                                                                ImageViewWidget(
                                                              indexCurrent: 1,
                                                              alllistImage: widget
                                                                  .messageDoc!
                                                                  .listImages,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ).then((value) =>
                                                        safeSetState(() {}));
                                                  },
                                                  child: Hero(
                                                    tag: widget
                                                        .messageDoc!.listImages
                                                        .elementAtOrNull(1)!,
                                                    transitionOnUserGestures:
                                                        true,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(
                                                        topRight:
                                                            Radius.circular(
                                                                17.0),
                                                      ),
                                                      child: CachedNetworkImage(
                                                        fadeInDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        fadeOutDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        imageUrl: widget
                                                            .messageDoc!
                                                            .listImages
                                                            .elementAtOrNull(
                                                                1)!,
                                                        width: double.infinity,
                                                        height: 100.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    await showModalBottomSheet(
                                                      isScrollControlled: true,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      context: context,
                                                      builder: (context) {
                                                        return WebViewAware(
                                                          child: Padding(
                                                            padding: MediaQuery
                                                                .viewInsetsOf(
                                                                    context),
                                                            child:
                                                                ImageViewWidget(
                                                              indexCurrent: 2,
                                                              alllistImage: widget
                                                                  .messageDoc!
                                                                  .listImages,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ).then((value) =>
                                                        safeSetState(() {}));
                                                  },
                                                  child: Hero(
                                                    tag: widget
                                                        .messageDoc!.listImages
                                                        .elementAtOrNull(2)!,
                                                    transitionOnUserGestures:
                                                        true,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(),
                                                      child: CachedNetworkImage(
                                                        fadeInDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        fadeOutDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        imageUrl: widget
                                                            .messageDoc!
                                                            .listImages
                                                            .elementAtOrNull(
                                                                2)!,
                                                        width: double.infinity,
                                                        height: 100.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    await showModalBottomSheet(
                                                      isScrollControlled: true,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      context: context,
                                                      builder: (context) {
                                                        return WebViewAware(
                                                          child: Padding(
                                                            padding: MediaQuery
                                                                .viewInsetsOf(
                                                                    context),
                                                            child:
                                                                ImageViewWidget(
                                                              indexCurrent: 3,
                                                              alllistImage: widget
                                                                  .messageDoc!
                                                                  .listImages,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ).then((value) =>
                                                        safeSetState(() {}));
                                                  },
                                                  child: Hero(
                                                    tag: widget.messageDoc!
                                                        .listImages.lastOrNull!,
                                                    transitionOnUserGestures:
                                                        true,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(
                                                        bottomRight:
                                                            Radius.circular(
                                                                17.0),
                                                      ),
                                                      child: CachedNetworkImage(
                                                        fadeInDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        fadeOutDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        imageUrl: widget
                                                            .messageDoc!
                                                            .listImages
                                                            .lastOrNull!,
                                                        width: double.infinity,
                                                        height: 100.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ].divide(
                                                  const SizedBox(height: 1.0)),
                                            ),
                                          ),
                                        ].divide(const SizedBox(width: 1.0)),
                                      ),
                                    if (widget.messageDoc?.listImages.length ==
                                        5)
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Expanded(
                                                child: InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    await showModalBottomSheet(
                                                      isScrollControlled: true,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      context: context,
                                                      builder: (context) {
                                                        return WebViewAware(
                                                          child: Padding(
                                                            padding: MediaQuery
                                                                .viewInsetsOf(
                                                                    context),
                                                            child:
                                                                ImageViewWidget(
                                                              indexCurrent: 0,
                                                              alllistImage: widget
                                                                  .messageDoc!
                                                                  .listImages,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ).then((value) =>
                                                        safeSetState(() {}));
                                                  },
                                                  child: Hero(
                                                    tag: widget
                                                        .messageDoc!
                                                        .listImages
                                                        .firstOrNull!,
                                                    transitionOnUserGestures:
                                                        true,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(
                                                        topLeft:
                                                            Radius.circular(
                                                                17.0),
                                                      ),
                                                      child: CachedNetworkImage(
                                                        fadeInDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        fadeOutDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        imageUrl: widget
                                                            .messageDoc!
                                                            .listImages
                                                            .firstOrNull!,
                                                        width: double.infinity,
                                                        height: 170.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    await showModalBottomSheet(
                                                      isScrollControlled: true,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      context: context,
                                                      builder: (context) {
                                                        return WebViewAware(
                                                          child: Padding(
                                                            padding: MediaQuery
                                                                .viewInsetsOf(
                                                                    context),
                                                            child:
                                                                ImageViewWidget(
                                                              indexCurrent: 1,
                                                              alllistImage: widget
                                                                  .messageDoc!
                                                                  .listImages,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ).then((value) =>
                                                        safeSetState(() {}));
                                                  },
                                                  child: Hero(
                                                    tag: widget
                                                        .messageDoc!.listImages
                                                        .elementAtOrNull(1)!,
                                                    transitionOnUserGestures:
                                                        true,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(
                                                        topRight:
                                                            Radius.circular(
                                                                17.0),
                                                      ),
                                                      child: CachedNetworkImage(
                                                        fadeInDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        fadeOutDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        imageUrl: widget
                                                            .messageDoc!
                                                            .listImages
                                                            .elementAtOrNull(
                                                                1)!,
                                                        width: double.infinity,
                                                        height: 170.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ].divide(
                                                const SizedBox(width: 1.0)),
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Expanded(
                                                child: InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    await showModalBottomSheet(
                                                      isScrollControlled: true,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      context: context,
                                                      builder: (context) {
                                                        return WebViewAware(
                                                          child: Padding(
                                                            padding: MediaQuery
                                                                .viewInsetsOf(
                                                                    context),
                                                            child:
                                                                ImageViewWidget(
                                                              indexCurrent: 2,
                                                              alllistImage: widget
                                                                  .messageDoc!
                                                                  .listImages,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ).then((value) =>
                                                        safeSetState(() {}));
                                                  },
                                                  child: Hero(
                                                    tag: widget
                                                        .messageDoc!.listImages
                                                        .elementAtOrNull(2)!,
                                                    transitionOnUserGestures:
                                                        true,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(
                                                        bottomLeft:
                                                            Radius.circular(
                                                                7.0),
                                                      ),
                                                      child: CachedNetworkImage(
                                                        fadeInDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        fadeOutDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        imageUrl: widget
                                                            .messageDoc!
                                                            .listImages
                                                            .elementAtOrNull(
                                                                2)!,
                                                        width: double.infinity,
                                                        height: 127.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    await showModalBottomSheet(
                                                      isScrollControlled: true,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      context: context,
                                                      builder: (context) {
                                                        return WebViewAware(
                                                          child: Padding(
                                                            padding: MediaQuery
                                                                .viewInsetsOf(
                                                                    context),
                                                            child:
                                                                ImageViewWidget(
                                                              indexCurrent: 3,
                                                              alllistImage: widget
                                                                  .messageDoc!
                                                                  .listImages,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ).then((value) =>
                                                        safeSetState(() {}));
                                                  },
                                                  child: Hero(
                                                    tag: widget
                                                        .messageDoc!.listImages
                                                        .elementAtOrNull(3)!,
                                                    transitionOnUserGestures:
                                                        true,
                                                    child: CachedNetworkImage(
                                                      fadeInDuration:
                                                          const Duration(
                                                              milliseconds: 5),
                                                      fadeOutDuration:
                                                          const Duration(
                                                              milliseconds: 5),
                                                      imageUrl: widget
                                                          .messageDoc!
                                                          .listImages
                                                          .elementAtOrNull(3)!,
                                                      width: double.infinity,
                                                      height: 127.0,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    await showModalBottomSheet(
                                                      isScrollControlled: true,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      context: context,
                                                      builder: (context) {
                                                        return WebViewAware(
                                                          child: Padding(
                                                            padding: MediaQuery
                                                                .viewInsetsOf(
                                                                    context),
                                                            child:
                                                                ImageViewWidget(
                                                              indexCurrent: 4,
                                                              alllistImage: widget
                                                                  .messageDoc!
                                                                  .listImages,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ).then((value) =>
                                                        safeSetState(() {}));
                                                  },
                                                  child: Hero(
                                                    tag: widget.messageDoc!
                                                        .listImages.lastOrNull!,
                                                    transitionOnUserGestures:
                                                        true,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(
                                                        bottomRight:
                                                            Radius.circular(
                                                                17.0),
                                                      ),
                                                      child: CachedNetworkImage(
                                                        fadeInDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        fadeOutDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        imageUrl: widget
                                                            .messageDoc!
                                                            .listImages
                                                            .lastOrNull!,
                                                        width: double.infinity,
                                                        height: 127.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ].divide(
                                                const SizedBox(width: 1.0)),
                                          ),
                                        ].divide(const SizedBox(height: 1.0)),
                                      ),
                                    if (widget.messageDoc?.listImages.length ==
                                        6)
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Expanded(
                                                child: InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    await showModalBottomSheet(
                                                      isScrollControlled: true,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      context: context,
                                                      builder: (context) {
                                                        return WebViewAware(
                                                          child: Padding(
                                                            padding: MediaQuery
                                                                .viewInsetsOf(
                                                                    context),
                                                            child:
                                                                ImageViewWidget(
                                                              indexCurrent: 0,
                                                              alllistImage: widget
                                                                  .messageDoc!
                                                                  .listImages,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ).then((value) =>
                                                        safeSetState(() {}));
                                                  },
                                                  child: Hero(
                                                    tag: widget
                                                        .messageDoc!
                                                        .listImages
                                                        .firstOrNull!,
                                                    transitionOnUserGestures:
                                                        true,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(
                                                        topLeft:
                                                            Radius.circular(
                                                                17.0),
                                                      ),
                                                      child: CachedNetworkImage(
                                                        fadeInDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        fadeOutDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        imageUrl: widget
                                                            .messageDoc!
                                                            .listImages
                                                            .firstOrNull!,
                                                        width: double.infinity,
                                                        height: 120.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    await showModalBottomSheet(
                                                      isScrollControlled: true,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      context: context,
                                                      builder: (context) {
                                                        return WebViewAware(
                                                          child: Padding(
                                                            padding: MediaQuery
                                                                .viewInsetsOf(
                                                                    context),
                                                            child:
                                                                ImageViewWidget(
                                                              indexCurrent: 1,
                                                              alllistImage: widget
                                                                  .messageDoc!
                                                                  .listImages,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ).then((value) =>
                                                        safeSetState(() {}));
                                                  },
                                                  child: Hero(
                                                    tag: widget
                                                        .messageDoc!.listImages
                                                        .elementAtOrNull(1)!,
                                                    transitionOnUserGestures:
                                                        true,
                                                    child: CachedNetworkImage(
                                                      fadeInDuration:
                                                          const Duration(
                                                              milliseconds: 5),
                                                      fadeOutDuration:
                                                          const Duration(
                                                              milliseconds: 5),
                                                      imageUrl: widget
                                                          .messageDoc!
                                                          .listImages
                                                          .elementAtOrNull(1)!,
                                                      width: double.infinity,
                                                      height: 120.0,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    await showModalBottomSheet(
                                                      isScrollControlled: true,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      context: context,
                                                      builder: (context) {
                                                        return WebViewAware(
                                                          child: Padding(
                                                            padding: MediaQuery
                                                                .viewInsetsOf(
                                                                    context),
                                                            child:
                                                                ImageViewWidget(
                                                              indexCurrent: 2,
                                                              alllistImage: widget
                                                                  .messageDoc!
                                                                  .listImages,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ).then((value) =>
                                                        safeSetState(() {}));
                                                  },
                                                  child: Hero(
                                                    tag: widget
                                                        .messageDoc!.listImages
                                                        .elementAtOrNull(2)!,
                                                    transitionOnUserGestures:
                                                        true,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(
                                                        topRight:
                                                            Radius.circular(
                                                                17.0),
                                                      ),
                                                      child: CachedNetworkImage(
                                                        fadeInDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        fadeOutDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        imageUrl: widget
                                                            .messageDoc!
                                                            .listImages
                                                            .elementAtOrNull(
                                                                2)!,
                                                        width: double.infinity,
                                                        height: 120.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ].divide(
                                                const SizedBox(width: 1.0)),
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Expanded(
                                                child: InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    await showModalBottomSheet(
                                                      isScrollControlled: true,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      context: context,
                                                      builder: (context) {
                                                        return WebViewAware(
                                                          child: Padding(
                                                            padding: MediaQuery
                                                                .viewInsetsOf(
                                                                    context),
                                                            child:
                                                                ImageViewWidget(
                                                              indexCurrent: 3,
                                                              alllistImage: widget
                                                                  .messageDoc!
                                                                  .listImages,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ).then((value) =>
                                                        safeSetState(() {}));
                                                  },
                                                  child: Hero(
                                                    tag: widget
                                                        .messageDoc!.listImages
                                                        .elementAtOrNull(3)!,
                                                    transitionOnUserGestures:
                                                        true,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(
                                                        bottomLeft:
                                                            Radius.circular(
                                                                7.0),
                                                      ),
                                                      child: CachedNetworkImage(
                                                        fadeInDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        fadeOutDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        imageUrl: widget
                                                            .messageDoc!
                                                            .listImages
                                                            .elementAtOrNull(
                                                                3)!,
                                                        width: double.infinity,
                                                        height: 120.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    await showModalBottomSheet(
                                                      isScrollControlled: true,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      context: context,
                                                      builder: (context) {
                                                        return WebViewAware(
                                                          child: Padding(
                                                            padding: MediaQuery
                                                                .viewInsetsOf(
                                                                    context),
                                                            child:
                                                                ImageViewWidget(
                                                              indexCurrent: 4,
                                                              alllistImage: widget
                                                                  .messageDoc!
                                                                  .listImages,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ).then((value) =>
                                                        safeSetState(() {}));
                                                  },
                                                  child: Hero(
                                                    tag: widget
                                                        .messageDoc!.listImages
                                                        .elementAtOrNull(4)!,
                                                    transitionOnUserGestures:
                                                        true,
                                                    child: CachedNetworkImage(
                                                      fadeInDuration:
                                                          const Duration(
                                                              milliseconds: 5),
                                                      fadeOutDuration:
                                                          const Duration(
                                                              milliseconds: 5),
                                                      imageUrl: widget
                                                          .messageDoc!
                                                          .listImages
                                                          .elementAtOrNull(4)!,
                                                      width: double.infinity,
                                                      height: 120.0,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    await showModalBottomSheet(
                                                      isScrollControlled: true,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      context: context,
                                                      builder: (context) {
                                                        return WebViewAware(
                                                          child: Padding(
                                                            padding: MediaQuery
                                                                .viewInsetsOf(
                                                                    context),
                                                            child:
                                                                ImageViewWidget(
                                                              indexCurrent: 5,
                                                              alllistImage: widget
                                                                  .messageDoc!
                                                                  .listImages,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ).then((value) =>
                                                        safeSetState(() {}));
                                                  },
                                                  child: Hero(
                                                    tag: widget.messageDoc!
                                                        .listImages.lastOrNull!,
                                                    transitionOnUserGestures:
                                                        true,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(
                                                        bottomRight:
                                                            Radius.circular(
                                                                17.0),
                                                      ),
                                                      child: CachedNetworkImage(
                                                        fadeInDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        fadeOutDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        imageUrl: widget
                                                            .messageDoc!
                                                            .listImages
                                                            .lastOrNull!,
                                                        width: double.infinity,
                                                        height: 120.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ].divide(
                                                const SizedBox(width: 1.0)),
                                          ),
                                        ].divide(const SizedBox(height: 1.0)),
                                      ),
                                    if (widget.messageDoc?.listImages.length ==
                                        7)
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Expanded(
                                                child: InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    await showModalBottomSheet(
                                                      isScrollControlled: true,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      context: context,
                                                      builder: (context) {
                                                        return WebViewAware(
                                                          child: Padding(
                                                            padding: MediaQuery
                                                                .viewInsetsOf(
                                                                    context),
                                                            child:
                                                                ImageViewWidget(
                                                              indexCurrent: 0,
                                                              alllistImage: widget
                                                                  .messageDoc!
                                                                  .listImages,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ).then((value) =>
                                                        safeSetState(() {}));
                                                  },
                                                  child: Hero(
                                                    tag: widget
                                                        .messageDoc!
                                                        .listImages
                                                        .firstOrNull!,
                                                    transitionOnUserGestures:
                                                        true,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(
                                                        topLeft:
                                                            Radius.circular(
                                                                17.0),
                                                      ),
                                                      child: CachedNetworkImage(
                                                        fadeInDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        fadeOutDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        imageUrl: widget
                                                            .messageDoc!
                                                            .listImages
                                                            .firstOrNull!,
                                                        width: double.infinity,
                                                        height: 170.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    await showModalBottomSheet(
                                                      isScrollControlled: true,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      context: context,
                                                      builder: (context) {
                                                        return WebViewAware(
                                                          child: Padding(
                                                            padding: MediaQuery
                                                                .viewInsetsOf(
                                                                    context),
                                                            child:
                                                                ImageViewWidget(
                                                              indexCurrent: 1,
                                                              alllistImage: widget
                                                                  .messageDoc!
                                                                  .listImages,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ).then((value) =>
                                                        safeSetState(() {}));
                                                  },
                                                  child: Hero(
                                                    tag: widget
                                                        .messageDoc!.listImages
                                                        .elementAtOrNull(1)!,
                                                    transitionOnUserGestures:
                                                        true,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(
                                                        topRight:
                                                            Radius.circular(
                                                                17.0),
                                                      ),
                                                      child: CachedNetworkImage(
                                                        fadeInDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        fadeOutDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        imageUrl: widget
                                                            .messageDoc!
                                                            .listImages
                                                            .elementAtOrNull(
                                                                1)!,
                                                        width: double.infinity,
                                                        height: 170.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ].divide(
                                                const SizedBox(width: 1.0)),
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Expanded(
                                                child: InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    await showModalBottomSheet(
                                                      isScrollControlled: true,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      context: context,
                                                      builder: (context) {
                                                        return WebViewAware(
                                                          child: Padding(
                                                            padding: MediaQuery
                                                                .viewInsetsOf(
                                                                    context),
                                                            child:
                                                                ImageViewWidget(
                                                              indexCurrent: 2,
                                                              alllistImage: widget
                                                                  .messageDoc!
                                                                  .listImages,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ).then((value) =>
                                                        safeSetState(() {}));
                                                  },
                                                  child: Hero(
                                                    tag: widget
                                                        .messageDoc!.listImages
                                                        .elementAtOrNull(2)!,
                                                    transitionOnUserGestures:
                                                        true,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(),
                                                      child: CachedNetworkImage(
                                                        fadeInDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        fadeOutDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        imageUrl: widget
                                                            .messageDoc!
                                                            .listImages
                                                            .elementAtOrNull(
                                                                2)!,
                                                        width: double.infinity,
                                                        height: 170.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    await showModalBottomSheet(
                                                      isScrollControlled: true,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      context: context,
                                                      builder: (context) {
                                                        return WebViewAware(
                                                          child: Padding(
                                                            padding: MediaQuery
                                                                .viewInsetsOf(
                                                                    context),
                                                            child:
                                                                ImageViewWidget(
                                                              indexCurrent: 3,
                                                              alllistImage: widget
                                                                  .messageDoc!
                                                                  .listImages,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ).then((value) =>
                                                        safeSetState(() {}));
                                                  },
                                                  child: Hero(
                                                    tag: widget
                                                        .messageDoc!.listImages
                                                        .elementAtOrNull(3)!,
                                                    transitionOnUserGestures:
                                                        true,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(),
                                                      child: CachedNetworkImage(
                                                        fadeInDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        fadeOutDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        imageUrl: widget
                                                            .messageDoc!
                                                            .listImages
                                                            .elementAtOrNull(
                                                                3)!,
                                                        width: double.infinity,
                                                        height: 170.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ].divide(
                                                const SizedBox(width: 1.0)),
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Expanded(
                                                child: InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    await showModalBottomSheet(
                                                      isScrollControlled: true,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      context: context,
                                                      builder: (context) {
                                                        return WebViewAware(
                                                          child: Padding(
                                                            padding: MediaQuery
                                                                .viewInsetsOf(
                                                                    context),
                                                            child:
                                                                ImageViewWidget(
                                                              indexCurrent: 4,
                                                              alllistImage: widget
                                                                  .messageDoc!
                                                                  .listImages,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ).then((value) =>
                                                        safeSetState(() {}));
                                                  },
                                                  child: Hero(
                                                    tag: widget
                                                        .messageDoc!.listImages
                                                        .elementAtOrNull(4)!,
                                                    transitionOnUserGestures:
                                                        true,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(
                                                        bottomLeft:
                                                            Radius.circular(
                                                                7.0),
                                                      ),
                                                      child: CachedNetworkImage(
                                                        fadeInDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        fadeOutDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        imageUrl: widget
                                                            .messageDoc!
                                                            .listImages
                                                            .elementAtOrNull(
                                                                4)!,
                                                        width: double.infinity,
                                                        height: 120.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    await showModalBottomSheet(
                                                      isScrollControlled: true,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      context: context,
                                                      builder: (context) {
                                                        return WebViewAware(
                                                          child: Padding(
                                                            padding: MediaQuery
                                                                .viewInsetsOf(
                                                                    context),
                                                            child:
                                                                ImageViewWidget(
                                                              indexCurrent: 5,
                                                              alllistImage: widget
                                                                  .messageDoc!
                                                                  .listImages,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ).then((value) =>
                                                        safeSetState(() {}));
                                                  },
                                                  child: Hero(
                                                    tag: widget
                                                        .messageDoc!.listImages
                                                        .elementAtOrNull(5)!,
                                                    transitionOnUserGestures:
                                                        true,
                                                    child: CachedNetworkImage(
                                                      fadeInDuration:
                                                          const Duration(
                                                              milliseconds: 5),
                                                      fadeOutDuration:
                                                          const Duration(
                                                              milliseconds: 5),
                                                      imageUrl: widget
                                                          .messageDoc!
                                                          .listImages
                                                          .elementAtOrNull(5)!,
                                                      width: double.infinity,
                                                      height: 120.0,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    await showModalBottomSheet(
                                                      isScrollControlled: true,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      context: context,
                                                      builder: (context) {
                                                        return WebViewAware(
                                                          child: Padding(
                                                            padding: MediaQuery
                                                                .viewInsetsOf(
                                                                    context),
                                                            child:
                                                                ImageViewWidget(
                                                              indexCurrent: 6,
                                                              alllistImage: widget
                                                                  .messageDoc!
                                                                  .listImages,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ).then((value) =>
                                                        safeSetState(() {}));
                                                  },
                                                  child: Hero(
                                                    tag: widget.messageDoc!
                                                        .listImages.lastOrNull!,
                                                    transitionOnUserGestures:
                                                        true,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(
                                                        bottomRight:
                                                            Radius.circular(
                                                                17.0),
                                                      ),
                                                      child: CachedNetworkImage(
                                                        fadeInDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        fadeOutDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        imageUrl: widget
                                                            .messageDoc!
                                                            .listImages
                                                            .lastOrNull!,
                                                        width: double.infinity,
                                                        height: 120.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ].divide(
                                                const SizedBox(width: 1.0)),
                                          ),
                                        ].divide(const SizedBox(height: 1.0)),
                                      ),
                                    if (widget.messageDoc?.listImages.length ==
                                        8)
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Expanded(
                                                child: InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    await showModalBottomSheet(
                                                      isScrollControlled: true,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      context: context,
                                                      builder: (context) {
                                                        return WebViewAware(
                                                          child: Padding(
                                                            padding: MediaQuery
                                                                .viewInsetsOf(
                                                                    context),
                                                            child:
                                                                ImageViewWidget(
                                                              indexCurrent: 0,
                                                              alllistImage: widget
                                                                  .messageDoc!
                                                                  .listImages,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ).then((value) =>
                                                        safeSetState(() {}));
                                                  },
                                                  child: Hero(
                                                    tag: widget
                                                        .messageDoc!
                                                        .listImages
                                                        .firstOrNull!,
                                                    transitionOnUserGestures:
                                                        true,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(
                                                        topLeft:
                                                            Radius.circular(
                                                                17.0),
                                                      ),
                                                      child: CachedNetworkImage(
                                                        fadeInDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        fadeOutDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        imageUrl: widget
                                                            .messageDoc!
                                                            .listImages
                                                            .firstOrNull!,
                                                        width: double.infinity,
                                                        height: 170.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    await showModalBottomSheet(
                                                      isScrollControlled: true,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      context: context,
                                                      builder: (context) {
                                                        return WebViewAware(
                                                          child: Padding(
                                                            padding: MediaQuery
                                                                .viewInsetsOf(
                                                                    context),
                                                            child:
                                                                ImageViewWidget(
                                                              indexCurrent: 1,
                                                              alllistImage: widget
                                                                  .messageDoc!
                                                                  .listImages,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ).then((value) =>
                                                        safeSetState(() {}));
                                                  },
                                                  child: Hero(
                                                    tag: widget
                                                        .messageDoc!.listImages
                                                        .elementAtOrNull(1)!,
                                                    transitionOnUserGestures:
                                                        true,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(
                                                        topRight:
                                                            Radius.circular(
                                                                17.0),
                                                      ),
                                                      child: CachedNetworkImage(
                                                        fadeInDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        fadeOutDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        imageUrl: widget
                                                            .messageDoc!
                                                            .listImages
                                                            .elementAtOrNull(
                                                                1)!,
                                                        width: double.infinity,
                                                        height: 170.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ].divide(
                                                const SizedBox(width: 1.0)),
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Expanded(
                                                child: InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    await showModalBottomSheet(
                                                      isScrollControlled: true,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      context: context,
                                                      builder: (context) {
                                                        return WebViewAware(
                                                          child: Padding(
                                                            padding: MediaQuery
                                                                .viewInsetsOf(
                                                                    context),
                                                            child:
                                                                ImageViewWidget(
                                                              indexCurrent: 2,
                                                              alllistImage: widget
                                                                  .messageDoc!
                                                                  .listImages,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ).then((value) =>
                                                        safeSetState(() {}));
                                                  },
                                                  child: Hero(
                                                    tag: widget
                                                        .messageDoc!.listImages
                                                        .elementAtOrNull(2)!,
                                                    transitionOnUserGestures:
                                                        true,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(),
                                                      child: CachedNetworkImage(
                                                        fadeInDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        fadeOutDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        imageUrl: widget
                                                            .messageDoc!
                                                            .listImages
                                                            .elementAtOrNull(
                                                                2)!,
                                                        width: double.infinity,
                                                        height: 120.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    await showModalBottomSheet(
                                                      isScrollControlled: true,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      context: context,
                                                      builder: (context) {
                                                        return WebViewAware(
                                                          child: Padding(
                                                            padding: MediaQuery
                                                                .viewInsetsOf(
                                                                    context),
                                                            child:
                                                                ImageViewWidget(
                                                              indexCurrent: 3,
                                                              alllistImage: widget
                                                                  .messageDoc!
                                                                  .listImages,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ).then((value) =>
                                                        safeSetState(() {}));
                                                  },
                                                  child: Hero(
                                                    tag: widget
                                                        .messageDoc!.listImages
                                                        .elementAtOrNull(3)!,
                                                    transitionOnUserGestures:
                                                        true,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(),
                                                      child: CachedNetworkImage(
                                                        fadeInDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        fadeOutDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        imageUrl: widget
                                                            .messageDoc!
                                                            .listImages
                                                            .elementAtOrNull(
                                                                3)!,
                                                        width: double.infinity,
                                                        height: 120.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    await showModalBottomSheet(
                                                      isScrollControlled: true,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      context: context,
                                                      builder: (context) {
                                                        return WebViewAware(
                                                          child: Padding(
                                                            padding: MediaQuery
                                                                .viewInsetsOf(
                                                                    context),
                                                            child:
                                                                ImageViewWidget(
                                                              indexCurrent: 4,
                                                              alllistImage: widget
                                                                  .messageDoc!
                                                                  .listImages,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ).then((value) =>
                                                        safeSetState(() {}));
                                                  },
                                                  child: Hero(
                                                    tag: widget
                                                        .messageDoc!.listImages
                                                        .elementAtOrNull(4)!,
                                                    transitionOnUserGestures:
                                                        true,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(),
                                                      child: CachedNetworkImage(
                                                        fadeInDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        fadeOutDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        imageUrl: widget
                                                            .messageDoc!
                                                            .listImages
                                                            .elementAtOrNull(
                                                                4)!,
                                                        width: double.infinity,
                                                        height: 120.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ].divide(
                                                const SizedBox(width: 1.0)),
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Expanded(
                                                child: InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    await showModalBottomSheet(
                                                      isScrollControlled: true,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      context: context,
                                                      builder: (context) {
                                                        return WebViewAware(
                                                          child: Padding(
                                                            padding: MediaQuery
                                                                .viewInsetsOf(
                                                                    context),
                                                            child:
                                                                ImageViewWidget(
                                                              indexCurrent: 5,
                                                              alllistImage: widget
                                                                  .messageDoc!
                                                                  .listImages,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ).then((value) =>
                                                        safeSetState(() {}));
                                                  },
                                                  child: Hero(
                                                    tag: widget
                                                        .messageDoc!.listImages
                                                        .elementAtOrNull(5)!,
                                                    transitionOnUserGestures:
                                                        true,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(
                                                        bottomLeft:
                                                            Radius.circular(
                                                                7.0),
                                                      ),
                                                      child: CachedNetworkImage(
                                                        fadeInDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        fadeOutDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        imageUrl: widget
                                                            .messageDoc!
                                                            .listImages
                                                            .elementAtOrNull(
                                                                5)!,
                                                        width: double.infinity,
                                                        height: 120.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    await showModalBottomSheet(
                                                      isScrollControlled: true,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      context: context,
                                                      builder: (context) {
                                                        return WebViewAware(
                                                          child: Padding(
                                                            padding: MediaQuery
                                                                .viewInsetsOf(
                                                                    context),
                                                            child:
                                                                ImageViewWidget(
                                                              indexCurrent: 6,
                                                              alllistImage: widget
                                                                  .messageDoc!
                                                                  .listImages,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ).then((value) =>
                                                        safeSetState(() {}));
                                                  },
                                                  child: Hero(
                                                    tag: widget
                                                        .messageDoc!.listImages
                                                        .elementAtOrNull(6)!,
                                                    transitionOnUserGestures:
                                                        true,
                                                    child: CachedNetworkImage(
                                                      fadeInDuration:
                                                          const Duration(
                                                              milliseconds: 5),
                                                      fadeOutDuration:
                                                          const Duration(
                                                              milliseconds: 5),
                                                      imageUrl: widget
                                                          .messageDoc!
                                                          .listImages
                                                          .elementAtOrNull(6)!,
                                                      width: double.infinity,
                                                      height: 120.0,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    await showModalBottomSheet(
                                                      isScrollControlled: true,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      context: context,
                                                      builder: (context) {
                                                        return WebViewAware(
                                                          child: Padding(
                                                            padding: MediaQuery
                                                                .viewInsetsOf(
                                                                    context),
                                                            child:
                                                                ImageViewWidget(
                                                              indexCurrent: 7,
                                                              alllistImage: widget
                                                                  .messageDoc!
                                                                  .listImages,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ).then((value) =>
                                                        safeSetState(() {}));
                                                  },
                                                  child: Hero(
                                                    tag: widget.messageDoc!
                                                        .listImages.lastOrNull!,
                                                    transitionOnUserGestures:
                                                        true,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(
                                                        bottomRight:
                                                            Radius.circular(
                                                                17.0),
                                                      ),
                                                      child: CachedNetworkImage(
                                                        fadeInDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        fadeOutDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        imageUrl: widget
                                                            .messageDoc!
                                                            .listImages
                                                            .lastOrNull!,
                                                        width: double.infinity,
                                                        height: 120.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ].divide(
                                                const SizedBox(width: 1.0)),
                                          ),
                                        ].divide(const SizedBox(height: 1.0)),
                                      ),
                                    if (widget.messageDoc?.listImages.length ==
                                        9)
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Expanded(
                                                child: InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    await showModalBottomSheet(
                                                      isScrollControlled: true,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      context: context,
                                                      builder: (context) {
                                                        return WebViewAware(
                                                          child: Padding(
                                                            padding: MediaQuery
                                                                .viewInsetsOf(
                                                                    context),
                                                            child:
                                                                ImageViewWidget(
                                                              indexCurrent: 0,
                                                              alllistImage: widget
                                                                  .messageDoc!
                                                                  .listImages,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ).then((value) =>
                                                        safeSetState(() {}));
                                                  },
                                                  child: Hero(
                                                    tag: widget
                                                        .messageDoc!
                                                        .listImages
                                                        .firstOrNull!,
                                                    transitionOnUserGestures:
                                                        true,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(
                                                        topLeft:
                                                            Radius.circular(
                                                                17.0),
                                                      ),
                                                      child: CachedNetworkImage(
                                                        fadeInDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        fadeOutDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        imageUrl: widget
                                                            .messageDoc!
                                                            .listImages
                                                            .firstOrNull!,
                                                        width: double.infinity,
                                                        height: 120.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    await showModalBottomSheet(
                                                      isScrollControlled: true,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      context: context,
                                                      builder: (context) {
                                                        return WebViewAware(
                                                          child: Padding(
                                                            padding: MediaQuery
                                                                .viewInsetsOf(
                                                                    context),
                                                            child:
                                                                ImageViewWidget(
                                                              indexCurrent: 1,
                                                              alllistImage: widget
                                                                  .messageDoc!
                                                                  .listImages,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ).then((value) =>
                                                        safeSetState(() {}));
                                                  },
                                                  child: Hero(
                                                    tag: widget
                                                        .messageDoc!.listImages
                                                        .elementAtOrNull(1)!,
                                                    transitionOnUserGestures:
                                                        true,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(),
                                                      child: CachedNetworkImage(
                                                        fadeInDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        fadeOutDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        imageUrl: widget
                                                            .messageDoc!
                                                            .listImages
                                                            .elementAtOrNull(
                                                                1)!,
                                                        width: double.infinity,
                                                        height: 120.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    await showModalBottomSheet(
                                                      isScrollControlled: true,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      context: context,
                                                      builder: (context) {
                                                        return WebViewAware(
                                                          child: Padding(
                                                            padding: MediaQuery
                                                                .viewInsetsOf(
                                                                    context),
                                                            child:
                                                                ImageViewWidget(
                                                              indexCurrent: 2,
                                                              alllistImage: widget
                                                                  .messageDoc!
                                                                  .listImages,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ).then((value) =>
                                                        safeSetState(() {}));
                                                  },
                                                  child: Hero(
                                                    tag: widget
                                                        .messageDoc!.listImages
                                                        .elementAtOrNull(2)!,
                                                    transitionOnUserGestures:
                                                        true,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(
                                                        topRight:
                                                            Radius.circular(
                                                                17.0),
                                                      ),
                                                      child: CachedNetworkImage(
                                                        fadeInDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        fadeOutDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        imageUrl: widget
                                                            .messageDoc!
                                                            .listImages
                                                            .elementAtOrNull(
                                                                2)!,
                                                        width: double.infinity,
                                                        height: 120.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ].divide(
                                                const SizedBox(width: 1.0)),
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Expanded(
                                                child: InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    await showModalBottomSheet(
                                                      isScrollControlled: true,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      context: context,
                                                      builder: (context) {
                                                        return WebViewAware(
                                                          child: Padding(
                                                            padding: MediaQuery
                                                                .viewInsetsOf(
                                                                    context),
                                                            child:
                                                                ImageViewWidget(
                                                              indexCurrent: 3,
                                                              alllistImage: widget
                                                                  .messageDoc!
                                                                  .listImages,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ).then((value) =>
                                                        safeSetState(() {}));
                                                  },
                                                  child: Hero(
                                                    tag: widget
                                                        .messageDoc!.listImages
                                                        .elementAtOrNull(3)!,
                                                    transitionOnUserGestures:
                                                        true,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(),
                                                      child: CachedNetworkImage(
                                                        fadeInDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        fadeOutDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        imageUrl: widget
                                                            .messageDoc!
                                                            .listImages
                                                            .elementAtOrNull(
                                                                3)!,
                                                        width: double.infinity,
                                                        height: 120.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    await showModalBottomSheet(
                                                      isScrollControlled: true,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      context: context,
                                                      builder: (context) {
                                                        return WebViewAware(
                                                          child: Padding(
                                                            padding: MediaQuery
                                                                .viewInsetsOf(
                                                                    context),
                                                            child:
                                                                ImageViewWidget(
                                                              indexCurrent: 4,
                                                              alllistImage: widget
                                                                  .messageDoc!
                                                                  .listImages,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ).then((value) =>
                                                        safeSetState(() {}));
                                                  },
                                                  child: Hero(
                                                    tag: widget
                                                        .messageDoc!.listImages
                                                        .elementAtOrNull(4)!,
                                                    transitionOnUserGestures:
                                                        true,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(),
                                                      child: CachedNetworkImage(
                                                        fadeInDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        fadeOutDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        imageUrl: widget
                                                            .messageDoc!
                                                            .listImages
                                                            .elementAtOrNull(
                                                                4)!,
                                                        width: double.infinity,
                                                        height: 120.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    await showModalBottomSheet(
                                                      isScrollControlled: true,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      context: context,
                                                      builder: (context) {
                                                        return WebViewAware(
                                                          child: Padding(
                                                            padding: MediaQuery
                                                                .viewInsetsOf(
                                                                    context),
                                                            child:
                                                                ImageViewWidget(
                                                              indexCurrent: 5,
                                                              alllistImage: widget
                                                                  .messageDoc!
                                                                  .listImages,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ).then((value) =>
                                                        safeSetState(() {}));
                                                  },
                                                  child: Hero(
                                                    tag: widget
                                                        .messageDoc!.listImages
                                                        .elementAtOrNull(5)!,
                                                    transitionOnUserGestures:
                                                        true,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(),
                                                      child: CachedNetworkImage(
                                                        fadeInDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        fadeOutDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        imageUrl: widget
                                                            .messageDoc!
                                                            .listImages
                                                            .elementAtOrNull(
                                                                5)!,
                                                        width: double.infinity,
                                                        height: 120.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ].divide(
                                                const SizedBox(width: 1.0)),
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Expanded(
                                                child: InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    await showModalBottomSheet(
                                                      isScrollControlled: true,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      context: context,
                                                      builder: (context) {
                                                        return WebViewAware(
                                                          child: Padding(
                                                            padding: MediaQuery
                                                                .viewInsetsOf(
                                                                    context),
                                                            child:
                                                                ImageViewWidget(
                                                              indexCurrent: 6,
                                                              alllistImage: widget
                                                                  .messageDoc!
                                                                  .listImages,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ).then((value) =>
                                                        safeSetState(() {}));
                                                  },
                                                  child: Hero(
                                                    tag: widget
                                                        .messageDoc!.listImages
                                                        .elementAtOrNull(6)!,
                                                    transitionOnUserGestures:
                                                        true,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(
                                                        bottomLeft:
                                                            Radius.circular(
                                                                7.0),
                                                      ),
                                                      child: CachedNetworkImage(
                                                        fadeInDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        fadeOutDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        imageUrl: widget
                                                            .messageDoc!
                                                            .listImages
                                                            .elementAtOrNull(
                                                                6)!,
                                                        width: double.infinity,
                                                        height: 120.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    await showModalBottomSheet(
                                                      isScrollControlled: true,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      context: context,
                                                      builder: (context) {
                                                        return WebViewAware(
                                                          child: Padding(
                                                            padding: MediaQuery
                                                                .viewInsetsOf(
                                                                    context),
                                                            child:
                                                                ImageViewWidget(
                                                              indexCurrent: 7,
                                                              alllistImage: widget
                                                                  .messageDoc!
                                                                  .listImages,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ).then((value) =>
                                                        safeSetState(() {}));
                                                  },
                                                  child: Hero(
                                                    tag: widget
                                                        .messageDoc!.listImages
                                                        .elementAtOrNull(7)!,
                                                    transitionOnUserGestures:
                                                        true,
                                                    child: CachedNetworkImage(
                                                      fadeInDuration:
                                                          const Duration(
                                                              milliseconds: 5),
                                                      fadeOutDuration:
                                                          const Duration(
                                                              milliseconds: 5),
                                                      imageUrl: widget
                                                          .messageDoc!
                                                          .listImages
                                                          .elementAtOrNull(7)!,
                                                      width: double.infinity,
                                                      height: 120.0,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    await showModalBottomSheet(
                                                      isScrollControlled: true,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      context: context,
                                                      builder: (context) {
                                                        return WebViewAware(
                                                          child: Padding(
                                                            padding: MediaQuery
                                                                .viewInsetsOf(
                                                                    context),
                                                            child:
                                                                ImageViewWidget(
                                                              indexCurrent: 8,
                                                              alllistImage: widget
                                                                  .messageDoc!
                                                                  .listImages,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ).then((value) =>
                                                        safeSetState(() {}));
                                                  },
                                                  child: Hero(
                                                    tag: widget.messageDoc!
                                                        .listImages.lastOrNull!,
                                                    transitionOnUserGestures:
                                                        true,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(
                                                        bottomRight:
                                                            Radius.circular(
                                                                17.0),
                                                      ),
                                                      child: CachedNetworkImage(
                                                        fadeInDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        fadeOutDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        imageUrl: widget
                                                            .messageDoc!
                                                            .listImages
                                                            .lastOrNull!,
                                                        width: double.infinity,
                                                        height: 120.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ].divide(
                                                const SizedBox(width: 1.0)),
                                          ),
                                        ].divide(const SizedBox(height: 1.0)),
                                      ),
                                    if (widget.messageDoc?.listImages.length ==
                                        10)
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Expanded(
                                                child: InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    await showModalBottomSheet(
                                                      isScrollControlled: true,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      context: context,
                                                      builder: (context) {
                                                        return WebViewAware(
                                                          child: Padding(
                                                            padding: MediaQuery
                                                                .viewInsetsOf(
                                                                    context),
                                                            child:
                                                                ImageViewWidget(
                                                              indexCurrent: 0,
                                                              alllistImage: widget
                                                                  .messageDoc!
                                                                  .listImages,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ).then((value) =>
                                                        safeSetState(() {}));
                                                  },
                                                  child: Hero(
                                                    tag: widget
                                                        .messageDoc!
                                                        .listImages
                                                        .firstOrNull!,
                                                    transitionOnUserGestures:
                                                        true,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(
                                                        topLeft:
                                                            Radius.circular(
                                                                17.0),
                                                      ),
                                                      child: CachedNetworkImage(
                                                        fadeInDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        fadeOutDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        imageUrl: widget
                                                            .messageDoc!
                                                            .listImages
                                                            .firstOrNull!,
                                                        width: double.infinity,
                                                        height: 120.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    await showModalBottomSheet(
                                                      isScrollControlled: true,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      context: context,
                                                      builder: (context) {
                                                        return WebViewAware(
                                                          child: Padding(
                                                            padding: MediaQuery
                                                                .viewInsetsOf(
                                                                    context),
                                                            child:
                                                                ImageViewWidget(
                                                              indexCurrent: 1,
                                                              alllistImage: widget
                                                                  .messageDoc!
                                                                  .listImages,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ).then((value) =>
                                                        safeSetState(() {}));
                                                  },
                                                  child: Hero(
                                                    tag: widget
                                                        .messageDoc!.listImages
                                                        .elementAtOrNull(1)!,
                                                    transitionOnUserGestures:
                                                        true,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(),
                                                      child: CachedNetworkImage(
                                                        fadeInDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        fadeOutDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        imageUrl: widget
                                                            .messageDoc!
                                                            .listImages
                                                            .elementAtOrNull(
                                                                1)!,
                                                        width: double.infinity,
                                                        height: 120.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    await showModalBottomSheet(
                                                      isScrollControlled: true,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      context: context,
                                                      builder: (context) {
                                                        return WebViewAware(
                                                          child: Padding(
                                                            padding: MediaQuery
                                                                .viewInsetsOf(
                                                                    context),
                                                            child:
                                                                ImageViewWidget(
                                                              indexCurrent: 2,
                                                              alllistImage: widget
                                                                  .messageDoc!
                                                                  .listImages,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ).then((value) =>
                                                        safeSetState(() {}));
                                                  },
                                                  child: Hero(
                                                    tag: widget
                                                        .messageDoc!.listImages
                                                        .elementAtOrNull(2)!,
                                                    transitionOnUserGestures:
                                                        true,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(
                                                        topRight:
                                                            Radius.circular(
                                                                17.0),
                                                      ),
                                                      child: CachedNetworkImage(
                                                        fadeInDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        fadeOutDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        imageUrl: widget
                                                            .messageDoc!
                                                            .listImages
                                                            .elementAtOrNull(
                                                                2)!,
                                                        width: double.infinity,
                                                        height: 120.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ].divide(
                                                const SizedBox(width: 1.0)),
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Expanded(
                                                child: InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    await showModalBottomSheet(
                                                      isScrollControlled: true,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      context: context,
                                                      builder: (context) {
                                                        return WebViewAware(
                                                          child: Padding(
                                                            padding: MediaQuery
                                                                .viewInsetsOf(
                                                                    context),
                                                            child:
                                                                ImageViewWidget(
                                                              indexCurrent: 3,
                                                              alllistImage: widget
                                                                  .messageDoc!
                                                                  .listImages,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ).then((value) =>
                                                        safeSetState(() {}));
                                                  },
                                                  child: Hero(
                                                    tag: widget
                                                        .messageDoc!.listImages
                                                        .elementAtOrNull(3)!,
                                                    transitionOnUserGestures:
                                                        true,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(),
                                                      child: CachedNetworkImage(
                                                        fadeInDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        fadeOutDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        imageUrl: widget
                                                            .messageDoc!
                                                            .listImages
                                                            .elementAtOrNull(
                                                                3)!,
                                                        width: double.infinity,
                                                        height: 120.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    await showModalBottomSheet(
                                                      isScrollControlled: true,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      context: context,
                                                      builder: (context) {
                                                        return WebViewAware(
                                                          child: Padding(
                                                            padding: MediaQuery
                                                                .viewInsetsOf(
                                                                    context),
                                                            child:
                                                                ImageViewWidget(
                                                              indexCurrent: 4,
                                                              alllistImage: widget
                                                                  .messageDoc!
                                                                  .listImages,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ).then((value) =>
                                                        safeSetState(() {}));
                                                  },
                                                  child: Hero(
                                                    tag: widget
                                                        .messageDoc!.listImages
                                                        .elementAtOrNull(4)!,
                                                    transitionOnUserGestures:
                                                        true,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(),
                                                      child: CachedNetworkImage(
                                                        fadeInDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        fadeOutDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        imageUrl: widget
                                                            .messageDoc!
                                                            .listImages
                                                            .elementAtOrNull(
                                                                4)!,
                                                        width: double.infinity,
                                                        height: 120.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    await showModalBottomSheet(
                                                      isScrollControlled: true,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      context: context,
                                                      builder: (context) {
                                                        return WebViewAware(
                                                          child: Padding(
                                                            padding: MediaQuery
                                                                .viewInsetsOf(
                                                                    context),
                                                            child:
                                                                ImageViewWidget(
                                                              indexCurrent: 5,
                                                              alllistImage: widget
                                                                  .messageDoc!
                                                                  .listImages,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ).then((value) =>
                                                        safeSetState(() {}));
                                                  },
                                                  child: Hero(
                                                    tag: widget
                                                        .messageDoc!.listImages
                                                        .elementAtOrNull(5)!,
                                                    transitionOnUserGestures:
                                                        true,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(),
                                                      child: CachedNetworkImage(
                                                        fadeInDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        fadeOutDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        imageUrl: widget
                                                            .messageDoc!
                                                            .listImages
                                                            .elementAtOrNull(
                                                                5)!,
                                                        width: double.infinity,
                                                        height: 120.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    await showModalBottomSheet(
                                                      isScrollControlled: true,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      context: context,
                                                      builder: (context) {
                                                        return WebViewAware(
                                                          child: Padding(
                                                            padding: MediaQuery
                                                                .viewInsetsOf(
                                                                    context),
                                                            child:
                                                                ImageViewWidget(
                                                              indexCurrent: 6,
                                                              alllistImage: widget
                                                                  .messageDoc!
                                                                  .listImages,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ).then((value) =>
                                                        safeSetState(() {}));
                                                  },
                                                  child: Hero(
                                                    tag: widget
                                                        .messageDoc!.listImages
                                                        .elementAtOrNull(6)!,
                                                    transitionOnUserGestures:
                                                        true,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(),
                                                      child: CachedNetworkImage(
                                                        fadeInDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        fadeOutDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        imageUrl: widget
                                                            .messageDoc!
                                                            .listImages
                                                            .elementAtOrNull(
                                                                6)!,
                                                        width: double.infinity,
                                                        height: 120.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ].divide(
                                                const SizedBox(width: 1.0)),
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Expanded(
                                                child: InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    await showModalBottomSheet(
                                                      isScrollControlled: true,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      context: context,
                                                      builder: (context) {
                                                        return WebViewAware(
                                                          child: Padding(
                                                            padding: MediaQuery
                                                                .viewInsetsOf(
                                                                    context),
                                                            child:
                                                                ImageViewWidget(
                                                              indexCurrent: 7,
                                                              alllistImage: widget
                                                                  .messageDoc!
                                                                  .listImages,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ).then((value) =>
                                                        safeSetState(() {}));
                                                  },
                                                  child: Hero(
                                                    tag: widget
                                                        .messageDoc!.listImages
                                                        .elementAtOrNull(7)!,
                                                    transitionOnUserGestures:
                                                        true,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(
                                                        bottomLeft:
                                                            Radius.circular(
                                                                7.0),
                                                      ),
                                                      child: CachedNetworkImage(
                                                        fadeInDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        fadeOutDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        imageUrl: widget
                                                            .messageDoc!
                                                            .listImages
                                                            .elementAtOrNull(
                                                                7)!,
                                                        width: double.infinity,
                                                        height: 120.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    await showModalBottomSheet(
                                                      isScrollControlled: true,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      context: context,
                                                      builder: (context) {
                                                        return WebViewAware(
                                                          child: Padding(
                                                            padding: MediaQuery
                                                                .viewInsetsOf(
                                                                    context),
                                                            child:
                                                                ImageViewWidget(
                                                              indexCurrent: 8,
                                                              alllistImage: widget
                                                                  .messageDoc!
                                                                  .listImages,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ).then((value) =>
                                                        safeSetState(() {}));
                                                  },
                                                  child: Hero(
                                                    tag: widget
                                                        .messageDoc!.listImages
                                                        .elementAtOrNull(8)!,
                                                    transitionOnUserGestures:
                                                        true,
                                                    child: CachedNetworkImage(
                                                      fadeInDuration:
                                                          const Duration(
                                                              milliseconds: 5),
                                                      fadeOutDuration:
                                                          const Duration(
                                                              milliseconds: 5),
                                                      imageUrl: widget
                                                          .messageDoc!
                                                          .listImages
                                                          .elementAtOrNull(8)!,
                                                      width: double.infinity,
                                                      height: 120.0,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    await showModalBottomSheet(
                                                      isScrollControlled: true,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      context: context,
                                                      builder: (context) {
                                                        return WebViewAware(
                                                          child: Padding(
                                                            padding: MediaQuery
                                                                .viewInsetsOf(
                                                                    context),
                                                            child:
                                                                ImageViewWidget(
                                                              indexCurrent: 9,
                                                              alllistImage: widget
                                                                  .messageDoc!
                                                                  .listImages,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ).then((value) =>
                                                        safeSetState(() {}));
                                                  },
                                                  child: Hero(
                                                    tag: widget.messageDoc!
                                                        .listImages.lastOrNull!,
                                                    transitionOnUserGestures:
                                                        true,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(
                                                        bottomRight:
                                                            Radius.circular(
                                                                17.0),
                                                      ),
                                                      child: CachedNetworkImage(
                                                        fadeInDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        fadeOutDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    5),
                                                        imageUrl: widget
                                                            .messageDoc!
                                                            .listImages
                                                            .lastOrNull!,
                                                        width: double.infinity,
                                                        height: 120.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ].divide(
                                                const SizedBox(width: 1.0)),
                                          ),
                                        ].divide(const SizedBox(height: 1.0)),
                                      ),
                                    if (widget.messageDoc?.text == null ||
                                        widget.messageDoc?.text == '')
                                      Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(0.0, 0.0, 5.0, 5.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: const Color(0xB3000000),
                                            borderRadius:
                                                BorderRadius.circular(24.0),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsetsDirectional
                                                .fromSTEB(6.0, 5.0, 6.0, 6.0),
                                            child: Text(
                                              dateTimeFormat(
                                                "Hm",
                                                widget.messageDoc!.dateCreated!,
                                                locale: FFLocalizations.of(
                                                            context)
                                                        .languageShortCode ??
                                                    FFLocalizations.of(context)
                                                        .languageCode,
                                              ),
                                              textAlign: TextAlign.center,
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyMedium
                                                  .override(
                                                    font: GoogleFonts.inter(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .fontStyle,
                                                    ),
                                                    color:
                                                        const Color(0xFFF6F6F6),
                                                    fontSize: 12.0,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.w500,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                    lineHeight: 1.2,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            if ((widget.messageDoc?.text != null &&
                                    widget.messageDoc?.text != '') &&
                                !(widget.messageDoc!.listImages.isNotEmpty))
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    16.0, 9.0, 7.0, 4.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Flexible(
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(0.0, 0.0, 0.0, 5.0),
                                        child: Text(
                                          widget.messageDoc!.text,
                                          textAlign: TextAlign.start,
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                                fontSize: 15.0,
                                                letterSpacing: 0.0,
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(7.0, 0.0, 0.0, 0.0),
                                          child: Text(
                                            dateTimeFormat(
                                              "Hm",
                                              widget.messageDoc!.dateCreated!,
                                              locale: FFLocalizations.of(
                                                          context)
                                                      .languageShortCode ??
                                                  FFLocalizations.of(context)
                                                      .languageCode,
                                            ),
                                            textAlign: TextAlign.end,
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  font: GoogleFonts.inter(
                                                    fontWeight: FontWeight.w500,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                                  color:
                                                      const Color(0xFF909595),
                                                  fontSize: 12.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w500,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            if ((widget.messageDoc?.text != null &&
                                    widget.messageDoc?.text != '') &&
                                (widget.messageDoc!.listImages.isNotEmpty))
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    16.0, 9.0, 7.0, 4.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Flexible(
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(0.0, 0.0, 0.0, 5.0),
                                        child: Text(
                                          widget.messageDoc!.text,
                                          textAlign: TextAlign.start,
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                                fontSize: 15.0,
                                                letterSpacing: 0.0,
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              7.0, 0.0, 0.0, 0.0),
                                      child: Text(
                                        dateTimeFormat(
                                          "Hm",
                                          widget.messageDoc!.dateCreated!,
                                          locale: FFLocalizations.of(context)
                                                  .languageShortCode ??
                                              FFLocalizations.of(context)
                                                  .languageCode,
                                        ),
                                        textAlign: TextAlign.end,
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.inter(
                                                fontWeight: FontWeight.w500,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              color: const Color(0xFF909595),
                                              fontSize: 12.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w500,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        if (widget.messageDoc?.sender == currentUserReference)
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(30.0, 0.0, 10.0, 0.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: const AlignmentDirectional(1.0, 0.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).tertiary,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(18.0),
                        topRight: Radius.circular(18.0),
                        bottomLeft: Radius.circular(18.0),
                        bottomRight: Radius.circular(8.0),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.messageDoc?.listImages != null &&
                            (widget.messageDoc?.listImages)!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: Stack(
                              alignment: const AlignmentDirectional(1.0, 1.0),
                              children: [
                                if (widget.messageDoc?.listImages.length == 1)
                                  InkWell(
                                    splashColor: Colors.transparent,
                                    focusColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () async {
                                      await showModalBottomSheet(
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        context: context,
                                        builder: (context) {
                                          return WebViewAware(
                                            child: Padding(
                                              padding: MediaQuery.viewInsetsOf(
                                                  context),
                                              child: ImageViewWidget(
                                                indexCurrent: 0,
                                                alllistImage: widget
                                                    .messageDoc!.listImages,
                                              ),
                                            ),
                                          );
                                        },
                                      ).then((value) => safeSetState(() {}));
                                    },
                                    child: Hero(
                                      tag: widget
                                          .messageDoc!.listImages.firstOrNull!,
                                      transitionOnUserGestures: true,
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(18.0),
                                          topRight: Radius.circular(18.0),
                                          bottomLeft: Radius.circular(18.0),
                                          bottomRight: Radius.circular(8.0),
                                        ),
                                        child: CachedNetworkImage(
                                          fadeInDuration:
                                              const Duration(milliseconds: 5),
                                          fadeOutDuration:
                                              const Duration(milliseconds: 5),
                                          imageUrl: widget.messageDoc!
                                              .listImages.firstOrNull!,
                                          width: double.infinity,
                                          height: 300.0,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                if (widget.messageDoc?.listImages.length == 2)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        child: InkWell(
                                          splashColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () async {
                                            await showModalBottomSheet(
                                              isScrollControlled: true,
                                              backgroundColor:
                                                  Colors.transparent,
                                              context: context,
                                              builder: (context) {
                                                return WebViewAware(
                                                  child: Padding(
                                                    padding:
                                                        MediaQuery.viewInsetsOf(
                                                            context),
                                                    child: ImageViewWidget(
                                                      indexCurrent: 0,
                                                      alllistImage: widget
                                                          .messageDoc!
                                                          .listImages,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ).then(
                                                (value) => safeSetState(() {}));
                                          },
                                          child: Hero(
                                            tag: widget.messageDoc!.listImages
                                                .firstOrNull!,
                                            transitionOnUserGestures: true,
                                            child: ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topLeft: Radius.circular(18.0),
                                                bottomLeft:
                                                    Radius.circular(18.0),
                                              ),
                                              child: CachedNetworkImage(
                                                fadeInDuration: const Duration(
                                                    milliseconds: 5),
                                                fadeOutDuration: const Duration(
                                                    milliseconds: 5),
                                                imageUrl: widget.messageDoc!
                                                    .listImages.firstOrNull!,
                                                width: double.infinity,
                                                height: 170.0,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        child: InkWell(
                                          splashColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () async {
                                            await showModalBottomSheet(
                                              isScrollControlled: true,
                                              backgroundColor:
                                                  Colors.transparent,
                                              context: context,
                                              builder: (context) {
                                                return WebViewAware(
                                                  child: Padding(
                                                    padding:
                                                        MediaQuery.viewInsetsOf(
                                                            context),
                                                    child: ImageViewWidget(
                                                      indexCurrent: 1,
                                                      alllistImage: widget
                                                          .messageDoc!
                                                          .listImages,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ).then(
                                                (value) => safeSetState(() {}));
                                          },
                                          child: Hero(
                                            tag: widget.messageDoc!.listImages
                                                .lastOrNull!,
                                            transitionOnUserGestures: true,
                                            child: ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topRight: Radius.circular(18.0),
                                                bottomRight:
                                                    Radius.circular(8.0),
                                              ),
                                              child: CachedNetworkImage(
                                                fadeInDuration: const Duration(
                                                    milliseconds: 5),
                                                fadeOutDuration: const Duration(
                                                    milliseconds: 5),
                                                imageUrl: widget.messageDoc!
                                                    .listImages.lastOrNull!,
                                                width: double.infinity,
                                                height: 170.0,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ].divide(const SizedBox(width: 1.0)),
                                  ),
                                if (widget.messageDoc?.listImages.length == 3)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      InkWell(
                                        splashColor: Colors.transparent,
                                        focusColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () async {
                                          await showModalBottomSheet(
                                            isScrollControlled: true,
                                            backgroundColor: Colors.transparent,
                                            context: context,
                                            builder: (context) {
                                              return WebViewAware(
                                                child: Padding(
                                                  padding:
                                                      MediaQuery.viewInsetsOf(
                                                          context),
                                                  child: ImageViewWidget(
                                                    indexCurrent: 0,
                                                    alllistImage: widget
                                                        .messageDoc!.listImages,
                                                  ),
                                                ),
                                              );
                                            },
                                          ).then(
                                              (value) => safeSetState(() {}));
                                        },
                                        child: Hero(
                                          tag: widget.messageDoc!.listImages
                                              .firstOrNull!,
                                          transitionOnUserGestures: true,
                                          child: ClipRRect(
                                            borderRadius:
                                                const BorderRadius.only(
                                              topLeft: Radius.circular(18.0),
                                              bottomLeft: Radius.circular(18.0),
                                            ),
                                            child: CachedNetworkImage(
                                              fadeInDuration: const Duration(
                                                  milliseconds: 5),
                                              fadeOutDuration: const Duration(
                                                  milliseconds: 5),
                                              imageUrl: widget.messageDoc!
                                                  .listImages.firstOrNull!,
                                              width: 260.0,
                                              height: 300.0,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                await showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  context: context,
                                                  builder: (context) {
                                                    return WebViewAware(
                                                      child: Padding(
                                                        padding: MediaQuery
                                                            .viewInsetsOf(
                                                                context),
                                                        child: ImageViewWidget(
                                                          indexCurrent: 1,
                                                          alllistImage: widget
                                                              .messageDoc!
                                                              .listImages,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ).then((value) =>
                                                    safeSetState(() {}));
                                              },
                                              child: Hero(
                                                tag: widget
                                                    .messageDoc!.listImages
                                                    .elementAtOrNull(1)!,
                                                transitionOnUserGestures: true,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    topRight:
                                                        Radius.circular(18.0),
                                                  ),
                                                  child: CachedNetworkImage(
                                                    fadeInDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    fadeOutDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    imageUrl: widget
                                                        .messageDoc!.listImages
                                                        .elementAtOrNull(1)!,
                                                    width: double.infinity,
                                                    height: 150.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                await showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  context: context,
                                                  builder: (context) {
                                                    return WebViewAware(
                                                      child: Padding(
                                                        padding: MediaQuery
                                                            .viewInsetsOf(
                                                                context),
                                                        child: ImageViewWidget(
                                                          indexCurrent: 2,
                                                          alllistImage: widget
                                                              .messageDoc!
                                                              .listImages,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ).then((value) =>
                                                    safeSetState(() {}));
                                              },
                                              child: Hero(
                                                tag: widget.messageDoc!
                                                    .listImages.lastOrNull!,
                                                transitionOnUserGestures: true,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    bottomRight:
                                                        Radius.circular(8.0),
                                                  ),
                                                  child: CachedNetworkImage(
                                                    fadeInDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    fadeOutDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    imageUrl: widget.messageDoc!
                                                        .listImages.lastOrNull!,
                                                    width: double.infinity,
                                                    height: 150.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ].divide(const SizedBox(height: 1.0)),
                                        ),
                                      ),
                                    ].divide(const SizedBox(width: 1.0)),
                                  ),
                                if (widget.messageDoc?.listImages.length == 4)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      InkWell(
                                        splashColor: Colors.transparent,
                                        focusColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () async {
                                          await showModalBottomSheet(
                                            isScrollControlled: true,
                                            backgroundColor: Colors.transparent,
                                            context: context,
                                            builder: (context) {
                                              return WebViewAware(
                                                child: Padding(
                                                  padding:
                                                      MediaQuery.viewInsetsOf(
                                                          context),
                                                  child: ImageViewWidget(
                                                    indexCurrent: 0,
                                                    alllistImage: widget
                                                        .messageDoc!.listImages,
                                                  ),
                                                ),
                                              );
                                            },
                                          ).then(
                                              (value) => safeSetState(() {}));
                                        },
                                        child: Hero(
                                          tag: widget.messageDoc!.listImages
                                              .firstOrNull!,
                                          transitionOnUserGestures: true,
                                          child: ClipRRect(
                                            borderRadius:
                                                const BorderRadius.only(
                                              topLeft: Radius.circular(18.0),
                                              bottomLeft: Radius.circular(8.0),
                                            ),
                                            child: CachedNetworkImage(
                                              fadeInDuration: const Duration(
                                                  milliseconds: 5),
                                              fadeOutDuration: const Duration(
                                                  milliseconds: 5),
                                              imageUrl: widget.messageDoc!
                                                  .listImages.firstOrNull!,
                                              width: 260.0,
                                              height: 300.0,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                await showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  context: context,
                                                  builder: (context) {
                                                    return WebViewAware(
                                                      child: Padding(
                                                        padding: MediaQuery
                                                            .viewInsetsOf(
                                                                context),
                                                        child: ImageViewWidget(
                                                          indexCurrent: 1,
                                                          alllistImage: widget
                                                              .messageDoc!
                                                              .listImages,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ).then((value) =>
                                                    safeSetState(() {}));
                                              },
                                              child: Hero(
                                                tag: widget
                                                    .messageDoc!.listImages
                                                    .elementAtOrNull(1)!,
                                                transitionOnUserGestures: true,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    topRight:
                                                        Radius.circular(18.0),
                                                  ),
                                                  child: CachedNetworkImage(
                                                    fadeInDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    fadeOutDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    imageUrl: widget
                                                        .messageDoc!.listImages
                                                        .elementAtOrNull(1)!,
                                                    width: double.infinity,
                                                    height: 100.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                await showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  context: context,
                                                  builder: (context) {
                                                    return WebViewAware(
                                                      child: Padding(
                                                        padding: MediaQuery
                                                            .viewInsetsOf(
                                                                context),
                                                        child: ImageViewWidget(
                                                          indexCurrent: 2,
                                                          alllistImage: widget
                                                              .messageDoc!
                                                              .listImages,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ).then((value) =>
                                                    safeSetState(() {}));
                                              },
                                              child: Hero(
                                                tag: widget
                                                    .messageDoc!.listImages
                                                    .elementAtOrNull(2)!,
                                                transitionOnUserGestures: true,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.only(),
                                                  child: CachedNetworkImage(
                                                    fadeInDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    fadeOutDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    imageUrl: widget
                                                        .messageDoc!.listImages
                                                        .elementAtOrNull(2)!,
                                                    width: double.infinity,
                                                    height: 100.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                await showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  context: context,
                                                  builder: (context) {
                                                    return WebViewAware(
                                                      child: Padding(
                                                        padding: MediaQuery
                                                            .viewInsetsOf(
                                                                context),
                                                        child: ImageViewWidget(
                                                          indexCurrent: 3,
                                                          alllistImage: widget
                                                              .messageDoc!
                                                              .listImages,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ).then((value) =>
                                                    safeSetState(() {}));
                                              },
                                              child: Hero(
                                                tag: widget.messageDoc!
                                                    .listImages.lastOrNull!,
                                                transitionOnUserGestures: true,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    bottomRight:
                                                        Radius.circular(8.0),
                                                  ),
                                                  child: CachedNetworkImage(
                                                    fadeInDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    fadeOutDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    imageUrl: widget.messageDoc!
                                                        .listImages.lastOrNull!,
                                                    width: double.infinity,
                                                    height: 100.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ].divide(const SizedBox(height: 1.0)),
                                        ),
                                      ),
                                    ].divide(const SizedBox(width: 1.0)),
                                  ),
                                if (widget.messageDoc?.listImages.length == 5)
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Expanded(
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                await showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  context: context,
                                                  builder: (context) {
                                                    return WebViewAware(
                                                      child: Padding(
                                                        padding: MediaQuery
                                                            .viewInsetsOf(
                                                                context),
                                                        child: ImageViewWidget(
                                                          indexCurrent: 0,
                                                          alllistImage: widget
                                                              .messageDoc!
                                                              .listImages,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ).then((value) =>
                                                    safeSetState(() {}));
                                              },
                                              child: Hero(
                                                tag: widget.messageDoc!
                                                    .listImages.firstOrNull!,
                                                transitionOnUserGestures: true,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(18.0),
                                                  ),
                                                  child: CachedNetworkImage(
                                                    fadeInDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    fadeOutDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    imageUrl: widget
                                                        .messageDoc!
                                                        .listImages
                                                        .firstOrNull!,
                                                    width: double.infinity,
                                                    height: 170.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                await showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  context: context,
                                                  builder: (context) {
                                                    return WebViewAware(
                                                      child: Padding(
                                                        padding: MediaQuery
                                                            .viewInsetsOf(
                                                                context),
                                                        child: ImageViewWidget(
                                                          indexCurrent: 1,
                                                          alllistImage: widget
                                                              .messageDoc!
                                                              .listImages,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ).then((value) =>
                                                    safeSetState(() {}));
                                              },
                                              child: Hero(
                                                tag: widget
                                                    .messageDoc!.listImages
                                                    .elementAtOrNull(1)!,
                                                transitionOnUserGestures: true,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    topRight:
                                                        Radius.circular(18.0),
                                                  ),
                                                  child: CachedNetworkImage(
                                                    fadeInDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    fadeOutDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    imageUrl: widget
                                                        .messageDoc!.listImages
                                                        .elementAtOrNull(1)!,
                                                    width: double.infinity,
                                                    height: 170.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ].divide(const SizedBox(width: 1.0)),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Expanded(
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                await showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  context: context,
                                                  builder: (context) {
                                                    return WebViewAware(
                                                      child: Padding(
                                                        padding: MediaQuery
                                                            .viewInsetsOf(
                                                                context),
                                                        child: ImageViewWidget(
                                                          indexCurrent: 2,
                                                          alllistImage: widget
                                                              .messageDoc!
                                                              .listImages,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ).then((value) =>
                                                    safeSetState(() {}));
                                              },
                                              child: Hero(
                                                tag: widget
                                                    .messageDoc!.listImages
                                                    .elementAtOrNull(2)!,
                                                transitionOnUserGestures: true,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(18.0),
                                                  ),
                                                  child: CachedNetworkImage(
                                                    fadeInDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    fadeOutDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    imageUrl: widget
                                                        .messageDoc!.listImages
                                                        .elementAtOrNull(2)!,
                                                    width: double.infinity,
                                                    height: 127.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                await showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  context: context,
                                                  builder: (context) {
                                                    return WebViewAware(
                                                      child: Padding(
                                                        padding: MediaQuery
                                                            .viewInsetsOf(
                                                                context),
                                                        child: ImageViewWidget(
                                                          indexCurrent: 3,
                                                          alllistImage: widget
                                                              .messageDoc!
                                                              .listImages,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ).then((value) =>
                                                    safeSetState(() {}));
                                              },
                                              child: Hero(
                                                tag: widget
                                                    .messageDoc!.listImages
                                                    .elementAtOrNull(3)!,
                                                transitionOnUserGestures: true,
                                                child: CachedNetworkImage(
                                                  fadeInDuration:
                                                      const Duration(
                                                          milliseconds: 5),
                                                  fadeOutDuration:
                                                      const Duration(
                                                          milliseconds: 5),
                                                  imageUrl: widget
                                                      .messageDoc!.listImages
                                                      .elementAtOrNull(3)!,
                                                  width: double.infinity,
                                                  height: 127.0,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                await showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  context: context,
                                                  builder: (context) {
                                                    return WebViewAware(
                                                      child: Padding(
                                                        padding: MediaQuery
                                                            .viewInsetsOf(
                                                                context),
                                                        child: ImageViewWidget(
                                                          indexCurrent: 4,
                                                          alllistImage: widget
                                                              .messageDoc!
                                                              .listImages,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ).then((value) =>
                                                    safeSetState(() {}));
                                              },
                                              child: Hero(
                                                tag: widget.messageDoc!
                                                    .listImages.lastOrNull!,
                                                transitionOnUserGestures: true,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    bottomRight:
                                                        Radius.circular(8.0),
                                                  ),
                                                  child: CachedNetworkImage(
                                                    fadeInDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    fadeOutDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    imageUrl: widget.messageDoc!
                                                        .listImages.lastOrNull!,
                                                    width: double.infinity,
                                                    height: 127.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ].divide(const SizedBox(width: 1.0)),
                                      ),
                                    ].divide(const SizedBox(height: 1.0)),
                                  ),
                                if (widget.messageDoc?.listImages.length == 6)
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Expanded(
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                await showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  context: context,
                                                  builder: (context) {
                                                    return WebViewAware(
                                                      child: Padding(
                                                        padding: MediaQuery
                                                            .viewInsetsOf(
                                                                context),
                                                        child: ImageViewWidget(
                                                          indexCurrent: 0,
                                                          alllistImage: widget
                                                              .messageDoc!
                                                              .listImages,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ).then((value) =>
                                                    safeSetState(() {}));
                                              },
                                              child: Hero(
                                                tag: widget.messageDoc!
                                                    .listImages.firstOrNull!,
                                                transitionOnUserGestures: true,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(18.0),
                                                  ),
                                                  child: CachedNetworkImage(
                                                    fadeInDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    fadeOutDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    imageUrl: widget
                                                        .messageDoc!
                                                        .listImages
                                                        .firstOrNull!,
                                                    width: double.infinity,
                                                    height: 120.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                await showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  context: context,
                                                  builder: (context) {
                                                    return WebViewAware(
                                                      child: Padding(
                                                        padding: MediaQuery
                                                            .viewInsetsOf(
                                                                context),
                                                        child: ImageViewWidget(
                                                          indexCurrent: 1,
                                                          alllistImage: widget
                                                              .messageDoc!
                                                              .listImages,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ).then((value) =>
                                                    safeSetState(() {}));
                                              },
                                              child: Hero(
                                                tag: widget
                                                    .messageDoc!.listImages
                                                    .elementAtOrNull(1)!,
                                                transitionOnUserGestures: true,
                                                child: CachedNetworkImage(
                                                  fadeInDuration:
                                                      const Duration(
                                                          milliseconds: 5),
                                                  fadeOutDuration:
                                                      const Duration(
                                                          milliseconds: 5),
                                                  imageUrl: widget
                                                      .messageDoc!.listImages
                                                      .elementAtOrNull(1)!,
                                                  width: double.infinity,
                                                  height: 120.0,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                await showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  context: context,
                                                  builder: (context) {
                                                    return WebViewAware(
                                                      child: Padding(
                                                        padding: MediaQuery
                                                            .viewInsetsOf(
                                                                context),
                                                        child: ImageViewWidget(
                                                          indexCurrent: 2,
                                                          alllistImage: widget
                                                              .messageDoc!
                                                              .listImages,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ).then((value) =>
                                                    safeSetState(() {}));
                                              },
                                              child: Hero(
                                                tag: widget
                                                    .messageDoc!.listImages
                                                    .elementAtOrNull(2)!,
                                                transitionOnUserGestures: true,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    topRight:
                                                        Radius.circular(18.0),
                                                  ),
                                                  child: CachedNetworkImage(
                                                    fadeInDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    fadeOutDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    imageUrl: widget
                                                        .messageDoc!.listImages
                                                        .elementAtOrNull(2)!,
                                                    width: double.infinity,
                                                    height: 120.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ].divide(const SizedBox(width: 1.0)),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Expanded(
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                await showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  context: context,
                                                  builder: (context) {
                                                    return WebViewAware(
                                                      child: Padding(
                                                        padding: MediaQuery
                                                            .viewInsetsOf(
                                                                context),
                                                        child: ImageViewWidget(
                                                          indexCurrent: 3,
                                                          alllistImage: widget
                                                              .messageDoc!
                                                              .listImages,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ).then((value) =>
                                                    safeSetState(() {}));
                                              },
                                              child: Hero(
                                                tag: widget
                                                    .messageDoc!.listImages
                                                    .elementAtOrNull(3)!,
                                                transitionOnUserGestures: true,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(18.0),
                                                  ),
                                                  child: CachedNetworkImage(
                                                    fadeInDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    fadeOutDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    imageUrl: widget
                                                        .messageDoc!.listImages
                                                        .elementAtOrNull(3)!,
                                                    width: double.infinity,
                                                    height: 120.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                await showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  context: context,
                                                  builder: (context) {
                                                    return WebViewAware(
                                                      child: Padding(
                                                        padding: MediaQuery
                                                            .viewInsetsOf(
                                                                context),
                                                        child: ImageViewWidget(
                                                          indexCurrent: 4,
                                                          alllistImage: widget
                                                              .messageDoc!
                                                              .listImages,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ).then((value) =>
                                                    safeSetState(() {}));
                                              },
                                              child: Hero(
                                                tag: widget
                                                    .messageDoc!.listImages
                                                    .elementAtOrNull(4)!,
                                                transitionOnUserGestures: true,
                                                child: CachedNetworkImage(
                                                  fadeInDuration:
                                                      const Duration(
                                                          milliseconds: 5),
                                                  fadeOutDuration:
                                                      const Duration(
                                                          milliseconds: 5),
                                                  imageUrl: widget
                                                      .messageDoc!.listImages
                                                      .elementAtOrNull(4)!,
                                                  width: double.infinity,
                                                  height: 120.0,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                await showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  context: context,
                                                  builder: (context) {
                                                    return WebViewAware(
                                                      child: Padding(
                                                        padding: MediaQuery
                                                            .viewInsetsOf(
                                                                context),
                                                        child: ImageViewWidget(
                                                          indexCurrent: 5,
                                                          alllistImage: widget
                                                              .messageDoc!
                                                              .listImages,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ).then((value) =>
                                                    safeSetState(() {}));
                                              },
                                              child: Hero(
                                                tag: widget.messageDoc!
                                                    .listImages.lastOrNull!,
                                                transitionOnUserGestures: true,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    bottomRight:
                                                        Radius.circular(8.0),
                                                  ),
                                                  child: CachedNetworkImage(
                                                    fadeInDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    fadeOutDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    imageUrl: widget.messageDoc!
                                                        .listImages.lastOrNull!,
                                                    width: double.infinity,
                                                    height: 120.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ].divide(const SizedBox(width: 1.0)),
                                      ),
                                    ].divide(const SizedBox(height: 1.0)),
                                  ),
                                if (widget.messageDoc?.listImages.length == 7)
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Expanded(
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                await showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  context: context,
                                                  builder: (context) {
                                                    return WebViewAware(
                                                      child: Padding(
                                                        padding: MediaQuery
                                                            .viewInsetsOf(
                                                                context),
                                                        child: ImageViewWidget(
                                                          indexCurrent: 0,
                                                          alllistImage: widget
                                                              .messageDoc!
                                                              .listImages,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ).then((value) =>
                                                    safeSetState(() {}));
                                              },
                                              child: Hero(
                                                tag: widget.messageDoc!
                                                    .listImages.firstOrNull!,
                                                transitionOnUserGestures: true,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(18.0),
                                                  ),
                                                  child: CachedNetworkImage(
                                                    fadeInDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    fadeOutDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    imageUrl: widget
                                                        .messageDoc!
                                                        .listImages
                                                        .firstOrNull!,
                                                    width: double.infinity,
                                                    height: 170.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                await showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  context: context,
                                                  builder: (context) {
                                                    return WebViewAware(
                                                      child: Padding(
                                                        padding: MediaQuery
                                                            .viewInsetsOf(
                                                                context),
                                                        child: ImageViewWidget(
                                                          indexCurrent: 1,
                                                          alllistImage: widget
                                                              .messageDoc!
                                                              .listImages,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ).then((value) =>
                                                    safeSetState(() {}));
                                              },
                                              child: Hero(
                                                tag: widget
                                                    .messageDoc!.listImages
                                                    .elementAtOrNull(1)!,
                                                transitionOnUserGestures: true,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    topRight:
                                                        Radius.circular(18.0),
                                                  ),
                                                  child: CachedNetworkImage(
                                                    fadeInDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    fadeOutDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    imageUrl: widget
                                                        .messageDoc!.listImages
                                                        .elementAtOrNull(1)!,
                                                    width: double.infinity,
                                                    height: 170.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ].divide(const SizedBox(width: 1.0)),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Expanded(
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                await showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  context: context,
                                                  builder: (context) {
                                                    return WebViewAware(
                                                      child: Padding(
                                                        padding: MediaQuery
                                                            .viewInsetsOf(
                                                                context),
                                                        child: ImageViewWidget(
                                                          indexCurrent: 2,
                                                          alllistImage: widget
                                                              .messageDoc!
                                                              .listImages,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ).then((value) =>
                                                    safeSetState(() {}));
                                              },
                                              child: Hero(
                                                tag: widget
                                                    .messageDoc!.listImages
                                                    .elementAtOrNull(2)!,
                                                transitionOnUserGestures: true,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.only(),
                                                  child: CachedNetworkImage(
                                                    fadeInDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    fadeOutDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    imageUrl: widget
                                                        .messageDoc!.listImages
                                                        .elementAtOrNull(2)!,
                                                    width: double.infinity,
                                                    height: 170.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                await showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  context: context,
                                                  builder: (context) {
                                                    return WebViewAware(
                                                      child: Padding(
                                                        padding: MediaQuery
                                                            .viewInsetsOf(
                                                                context),
                                                        child: ImageViewWidget(
                                                          indexCurrent: 3,
                                                          alllistImage: widget
                                                              .messageDoc!
                                                              .listImages,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ).then((value) =>
                                                    safeSetState(() {}));
                                              },
                                              child: Hero(
                                                tag: widget
                                                    .messageDoc!.listImages
                                                    .elementAtOrNull(3)!,
                                                transitionOnUserGestures: true,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.only(),
                                                  child: CachedNetworkImage(
                                                    fadeInDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    fadeOutDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    imageUrl: widget
                                                        .messageDoc!.listImages
                                                        .elementAtOrNull(3)!,
                                                    width: double.infinity,
                                                    height: 170.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ].divide(const SizedBox(width: 1.0)),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Expanded(
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                await showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  context: context,
                                                  builder: (context) {
                                                    return WebViewAware(
                                                      child: Padding(
                                                        padding: MediaQuery
                                                            .viewInsetsOf(
                                                                context),
                                                        child: ImageViewWidget(
                                                          indexCurrent: 4,
                                                          alllistImage: widget
                                                              .messageDoc!
                                                              .listImages,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ).then((value) =>
                                                    safeSetState(() {}));
                                              },
                                              child: Hero(
                                                tag: widget
                                                    .messageDoc!.listImages
                                                    .elementAtOrNull(4)!,
                                                transitionOnUserGestures: true,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(18.0),
                                                  ),
                                                  child: CachedNetworkImage(
                                                    fadeInDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    fadeOutDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    imageUrl: widget
                                                        .messageDoc!.listImages
                                                        .elementAtOrNull(4)!,
                                                    width: double.infinity,
                                                    height: 120.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                await showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  context: context,
                                                  builder: (context) {
                                                    return WebViewAware(
                                                      child: Padding(
                                                        padding: MediaQuery
                                                            .viewInsetsOf(
                                                                context),
                                                        child: ImageViewWidget(
                                                          indexCurrent: 5,
                                                          alllistImage: widget
                                                              .messageDoc!
                                                              .listImages,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ).then((value) =>
                                                    safeSetState(() {}));
                                              },
                                              child: Hero(
                                                tag: widget
                                                    .messageDoc!.listImages
                                                    .elementAtOrNull(5)!,
                                                transitionOnUserGestures: true,
                                                child: CachedNetworkImage(
                                                  fadeInDuration:
                                                      const Duration(
                                                          milliseconds: 5),
                                                  fadeOutDuration:
                                                      const Duration(
                                                          milliseconds: 5),
                                                  imageUrl: widget
                                                      .messageDoc!.listImages
                                                      .elementAtOrNull(5)!,
                                                  width: double.infinity,
                                                  height: 120.0,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                await showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  context: context,
                                                  builder: (context) {
                                                    return WebViewAware(
                                                      child: Padding(
                                                        padding: MediaQuery
                                                            .viewInsetsOf(
                                                                context),
                                                        child: ImageViewWidget(
                                                          indexCurrent: 6,
                                                          alllistImage: widget
                                                              .messageDoc!
                                                              .listImages,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ).then((value) =>
                                                    safeSetState(() {}));
                                              },
                                              child: Hero(
                                                tag: widget.messageDoc!
                                                    .listImages.lastOrNull!,
                                                transitionOnUserGestures: true,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    bottomRight:
                                                        Radius.circular(8.0),
                                                  ),
                                                  child: CachedNetworkImage(
                                                    fadeInDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    fadeOutDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    imageUrl: widget.messageDoc!
                                                        .listImages.lastOrNull!,
                                                    width: double.infinity,
                                                    height: 120.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ].divide(const SizedBox(width: 1.0)),
                                      ),
                                    ].divide(const SizedBox(height: 1.0)),
                                  ),
                                if (widget.messageDoc?.listImages.length == 8)
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Expanded(
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                await showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  context: context,
                                                  builder: (context) {
                                                    return WebViewAware(
                                                      child: Padding(
                                                        padding: MediaQuery
                                                            .viewInsetsOf(
                                                                context),
                                                        child: ImageViewWidget(
                                                          indexCurrent: 0,
                                                          alllistImage: widget
                                                              .messageDoc!
                                                              .listImages,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ).then((value) =>
                                                    safeSetState(() {}));
                                              },
                                              child: Hero(
                                                tag: widget.messageDoc!
                                                    .listImages.firstOrNull!,
                                                transitionOnUserGestures: true,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(18.0),
                                                  ),
                                                  child: CachedNetworkImage(
                                                    fadeInDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    fadeOutDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    imageUrl: widget
                                                        .messageDoc!
                                                        .listImages
                                                        .firstOrNull!,
                                                    width: double.infinity,
                                                    height: 170.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                await showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  context: context,
                                                  builder: (context) {
                                                    return WebViewAware(
                                                      child: Padding(
                                                        padding: MediaQuery
                                                            .viewInsetsOf(
                                                                context),
                                                        child: ImageViewWidget(
                                                          indexCurrent: 1,
                                                          alllistImage: widget
                                                              .messageDoc!
                                                              .listImages,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ).then((value) =>
                                                    safeSetState(() {}));
                                              },
                                              child: Hero(
                                                tag: widget
                                                    .messageDoc!.listImages
                                                    .elementAtOrNull(1)!,
                                                transitionOnUserGestures: true,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    topRight:
                                                        Radius.circular(18.0),
                                                  ),
                                                  child: CachedNetworkImage(
                                                    fadeInDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    fadeOutDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    imageUrl: widget
                                                        .messageDoc!.listImages
                                                        .elementAtOrNull(1)!,
                                                    width: double.infinity,
                                                    height: 170.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ].divide(const SizedBox(width: 1.0)),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Expanded(
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                await showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  context: context,
                                                  builder: (context) {
                                                    return WebViewAware(
                                                      child: Padding(
                                                        padding: MediaQuery
                                                            .viewInsetsOf(
                                                                context),
                                                        child: ImageViewWidget(
                                                          indexCurrent: 2,
                                                          alllistImage: widget
                                                              .messageDoc!
                                                              .listImages,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ).then((value) =>
                                                    safeSetState(() {}));
                                              },
                                              child: Hero(
                                                tag: widget
                                                    .messageDoc!.listImages
                                                    .elementAtOrNull(2)!,
                                                transitionOnUserGestures: true,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.only(),
                                                  child: CachedNetworkImage(
                                                    fadeInDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    fadeOutDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    imageUrl: widget
                                                        .messageDoc!.listImages
                                                        .elementAtOrNull(2)!,
                                                    width: double.infinity,
                                                    height: 120.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                await showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  context: context,
                                                  builder: (context) {
                                                    return WebViewAware(
                                                      child: Padding(
                                                        padding: MediaQuery
                                                            .viewInsetsOf(
                                                                context),
                                                        child: ImageViewWidget(
                                                          indexCurrent: 3,
                                                          alllistImage: widget
                                                              .messageDoc!
                                                              .listImages,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ).then((value) =>
                                                    safeSetState(() {}));
                                              },
                                              child: Hero(
                                                tag: widget
                                                    .messageDoc!.listImages
                                                    .elementAtOrNull(3)!,
                                                transitionOnUserGestures: true,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.only(),
                                                  child: CachedNetworkImage(
                                                    fadeInDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    fadeOutDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    imageUrl: widget
                                                        .messageDoc!.listImages
                                                        .elementAtOrNull(3)!,
                                                    width: double.infinity,
                                                    height: 120.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                await showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  context: context,
                                                  builder: (context) {
                                                    return WebViewAware(
                                                      child: Padding(
                                                        padding: MediaQuery
                                                            .viewInsetsOf(
                                                                context),
                                                        child: ImageViewWidget(
                                                          indexCurrent: 4,
                                                          alllistImage: widget
                                                              .messageDoc!
                                                              .listImages,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ).then((value) =>
                                                    safeSetState(() {}));
                                              },
                                              child: Hero(
                                                tag: widget
                                                    .messageDoc!.listImages
                                                    .elementAtOrNull(4)!,
                                                transitionOnUserGestures: true,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.only(),
                                                  child: CachedNetworkImage(
                                                    fadeInDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    fadeOutDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    imageUrl: widget
                                                        .messageDoc!.listImages
                                                        .elementAtOrNull(4)!,
                                                    width: double.infinity,
                                                    height: 120.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ].divide(const SizedBox(width: 1.0)),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Expanded(
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                await showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  context: context,
                                                  builder: (context) {
                                                    return WebViewAware(
                                                      child: Padding(
                                                        padding: MediaQuery
                                                            .viewInsetsOf(
                                                                context),
                                                        child: ImageViewWidget(
                                                          indexCurrent: 5,
                                                          alllistImage: widget
                                                              .messageDoc!
                                                              .listImages,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ).then((value) =>
                                                    safeSetState(() {}));
                                              },
                                              child: Hero(
                                                tag: widget
                                                    .messageDoc!.listImages
                                                    .elementAtOrNull(5)!,
                                                transitionOnUserGestures: true,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(18.0),
                                                  ),
                                                  child: CachedNetworkImage(
                                                    fadeInDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    fadeOutDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    imageUrl: widget
                                                        .messageDoc!.listImages
                                                        .elementAtOrNull(5)!,
                                                    width: double.infinity,
                                                    height: 120.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                await showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  context: context,
                                                  builder: (context) {
                                                    return WebViewAware(
                                                      child: Padding(
                                                        padding: MediaQuery
                                                            .viewInsetsOf(
                                                                context),
                                                        child: ImageViewWidget(
                                                          indexCurrent: 6,
                                                          alllistImage: widget
                                                              .messageDoc!
                                                              .listImages,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ).then((value) =>
                                                    safeSetState(() {}));
                                              },
                                              child: Hero(
                                                tag: widget
                                                    .messageDoc!.listImages
                                                    .elementAtOrNull(6)!,
                                                transitionOnUserGestures: true,
                                                child: CachedNetworkImage(
                                                  fadeInDuration:
                                                      const Duration(
                                                          milliseconds: 5),
                                                  fadeOutDuration:
                                                      const Duration(
                                                          milliseconds: 5),
                                                  imageUrl: widget
                                                      .messageDoc!.listImages
                                                      .elementAtOrNull(6)!,
                                                  width: double.infinity,
                                                  height: 120.0,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                await showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  context: context,
                                                  builder: (context) {
                                                    return WebViewAware(
                                                      child: Padding(
                                                        padding: MediaQuery
                                                            .viewInsetsOf(
                                                                context),
                                                        child: ImageViewWidget(
                                                          indexCurrent: 7,
                                                          alllistImage: widget
                                                              .messageDoc!
                                                              .listImages,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ).then((value) =>
                                                    safeSetState(() {}));
                                              },
                                              child: Hero(
                                                tag: widget.messageDoc!
                                                    .listImages.lastOrNull!,
                                                transitionOnUserGestures: true,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    bottomRight:
                                                        Radius.circular(8.0),
                                                  ),
                                                  child: CachedNetworkImage(
                                                    fadeInDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    fadeOutDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    imageUrl: widget.messageDoc!
                                                        .listImages.lastOrNull!,
                                                    width: double.infinity,
                                                    height: 120.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ].divide(const SizedBox(width: 1.0)),
                                      ),
                                    ].divide(const SizedBox(height: 1.0)),
                                  ),
                                if (widget.messageDoc?.listImages.length == 9)
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Expanded(
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                await showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  context: context,
                                                  builder: (context) {
                                                    return WebViewAware(
                                                      child: Padding(
                                                        padding: MediaQuery
                                                            .viewInsetsOf(
                                                                context),
                                                        child: ImageViewWidget(
                                                          indexCurrent: 0,
                                                          alllistImage: widget
                                                              .messageDoc!
                                                              .listImages,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ).then((value) =>
                                                    safeSetState(() {}));
                                              },
                                              child: Hero(
                                                tag: widget.messageDoc!
                                                    .listImages.firstOrNull!,
                                                transitionOnUserGestures: true,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(18.0),
                                                  ),
                                                  child: CachedNetworkImage(
                                                    fadeInDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    fadeOutDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    imageUrl: widget
                                                        .messageDoc!
                                                        .listImages
                                                        .firstOrNull!,
                                                    width: double.infinity,
                                                    height: 120.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                await showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  context: context,
                                                  builder: (context) {
                                                    return WebViewAware(
                                                      child: Padding(
                                                        padding: MediaQuery
                                                            .viewInsetsOf(
                                                                context),
                                                        child: ImageViewWidget(
                                                          indexCurrent: 1,
                                                          alllistImage: widget
                                                              .messageDoc!
                                                              .listImages,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ).then((value) =>
                                                    safeSetState(() {}));
                                              },
                                              child: Hero(
                                                tag: widget
                                                    .messageDoc!.listImages
                                                    .elementAtOrNull(1)!,
                                                transitionOnUserGestures: true,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.only(),
                                                  child: CachedNetworkImage(
                                                    fadeInDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    fadeOutDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    imageUrl: widget
                                                        .messageDoc!.listImages
                                                        .elementAtOrNull(1)!,
                                                    width: double.infinity,
                                                    height: 120.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                await showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  context: context,
                                                  builder: (context) {
                                                    return WebViewAware(
                                                      child: Padding(
                                                        padding: MediaQuery
                                                            .viewInsetsOf(
                                                                context),
                                                        child: ImageViewWidget(
                                                          indexCurrent: 2,
                                                          alllistImage: widget
                                                              .messageDoc!
                                                              .listImages,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ).then((value) =>
                                                    safeSetState(() {}));
                                              },
                                              child: Hero(
                                                tag: widget
                                                    .messageDoc!.listImages
                                                    .elementAtOrNull(2)!,
                                                transitionOnUserGestures: true,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    topRight:
                                                        Radius.circular(18.0),
                                                  ),
                                                  child: CachedNetworkImage(
                                                    fadeInDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    fadeOutDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    imageUrl: widget
                                                        .messageDoc!.listImages
                                                        .elementAtOrNull(2)!,
                                                    width: double.infinity,
                                                    height: 120.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ].divide(const SizedBox(width: 1.0)),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Expanded(
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                await showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  context: context,
                                                  builder: (context) {
                                                    return WebViewAware(
                                                      child: Padding(
                                                        padding: MediaQuery
                                                            .viewInsetsOf(
                                                                context),
                                                        child: ImageViewWidget(
                                                          indexCurrent: 3,
                                                          alllistImage: widget
                                                              .messageDoc!
                                                              .listImages,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ).then((value) =>
                                                    safeSetState(() {}));
                                              },
                                              child: Hero(
                                                tag: widget
                                                    .messageDoc!.listImages
                                                    .elementAtOrNull(3)!,
                                                transitionOnUserGestures: true,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.only(),
                                                  child: CachedNetworkImage(
                                                    fadeInDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    fadeOutDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    imageUrl: widget
                                                        .messageDoc!.listImages
                                                        .elementAtOrNull(3)!,
                                                    width: double.infinity,
                                                    height: 120.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                await showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  context: context,
                                                  builder: (context) {
                                                    return WebViewAware(
                                                      child: Padding(
                                                        padding: MediaQuery
                                                            .viewInsetsOf(
                                                                context),
                                                        child: ImageViewWidget(
                                                          indexCurrent: 4,
                                                          alllistImage: widget
                                                              .messageDoc!
                                                              .listImages,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ).then((value) =>
                                                    safeSetState(() {}));
                                              },
                                              child: Hero(
                                                tag: widget
                                                    .messageDoc!.listImages
                                                    .elementAtOrNull(4)!,
                                                transitionOnUserGestures: true,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.only(),
                                                  child: CachedNetworkImage(
                                                    fadeInDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    fadeOutDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    imageUrl: widget
                                                        .messageDoc!.listImages
                                                        .elementAtOrNull(4)!,
                                                    width: double.infinity,
                                                    height: 120.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                await showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  context: context,
                                                  builder: (context) {
                                                    return WebViewAware(
                                                      child: Padding(
                                                        padding: MediaQuery
                                                            .viewInsetsOf(
                                                                context),
                                                        child: ImageViewWidget(
                                                          indexCurrent: 5,
                                                          alllistImage: widget
                                                              .messageDoc!
                                                              .listImages,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ).then((value) =>
                                                    safeSetState(() {}));
                                              },
                                              child: Hero(
                                                tag: widget
                                                    .messageDoc!.listImages
                                                    .elementAtOrNull(5)!,
                                                transitionOnUserGestures: true,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.only(),
                                                  child: CachedNetworkImage(
                                                    fadeInDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    fadeOutDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    imageUrl: widget
                                                        .messageDoc!.listImages
                                                        .elementAtOrNull(5)!,
                                                    width: double.infinity,
                                                    height: 120.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ].divide(const SizedBox(width: 1.0)),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Expanded(
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                await showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  context: context,
                                                  builder: (context) {
                                                    return WebViewAware(
                                                      child: Padding(
                                                        padding: MediaQuery
                                                            .viewInsetsOf(
                                                                context),
                                                        child: ImageViewWidget(
                                                          indexCurrent: 6,
                                                          alllistImage: widget
                                                              .messageDoc!
                                                              .listImages,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ).then((value) =>
                                                    safeSetState(() {}));
                                              },
                                              child: Hero(
                                                tag: widget
                                                    .messageDoc!.listImages
                                                    .elementAtOrNull(6)!,
                                                transitionOnUserGestures: true,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(18.0),
                                                  ),
                                                  child: CachedNetworkImage(
                                                    fadeInDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    fadeOutDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    imageUrl: widget
                                                        .messageDoc!.listImages
                                                        .elementAtOrNull(6)!,
                                                    width: double.infinity,
                                                    height: 120.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                await showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  context: context,
                                                  builder: (context) {
                                                    return WebViewAware(
                                                      child: Padding(
                                                        padding: MediaQuery
                                                            .viewInsetsOf(
                                                                context),
                                                        child: ImageViewWidget(
                                                          indexCurrent: 7,
                                                          alllistImage: widget
                                                              .messageDoc!
                                                              .listImages,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ).then((value) =>
                                                    safeSetState(() {}));
                                              },
                                              child: Hero(
                                                tag: widget
                                                    .messageDoc!.listImages
                                                    .elementAtOrNull(7)!,
                                                transitionOnUserGestures: true,
                                                child: CachedNetworkImage(
                                                  fadeInDuration:
                                                      const Duration(
                                                          milliseconds: 5),
                                                  fadeOutDuration:
                                                      const Duration(
                                                          milliseconds: 5),
                                                  imageUrl: widget
                                                      .messageDoc!.listImages
                                                      .elementAtOrNull(7)!,
                                                  width: double.infinity,
                                                  height: 120.0,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                await showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  context: context,
                                                  builder: (context) {
                                                    return WebViewAware(
                                                      child: Padding(
                                                        padding: MediaQuery
                                                            .viewInsetsOf(
                                                                context),
                                                        child: ImageViewWidget(
                                                          indexCurrent: 8,
                                                          alllistImage: widget
                                                              .messageDoc!
                                                              .listImages,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ).then((value) =>
                                                    safeSetState(() {}));
                                              },
                                              child: Hero(
                                                tag: widget.messageDoc!
                                                    .listImages.lastOrNull!,
                                                transitionOnUserGestures: true,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    bottomRight:
                                                        Radius.circular(8.0),
                                                  ),
                                                  child: CachedNetworkImage(
                                                    fadeInDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    fadeOutDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    imageUrl: widget.messageDoc!
                                                        .listImages.lastOrNull!,
                                                    width: double.infinity,
                                                    height: 120.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ].divide(const SizedBox(width: 1.0)),
                                      ),
                                    ].divide(const SizedBox(height: 1.0)),
                                  ),
                                if (widget.messageDoc?.listImages.length == 10)
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Expanded(
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                await showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  context: context,
                                                  builder: (context) {
                                                    return WebViewAware(
                                                      child: Padding(
                                                        padding: MediaQuery
                                                            .viewInsetsOf(
                                                                context),
                                                        child: ImageViewWidget(
                                                          indexCurrent: 0,
                                                          alllistImage: widget
                                                              .messageDoc!
                                                              .listImages,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ).then((value) =>
                                                    safeSetState(() {}));
                                              },
                                              child: Hero(
                                                tag: widget.messageDoc!
                                                    .listImages.firstOrNull!,
                                                transitionOnUserGestures: true,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(18.0),
                                                  ),
                                                  child: CachedNetworkImage(
                                                    fadeInDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    fadeOutDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    imageUrl: widget
                                                        .messageDoc!
                                                        .listImages
                                                        .firstOrNull!,
                                                    width: double.infinity,
                                                    height: 120.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                await showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  context: context,
                                                  builder: (context) {
                                                    return WebViewAware(
                                                      child: Padding(
                                                        padding: MediaQuery
                                                            .viewInsetsOf(
                                                                context),
                                                        child: ImageViewWidget(
                                                          indexCurrent: 1,
                                                          alllistImage: widget
                                                              .messageDoc!
                                                              .listImages,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ).then((value) =>
                                                    safeSetState(() {}));
                                              },
                                              child: Hero(
                                                tag: widget
                                                    .messageDoc!.listImages
                                                    .elementAtOrNull(1)!,
                                                transitionOnUserGestures: true,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.only(),
                                                  child: CachedNetworkImage(
                                                    fadeInDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    fadeOutDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    imageUrl: widget
                                                        .messageDoc!.listImages
                                                        .elementAtOrNull(1)!,
                                                    width: double.infinity,
                                                    height: 120.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                await showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  context: context,
                                                  builder: (context) {
                                                    return WebViewAware(
                                                      child: Padding(
                                                        padding: MediaQuery
                                                            .viewInsetsOf(
                                                                context),
                                                        child: ImageViewWidget(
                                                          indexCurrent: 2,
                                                          alllistImage: widget
                                                              .messageDoc!
                                                              .listImages,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ).then((value) =>
                                                    safeSetState(() {}));
                                              },
                                              child: Hero(
                                                tag: widget
                                                    .messageDoc!.listImages
                                                    .elementAtOrNull(2)!,
                                                transitionOnUserGestures: true,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    topRight:
                                                        Radius.circular(18.0),
                                                  ),
                                                  child: CachedNetworkImage(
                                                    fadeInDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    fadeOutDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    imageUrl: widget
                                                        .messageDoc!.listImages
                                                        .elementAtOrNull(2)!,
                                                    width: double.infinity,
                                                    height: 120.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ].divide(const SizedBox(width: 1.0)),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Expanded(
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                await showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  context: context,
                                                  builder: (context) {
                                                    return WebViewAware(
                                                      child: Padding(
                                                        padding: MediaQuery
                                                            .viewInsetsOf(
                                                                context),
                                                        child: ImageViewWidget(
                                                          indexCurrent: 3,
                                                          alllistImage: widget
                                                              .messageDoc!
                                                              .listImages,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ).then((value) =>
                                                    safeSetState(() {}));
                                              },
                                              child: Hero(
                                                tag: widget
                                                    .messageDoc!.listImages
                                                    .elementAtOrNull(3)!,
                                                transitionOnUserGestures: true,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.only(),
                                                  child: CachedNetworkImage(
                                                    fadeInDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    fadeOutDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    imageUrl: widget
                                                        .messageDoc!.listImages
                                                        .elementAtOrNull(3)!,
                                                    width: double.infinity,
                                                    height: 120.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                await showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  context: context,
                                                  builder: (context) {
                                                    return WebViewAware(
                                                      child: Padding(
                                                        padding: MediaQuery
                                                            .viewInsetsOf(
                                                                context),
                                                        child: ImageViewWidget(
                                                          indexCurrent: 4,
                                                          alllistImage: widget
                                                              .messageDoc!
                                                              .listImages,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ).then((value) =>
                                                    safeSetState(() {}));
                                              },
                                              child: Hero(
                                                tag: widget
                                                    .messageDoc!.listImages
                                                    .elementAtOrNull(4)!,
                                                transitionOnUserGestures: true,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.only(),
                                                  child: CachedNetworkImage(
                                                    fadeInDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    fadeOutDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    imageUrl: widget
                                                        .messageDoc!.listImages
                                                        .elementAtOrNull(4)!,
                                                    width: double.infinity,
                                                    height: 120.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                await showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  context: context,
                                                  builder: (context) {
                                                    return WebViewAware(
                                                      child: Padding(
                                                        padding: MediaQuery
                                                            .viewInsetsOf(
                                                                context),
                                                        child: ImageViewWidget(
                                                          indexCurrent: 5,
                                                          alllistImage: widget
                                                              .messageDoc!
                                                              .listImages,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ).then((value) =>
                                                    safeSetState(() {}));
                                              },
                                              child: Hero(
                                                tag: widget
                                                    .messageDoc!.listImages
                                                    .elementAtOrNull(5)!,
                                                transitionOnUserGestures: true,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.only(),
                                                  child: CachedNetworkImage(
                                                    fadeInDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    fadeOutDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    imageUrl: widget
                                                        .messageDoc!.listImages
                                                        .elementAtOrNull(5)!,
                                                    width: double.infinity,
                                                    height: 120.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                await showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  context: context,
                                                  builder: (context) {
                                                    return WebViewAware(
                                                      child: Padding(
                                                        padding: MediaQuery
                                                            .viewInsetsOf(
                                                                context),
                                                        child: ImageViewWidget(
                                                          indexCurrent: 6,
                                                          alllistImage: widget
                                                              .messageDoc!
                                                              .listImages,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ).then((value) =>
                                                    safeSetState(() {}));
                                              },
                                              child: Hero(
                                                tag: widget
                                                    .messageDoc!.listImages
                                                    .elementAtOrNull(6)!,
                                                transitionOnUserGestures: true,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.only(),
                                                  child: CachedNetworkImage(
                                                    fadeInDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    fadeOutDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    imageUrl: widget
                                                        .messageDoc!.listImages
                                                        .elementAtOrNull(6)!,
                                                    width: double.infinity,
                                                    height: 120.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ].divide(const SizedBox(width: 1.0)),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Expanded(
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                await showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  context: context,
                                                  builder: (context) {
                                                    return WebViewAware(
                                                      child: Padding(
                                                        padding: MediaQuery
                                                            .viewInsetsOf(
                                                                context),
                                                        child: ImageViewWidget(
                                                          indexCurrent: 7,
                                                          alllistImage: widget
                                                              .messageDoc!
                                                              .listImages,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ).then((value) =>
                                                    safeSetState(() {}));
                                              },
                                              child: Hero(
                                                tag: widget
                                                    .messageDoc!.listImages
                                                    .elementAtOrNull(7)!,
                                                transitionOnUserGestures: true,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(18.0),
                                                  ),
                                                  child: CachedNetworkImage(
                                                    fadeInDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    fadeOutDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    imageUrl: widget
                                                        .messageDoc!.listImages
                                                        .elementAtOrNull(7)!,
                                                    width: double.infinity,
                                                    height: 120.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                await showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  context: context,
                                                  builder: (context) {
                                                    return WebViewAware(
                                                      child: Padding(
                                                        padding: MediaQuery
                                                            .viewInsetsOf(
                                                                context),
                                                        child: ImageViewWidget(
                                                          indexCurrent: 8,
                                                          alllistImage: widget
                                                              .messageDoc!
                                                              .listImages,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ).then((value) =>
                                                    safeSetState(() {}));
                                              },
                                              child: Hero(
                                                tag: widget
                                                    .messageDoc!.listImages
                                                    .elementAtOrNull(8)!,
                                                transitionOnUserGestures: true,
                                                child: CachedNetworkImage(
                                                  fadeInDuration:
                                                      const Duration(
                                                          milliseconds: 5),
                                                  fadeOutDuration:
                                                      const Duration(
                                                          milliseconds: 5),
                                                  imageUrl: widget
                                                      .messageDoc!.listImages
                                                      .elementAtOrNull(8)!,
                                                  width: double.infinity,
                                                  height: 120.0,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                await showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  context: context,
                                                  builder: (context) {
                                                    return WebViewAware(
                                                      child: Padding(
                                                        padding: MediaQuery
                                                            .viewInsetsOf(
                                                                context),
                                                        child: ImageViewWidget(
                                                          indexCurrent: 9,
                                                          alllistImage: widget
                                                              .messageDoc!
                                                              .listImages,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ).then((value) =>
                                                    safeSetState(() {}));
                                              },
                                              child: Hero(
                                                tag: widget.messageDoc!
                                                    .listImages.lastOrNull!,
                                                transitionOnUserGestures: true,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    bottomRight:
                                                        Radius.circular(8.0),
                                                  ),
                                                  child: CachedNetworkImage(
                                                    fadeInDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    fadeOutDuration:
                                                        const Duration(
                                                            milliseconds: 5),
                                                    imageUrl: widget.messageDoc!
                                                        .listImages.lastOrNull!,
                                                    width: double.infinity,
                                                    height: 120.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ].divide(const SizedBox(width: 1.0)),
                                      ),
                                    ].divide(const SizedBox(height: 1.0)),
                                  ),
                                if (widget.messageDoc?.text == null ||
                                    widget.messageDoc?.text == '')
                                  Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            0.0, 0.0, 5.0, 5.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xB3000000),
                                        borderRadius:
                                            BorderRadius.circular(24.0),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(6.0, 5.0, 6.0, 6.0),
                                        child: Text(
                                          dateTimeFormat(
                                            "Hm",
                                            widget.messageDoc!.dateCreated!,
                                            locale: FFLocalizations.of(context)
                                                    .languageShortCode ??
                                                FFLocalizations.of(context)
                                                    .languageCode,
                                          ),
                                          textAlign: TextAlign.center,
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight: FontWeight.w500,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                                color: const Color(0xFFF6F6F6),
                                                fontSize: 12.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w500,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                                lineHeight: 1.2,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        if ((widget.messageDoc?.text != null &&
                                widget.messageDoc?.text != '') &&
                            !(widget.messageDoc!.listImages.isNotEmpty))
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                16.0, 9.0, 12.0, 6.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Flexible(
                                  child: Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            0.0, 0.0, 0.0, 5.0),
                                    child: Text(
                                      widget.messageDoc!.text,
                                      textAlign: TextAlign.start,
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                            color: FlutterFlowTheme.of(context)
                                                .secondary,
                                            fontSize: 15.0,
                                            letterSpacing: 0.0,
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              7.0, 0.0, 0.0, 0.0),
                                      child: Text(
                                        dateTimeFormat(
                                          "Hm",
                                          widget.messageDoc!.dateCreated!,
                                          locale: FFLocalizations.of(context)
                                                  .languageShortCode ??
                                              FFLocalizations.of(context)
                                                  .languageCode,
                                        ),
                                        textAlign: TextAlign.end,
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.inter(
                                                fontWeight: FontWeight.w500,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondary,
                                              fontSize: 12.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w500,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                      ),
                                    ),
                                    Stack(
                                      children: [
                                        if (widget.messageDoc?.read ?? true)
                                          FaIcon(
                                            FontAwesomeIcons.checkDouble,
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                            size: 11.0,
                                          ),
                                        if (!widget.messageDoc!.read)
                                          FaIcon(
                                            FontAwesomeIcons.check,
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                            size: 11.0,
                                          ),
                                      ],
                                    ),
                                  ].divide(const SizedBox(width: 8.0)),
                                ),
                              ],
                            ),
                          ),
                        if ((widget.messageDoc?.text != null &&
                                widget.messageDoc?.text != '') &&
                            (widget.messageDoc!.listImages.isNotEmpty))
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                16.0, 9.0, 12.0, 6.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Flexible(
                                  child: Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            0.0, 0.0, 0.0, 5.0),
                                    child: Text(
                                      widget.messageDoc!.text,
                                      textAlign: TextAlign.start,
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                            color: FlutterFlowTheme.of(context)
                                                .primaryText,
                                            fontSize: 15.0,
                                            letterSpacing: 0.0,
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              7.0, 0.0, 0.0, 0.0),
                                      child: Text(
                                        dateTimeFormat(
                                          "Hm",
                                          widget.messageDoc!.dateCreated!,
                                          locale: FFLocalizations.of(context)
                                                  .languageShortCode ??
                                              FFLocalizations.of(context)
                                                  .languageCode,
                                        ),
                                        textAlign: TextAlign.end,
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.inter(
                                                fontWeight: FontWeight.w500,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondary,
                                              fontSize: 12.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w500,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                      ),
                                    ),
                                    Stack(
                                      children: [
                                        if (widget.messageDoc?.read ?? true)
                                          FaIcon(
                                            FontAwesomeIcons.checkDouble,
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                            size: 11.0,
                                          ),
                                        if (!widget.messageDoc!.read)
                                          FaIcon(
                                            FontAwesomeIcons.check,
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                            size: 11.0,
                                          ),
                                      ],
                                    ),
                                  ].divide(const SizedBox(width: 8.0)),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
