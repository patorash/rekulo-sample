import 'dart:async';
import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:stream_sample/src/hero.dart';
import 'package:stream_sample/src/hero_service.dart';

@Component(
  selector: 'my-heroes',
  templateUrl: 'heroes_component.html',
  styleUrls: const ['heroes_component.css'],
  directives: const [CORE_DIRECTIVES,],
  providers: const[HeroService],
  pipes: const [COMMON_PIPES],
)
class HeroesComponent implements OnInit {
  List<Hero> heroes;
  Hero selectedHero;
  final HeroService _heroService;
  final Router _router;

  HeroesComponent(this._heroService, this._router);

  void ngOnInit() => getHeroes();

  Future<Null> getHeroes() async {
    // heroes = await _heroService.getHeroes();
    heroes = await _heroService.getHeroes();
  }

  void onSelect(Hero hero) => selectedHero = hero;

  Future<Null> gotoDetail() => _router.navigate([
    'HeroDetail',
    {'id': selectedHero.id.toString()}
  ]);
}