import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:concisions_foodie/main.dart';
import 'package:concisions_foodie/state.dart';

void main() {
  testWidgets('app starts on splash', (tester) async {
    await tester.pumpWidget(ChangeNotifierProvider(
        create: (_) => AppState(), child: const FoodieApp()));
    expect(find.text('Concisions Foodie'), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(find.text('Start tracking'), findsOneWidget);
  });

  test('logging food updates totals', () {
    final s = AppState();
    s.logFood(s.foods.first, 2, 'Lunch');
    expect(s.eaten, s.foods.first.kcal * 2);
  });
}
