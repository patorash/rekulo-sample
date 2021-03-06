import 'dart:io';
import 'dart:async';
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
  // pub serveにコンパイルを任せることにしたのでコメントアウトした
  // dart2js(new Directory(path.absolute('web/client/assets/js')));
  // sass2css(new Directory(path.absolute('web/client/assets/css')));
  // compileRsp(new Directory(path.absolute('web/client')));

  // compileRspでコンパイルを行うとエラーが起きる場合があったのでやめた
  runAsync('dart', arguments: ['build.dart']);
}

/// dartをjsにコンパイルする
/// 
/// [file]がDirectoryだった場合は、再帰的に呼び出す。
/// Fileだったら非同期でコンパイルする。
void dart2js(FileSystemEntity file) {
  file.exists().then((bool exists) {
    if (file is Directory) {
      Directory dir = file;
      dir.list().listen((FileSystemEntity fse) {
        dart2js(fse);
      });
    } else if (file is File && file.path.endsWith('.dart')) {
      runZoned(() => Dart2js.compileAsync(file)
      , onError: (e) {
        log(e.toString());
      });
    }
  });
}

/// sassをcssにコンパイルする
/// 
/// [file]がDirectoryだった場合は、再帰的に呼び出す。
/// Fileだったら非同期でコンパイルする。
void sass2css(FileSystemEntity file) {
  file.exists().then((bool exists) {
    if (file is Directory) {
      Directory dir = file;
      dir.list().listen((FileSystemEntity fse) {
        sass2css(fse);
      });
    } else if (file is File &&
              (file.path.endsWith('.scss') || file.path.endsWith('.sass'))) {
      runZoned(() => new File("${path.withoutExtension(file.path)}.css").writeAsString(
          sass.compile(file.path),
          mode: FileMode.WRITE_ONLY
        ), onError: (e) {
        log(e.toString());
      });
    }
  });
}

/// RSPファイルをコンパイルする
/// 
/// [file]がDirectoryだった場合は、再帰的に呼び出す。
/// Fileだったらコンパイルする。
void compileRsp(FileSystemEntity file) {
    file.exists().then((bool exists) {
    if (file is Directory) {
      Directory dir = file;
      dir.list().listen((FileSystemEntity fse) {
        compileRsp(fse);
      });
    } else if (file is File) {
      if (file.path.endsWith('.rsp.html')) {
        runZoned(() => rspc.compileFile(file.path)
        , onError: (e) {
          log(e.toString());
        });
      }
    }
  });
}

@DefaultTask()
@Depends(compile)
serve() async {
  Process process = await getStreamProcess();
  stdout.addStream(process.stdout);
  stderr.addStream(process.stderr);

  // rspファイルの変更を検知してコンパイルする
  var clientWatcher = new DirectoryWatcher(path.absolute('web/client'));
  clientWatcher.events.listen((event) async {
    if (event.path.endsWith('.rsp.html')) {
      runAsync('dart', arguments: ['build.dart']);
    }
    // pub serveにコンパイルを任せることにしたのでコメントアウトした
    // if (event.path.endsWith('.dart')) {
    //   dart2js(new File(event.path));
    // }
    // if (event.path.endsWith('.scss') || event.path.endsWith('.sass')) {
    //   sass2css(new File(event.path));
    // }
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
