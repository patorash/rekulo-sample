import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:stream_sample/app_component.dart';
import 'package:stream_sample/in_memory_data_service.dart';
import 'package:http/http.dart';
void main() {
  bootstrap(AppComponent, [
    ROUTER_PROVIDERS,
    // Remove next line in production
    provide(LocationStrategy, useClass: HashLocationStrategy),
    provide(Client, useClass: InMemoryDataService),
    // Using a real back end?
    // Import browser_client.dart and change the above to:
    // [provide(Client, useFactory: () => new BrowserClient(), deps: [])]
  ]);
}
