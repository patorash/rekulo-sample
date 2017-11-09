import 'dart:async';
import 'package:angular/angular.dart';
import 'package:stream_sample/src/hero.dart';
import 'package:stream_sample/src/mock_heros.dart';

@Injectable()
class HeroService {
  Future<List<Hero>> getHeroes() async => mockHeroes;

  Future<List<Hero>> getHeroesSlowly() {
    return new Future.delayed(const Duration(seconds: 2), getHeroes);
  }
}
