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
serve() {
  var pid;
  getStreamProcess().then((Process process) {
    pid = process.pid;
    stdout.addStream(process.stdout);
    stderr.addStream(process.stderr);
  });

  // rspファイルの変更を検知してコンパイルする
  var watcher = new DirectoryWatcher(path.absolute('web/client'));
  watcher.events.listen((event) {
    String secondExtension = path.extension(path.basenameWithoutExtension(event.path));
    if (secondExtension == '.rsp') {
      rspc.compileFile(event.path);
      // ファイルのコンパイル後にrekulo streamを再起動させる
      // TODO: 標準出力とかのあたりがまともに動いてない
      if (Process.killPid(pid, ProcessSignal.SIGTERM)) {
        getStreamProcess().then((Process process) {
          pid = process.pid;
        });
      }
    }
  });
}

getStreamProcess() => Process.start('dart', ['web/webapp/main.dart']);
