import 'dart:io';
import 'package:grinder/grinder.dart';
import 'package:path/path.dart' as path;
import 'package:watcher/watcher.dart';
import 'package:stream/rspc.dart' as rspc;
import 'package:sass/sass.dart' as sass;

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
  dart2js(new Directory(path.absolute('web/client/js')));
  sass2css(new Directory(path.absolute('web/client/css')));
}

void dart2js(Directory directory) {
  directory.exists().then((bool exists) {
    directory.list().listen((FileSystemEntity fse) {
      if (fse is Directory) {
        dart2js(fse);
      } else if (fse is File && fse.path.endsWith('.dart')) {
        Dart2js.compileAsync(fse);
      }
    });
  });
}

sass2css(Directory directory) {
  directory.exists().then((bool exists) {
    directory.list().listen((FileSystemEntity fse) {
      if (fse is Directory) {
        sass2css(fse);
      } else if (fse is File &&
        (fse.path.endsWith('.scss') || fse.path.endsWith('.sass'))) {
        new File("${path.withoutExtension(fse.path)}.css").writeAsString(
          sass.compile(fse.path),
          mode: FileMode.WRITE_ONLY);
      }
    });
  });
}

@DefaultTask()
@Depends(compile)
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

      case '.scss':
        new File("${path.withoutExtension(event.path)}.css").writeAsString(
          sass.compile(event.path, color: true),
          mode: FileMode.WRITE_ONLY
        );
        break;
      default:
    }
  });
}

getStreamProcess() async => Process.start('dart', ['web/webapp/main.dart']);
