import 'dart:async';
import 'package:angular/angular.dart';
import 'src/hero.dart';
import 'src/hero_detail_component.dart';
import 'src/hero_service.dart';

@Component(
  selector: 'my-app',
  templateUrl: 'app_component.html',
  styleUrls: const ['app_component.css'],
  directives: const [CORE_DIRECTIVES, HeroDetailComponent],
  providers: const[HeroService]
)
class AppComponent implements OnInit {
  final title = 'Tour of Heros';
  List<Hero> heroes;
  Hero selectedHero;
  final HeroService _heroService;

  AppComponent(this._heroService);

  void ngOnInit() => getHeroes();

  Future<Null> getHeroes() async {
    // heroes = await _heroService.getHeroes();
    heroes = await _heroService.getHeroesSlowly();
  }

  void onSelect(Hero hero) => selectedHero = hero;
}