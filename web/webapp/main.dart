//Sample of Stream: Hello Dynamic Contents
library hello_rsp;

import "dart:convert" show JSON;
import "package:stream/stream.dart";
import "package:rikulo_commons/io.dart" show getContentType;

part "client/helloView.rsp.dart";

//URI mapping
var _mapping = {
  "/server-info": serverInfo,
  "/hello": helloView
};

void serverInfo(HttpConnect connect) {
  final info = {"name": "Rikulo Stream", "version": connect.server.version};
  connect.response
    ..headers.contentType = getContentType("json")
    ..write(JSON.encode(info));
}

void main() {
  new StreamServer(
    homeDir: 'client',
    uriMapping: _mapping
  ).start();
}