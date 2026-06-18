import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;

import '../utils/app_dio.dart';

extension ImageExtension on CachedNetworkImage {
  CachedNetworkImage uuid () {
    return CachedNetworkImage(imageUrl: imageUrl.uuidToUrl(),
      width: width,
      height: height,
      fit: fit,
      color: color,
      errorWidget: errorWidget,
    );
  }
}

extension UuidExtension on String {
  String uuidToUrl () {
    return '${AppDio.domain}files/get?uuid=${this}';
  }

  String urlToUuid () {
    return this.replaceAll('${AppDio.domain}files/get?uuid=', '');
  }

  Future<Uint8List> uintFromUuid () async {
    http.Response response = await http.get(
      Uri.parse(this.uuidToUrl()),
    );
    print('get image');
    return response.bodyBytes;
  }
}

