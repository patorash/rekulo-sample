import 'dart:async';
import 'dart:convert';
import 'package:angular/angular.dart';
import 'package:stream_sample/src/hero.dart';
import 'package:http/http.dart';

@Injectable()
class HeroService {
  static final _headers = {'Content-Type': 'application/json'};
  static const _heroesUrl = 'api/heroes';
  final Client _http;

  HeroService(this._http);

  Future<List<Hero>> getHeroes() async {
    try {
      final response = await _http.get(_heroesUrl);
      final heroes = _extractData(response)
        .map((value) => new Hero.fromJson(value)).toList();
      return heroes;
    } catch (e) {
      throw _handleError(e);
    }
  }

  dynamic _extractData(Response response) => JSON.decode(response.body)['data'];

  Exception _handleError(dynamic error) {
    print(error);
    return new Exception('Server error; cause $error');
  }

  Future<List<Hero>> getHeroesSlowly() {
    return new Future.delayed(const Duration(seconds: 2), getHeroes);
  }

  Future<Hero> getHero(int id) async {
    try {
      final response = await _http.get('$_heroesUrl/$id');
      return new Hero.fromJson(_extractData(response));
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Hero> update(Hero hero) async {
    try {
      final url = '$_heroesUrl/${hero.id}';
      final response = await _http.put(url, headers: _headers, body: JSON.encode(hero));
      return new Hero.fromJson(_extractData(response));
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Hero> create(String name) async {
    try {
      final response = await _http.post(_heroesUrl, headers: _headers, body: JSON.encode({'name': name}));
      return new Hero.fromJson(_extractData(response));
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Null> delete(int id) async {
    try {
      final url = '$_heroesUrl/$id';
      await _http.delete(_heroesUrl, headers: _headers);
    } catch (e) {
      throw _handleError(e);
    }
  }
}
