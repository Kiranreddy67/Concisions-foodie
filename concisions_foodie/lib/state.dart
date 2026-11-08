import 'package:flutter/material.dart';

class Food {
  final String name, emoji, category;
  final int kcal, protein, carbs, fat; // per serving
  const Food(this.name, this.emoji, this.category, this.kcal, this.protein,
      this.carbs, this.fat);
}

class LogEntry {
  final Food food;
  final double servings;
  final String meal;
  LogEntry(this.food, this.servings, this.meal);
  int get kcal => (food.kcal * servings).round();
}

const meals = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];
const categories = ['Fruit', 'Grain', 'Protein', 'Dairy', 'Snack', 'Meal'];

class AppState extends ChangeNotifier {
  String? userName;
  int goal = 2000;
  bool dark = false;

  final List<Food> foods = [
    const Food('Banana', '🍌', 'Fruit', 105, 1, 27, 0),
    const Food('Apple', '🍎', 'Fruit', 95, 0, 25, 0),
    const Food('Oatmeal bowl', '🥣', 'Grain', 150, 5, 27, 3),
    const Food('Brown rice cup', '🍚', 'Grain', 215, 5, 45, 2),
    const Food('Boiled egg', '🥚', 'Protein', 78, 6, 1, 5),
    const Food('Grilled chicken', '🍗', 'Protein', 165, 31, 0, 4),
    const Food('Paneer 100g', '🧀', 'Dairy', 265, 18, 4, 20),
    const Food('Greek yogurt', '🥛', 'Dairy', 100, 17, 6, 1),
    const Food('Idli (2 pcs)', '🍘', 'Meal', 140, 4, 30, 1),
    const Food('Veg biryani', '🍛', 'Meal', 350, 8, 58, 10),
    const Food('Masala dosa', '🌯', 'Meal', 330, 6, 50, 12),
    const Food('Peanuts 30g', '🥜', 'Snack', 170, 7, 5, 14),
    const Food('Dark chocolate', '🍫', 'Snack', 170, 2, 13, 12),
    const Food('Pizza slice', '🍕', 'Meal', 285, 12, 36, 10),
  ];
  final List<LogEntry> log = [];

  int get eaten => log.fold(0, (s, e) => s + e.kcal);
  int _macro(int Function(Food) f) =>
      log.fold(0, (s, e) => s + (f(e.food) * e.servings).round());
  int get protein => _macro((f) => f.protein);
  int get carbs => _macro((f) => f.carbs);
  int get fat => _macro((f) => f.fat);

  void login(String name) {
    userName = name;
    notifyListeners();
  }

  void logout() {
    userName = null;
    log.clear();
    notifyListeners();
  }

  void setGoal(int g) {
    goal = g;
    notifyListeners();
  }

  void toggleDark() {
    dark = !dark;
    notifyListeners();
  }

  void addFood(Food f) {
    foods.insert(0, f);
    notifyListeners();
  }

  void logFood(Food f, double servings, String meal) {
    log.add(LogEntry(f, servings, meal));
    notifyListeners();
  }

  void removeLog(LogEntry e) {
    log.remove(e);
    notifyListeners();
  }
}
