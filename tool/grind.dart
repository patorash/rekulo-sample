import 'dart:io';
import 'package:grinder/grinder.dart';
import '../web/webapp/main.dart' as helloRsp;

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
  Process.start('dart', ['web/webapp/main.dart']).then((Process process) {
    stdout.addStream(process.stdout);
    stderr.addStream(process.stderr);
  });
}