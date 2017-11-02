import 'dart:io';
import 'package:grinder/grinder.dart';
import 'package:path/path.dart' as path;
import 'package:watcher/watcher.dart';
import 'package:stream/rspc.dart' as rspc;

main(args) => grind(args);

@Task()
test() => new TestRunner().testAsync();

// @Depends(test)
// build() {
//   Pub.build();
// }

@Task()
clean() => defaultClean();

@DefaultTask()
serve() async {
  Process process = await getStreamProcess();
  stdout.addStream(process.stdout);
  stderr.addStream(process.stderr);

  // rspファイルの変更を検知してコンパイルする
  var watcher = new DirectoryWatcher(path.absolute('web/client'));
  watcher.events.listen((event) async {
    String secondExtension = path.extension(path.basenameWithoutExtension(event.path));
    if (secondExtension == '.rsp') {
      // stdout.write(event.path);
      rspc.compileFile(event.path);
      // ファイルのコンパイル後にrekulo streamを再起動させる
      // TODO: 標準出力とかのあたりがまともに動いてないかも…
      if (process.kill(ProcessSignal.SIGTERM)) {
        process = await getStreamProcess();
      }
    }
    switch (path.extension(event.path)) {
      case '.dart':
        Dart2js.compileAsync(new File(event.path));
        break;

      default:
    }
  });
}

getStreamProcess() async => Process.start('dart', ['web/webapp/main.dart']);
