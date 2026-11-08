# Concisions Foodie (Flutter Web)

Responsive calorie tracker: log meals, browse foods, add custom foods, set a daily goal.

## Run
```
flutter create . --platforms=web      # generates the web/ folder once
flutter pub get
flutter run -d chrome
flutter build web                     # production build
```
Resize the browser window to test mobile (<800px), tablet and desktop (>=800px / >=1100px) layouts.

## Concept map
| Concept | Where |
|---|---|
| Widgets (Container, Row, Column, Stack, ListView, GridView, Card, buttons) | screens.dart, widgets.dart |
| Responsive UI (LayoutBuilder / MediaQuery / NavigationRail <-> NavigationBar, adaptive grid) | `Shell`, `FoodsTab`, `TodayTab` |
| Navigation (named routes, arguments, custom fade transition) | main.dart `onGenerateRoute` |
| Animations (TweenAnimationBuilder ring, Hero, AnimatedSwitcher, AnimationController splash, Dismissible) | `CalorieRing`, `Splash`, `Shell` |
| State management (Provider + ChangeNotifier, StatefulWidget) | state.dart |
| Theme + custom widgets (light/dark ThemeData, CalorieRing, MacroBar, FoodCard, Section) | main.dart, widgets.dart |
| Forms + validation (login, add food, calorie-goal calculator) | `Login`, `AddFood`, `ProfileTab` |
