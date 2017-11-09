import 'package:angular/angular.dart';
import 'package:angular_forms/angular_forms.dart';
import 'src/hero.dart';
import 'src/mock_heros.dart';

@Component(
  selector: 'my-app',
  templateUrl: 'app_component.html',
  styleUrls: const ['app_component.css'],
  directives: const [CORE_DIRECTIVES, formDirectives]
)
class AppComponent {
  final title = 'Tour of Heros';
  Hero hero = new Hero(1, 'Windstrom');
  List<Hero> heros = mockHeroes;
  Hero selectedHero;

  onSelect(Hero hero) {
    selectedHero = hero;
    print(selectedHero.name);
  }
}