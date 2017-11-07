import 'dart:io';
import 'dart:async';
import "package:stream/stream.dart";
import "package:rikulo_commons/io.dart" show getContentType;
import 'package:path/path.dart' as path;

class PubServeProxy {

  String _host;
  int _port;

  PubServeProxy(this._host, this._port);

  Future forward(HttpConnect connect) async {
    HttpRequest request = connect.request;
    final HttpClient client = new HttpClient();
    final HttpClientRequest proxyRequest = await client.open(
      request.method,
      _host,
      _port,
      request.uri.path);
    await proxyRequest.addStream(request);
    final HttpClientResponse proxyResponse = await proxyRequest.close();
    final HttpResponse response = request.response;
    response.statusCode = proxyResponse.statusCode;
    response.headers.contentType = getContentType(path.extension(request.uri.path));
    await response.addStream(proxyResponse);
    await response.flush();
    await response.close();
    client.close();
    return null;
  }
}