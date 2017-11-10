import 'dart:async';
import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'hero_service.dart';

import 'package:angular_forms/angular_forms.dart';
import 'hero.dart';

@Component(
  selector: 'hero-detail',
  templateUrl: 'hero_detail_component.html',
  directives: const [CORE_DIRECTIVES, formDirectives],
)
class HeroDetailComponent implements OnInit {
  Hero hero;
  final HeroService _heroService;
  final RouteParams _routeParams;
  final Location _location;

  HeroDetailComponent(this._heroService, this._routeParams, this._location);

  @override
  Future<Null> ngOnInit() async {
    var _id = _routeParams.get('id');
    var id = int.parse(_id ?? '', onError: (_) => null);
    if (id != null) hero = await (_heroService.getHero(id));
  }

  void goBack() => _location.back();

  Future<Null> save() async {
    _heroService.update(hero);
    goBack();
  }
}
