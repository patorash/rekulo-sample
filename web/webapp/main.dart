//Sample of Stream: Hello Dynamic Contents

import 'dart:io';
import 'dart:async';
import "dart:convert" show JSON;
import "package:stream/stream.dart";
import "package:rikulo_commons/io.dart" show getContentType;
import 'package:stream_sample/pub_serve_proxy.dart';

part "client/helloView.rsp.dart";

var proxy = new PubServeProxy('localhost', 8000);

//URI mapping
var _mapping = {
  "/server-info": serverInfo,
  "/hello": helloView,
  "/assets/.*": proxy.forward,
  "/packages/.*": proxy.forward
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
    uriMapping: _mapping,
  ).start();
}