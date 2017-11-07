import 'dart:io';
import 'package:grinder/grinder.dart';
import 'package:path/path.dart' as path;
import 'package:watcher/watcher.dart';

main(args) => grind(args);

@Task()
test() => new TestRunner().testAsync();

// @Depends(test)
// build() {
//   Pub.build();
// }

@Task()
clean() => defaultClean();

@Task()
compile() {
  runAsync('dart', arguments: ['build.dart']);
}

@DefaultTask()
@Depends(compile)
serve() async {
  runAsync('pub', arguments: ['serve', 'web/client', '--port=8000']);

  Process process = await getStreamProcess();
  stdout.addStream(process.stdout);
  stderr.addStream(process.stderr);

  // rspファイルの変更を検知してコンパイルする
  var clientWatcher = new DirectoryWatcher(path.absolute('web/client'));
  clientWatcher.events.listen((event) async {
    if (event.path.endsWith('.rsp.html')) {
      runAsync('dart', arguments: ['build.dart']);
    }
  });

  var serverWatcher = new DirectoryWatcher(path.absolute('web/webapp'));
  serverWatcher.events.listen((event) async {
    if (event.path.endsWith('.dart')) {
      log("Server: file change detected.");
      // ファイルのコンパイル後にrekulo streamを再起動させる
      // TODO: 標準出力とかのあたりがまともに動いてないかも…
      log("Server: kill process...");
      if (process.kill(ProcessSignal.SIGTERM)) {
        process = await getStreamProcess();
        log("Server: restart done.");
      }
    }
  });
}

getStreamProcess() async => Process.start('dart', ['web/webapp/main.dart']);
