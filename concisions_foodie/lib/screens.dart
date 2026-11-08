import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state.dart';
import 'widgets.dart';

// ───────────── Splash (AnimationController) ─────────────
class Splash extends StatefulWidget {
  const Splash({super.key});
  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
        ..forward();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      final loggedIn = context.read<AppState>().userName != null;
      Navigator.pushReplacementNamed(context, loggedIn ? '/home' : '/login');
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.primary,
      body: Center(
        child: ScaleTransition(
          scale: CurvedAnimation(parent: _c, curve: Curves.elasticOut),
          child: FadeTransition(
            opacity: _c,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('🥗', style: TextStyle(fontSize: 88)),
              const SizedBox(height: 12),
              Text('Concisions Foodie',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: cs.onPrimary)),
              Text('Know what you eat.', style: TextStyle(color: cs.onPrimary.withOpacity(.8))),
            ]),
          ),
        ),
      ),
    );
  }
}

// ───────────── Login (Form + validation) ─────────────
class Login extends StatefulWidget {
  const Login({super.key});
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _key = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _hide = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _key,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Text('🥗', style: TextStyle(fontSize: 56)),
                    Text('Welcome to Concisions Foodie',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _name,
                      decoration: const InputDecoration(labelText: 'Your name', prefixIcon: Icon(Icons.person)),
                      validator: (v) => (v == null || v.trim().length < 2) ? 'Enter at least 2 characters' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
                      validator: (v) => RegExp(r'^[\w.+-]+@[\w-]+\.[\w.]+$').hasMatch(v ?? '')
                          ? null
                          : 'Enter a valid email address',
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _pass,
                      obscureText: _hide,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                            icon: Icon(_hide ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => _hide = !_hide)),
                      ),
                      validator: (v) => (v ?? '').length < 6 ? 'Use 6 or more characters' : null,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          if (_key.currentState!.validate()) {
                            context.read<AppState>().login(_name.text.trim());
                            Navigator.pushReplacementNamed(context, '/home');
                          }
                        },
                        child: const Text('Start tracking'),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ───────────── Shell: adaptive navigation ─────────────
class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int _i = 0;
  static const _tabs = [
    (Icons.today_outlined, Icons.today, 'Today'),
    (Icons.restaurant_menu_outlined, Icons.restaurant_menu, 'Foods'),
    (Icons.person_outline, Icons.person, 'Profile'),
  ];
  static const _pages = [TodayTab(), FoodsTab(), ProfileTab()];

  @override
  Widget build(BuildContext context) {
    final wide = Bp.wide(context);
    return Scaffold(
      body: SafeArea(
        child: Row(children: [
          if (wide)
            NavigationRail(
              extended: Bp.desktop(context),
              selectedIndex: _i,
              onDestinationSelected: (i) => setState(() => _i = i),
              leading: const Padding(padding: EdgeInsets.all(12), child: Text('🥗', style: TextStyle(fontSize: 32))),
              destinations: [
                for (final t in _tabs)
                  NavigationRailDestination(icon: Icon(t.$1), selectedIcon: Icon(t.$2), label: Text(t.$3))
              ],
            ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: KeyedSubtree(key: ValueKey(_i), child: _pages[_i]),
            ),
          ),
        ]),
      ),
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: _i,
              onDestinationSelected: (i) => setState(() => _i = i),
              destinations: [
                for (final t in _tabs)
                  NavigationDestination(icon: Icon(t.$1), selectedIcon: Icon(t.$2), label: t.$3)
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/add'),
        icon: const Icon(Icons.add),
        label: const Text('New food'),
      ),
    );
  }
}

// ───────────── Today ─────────────
class TodayTab extends StatelessWidget {
  const TodayTab({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final cs = Theme.of(context).colorScheme;
    final wide = Bp.wide(context);

    final summary = Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          CalorieRing(s.eaten, s.goal, size: wide ? 240 : 200),
          const SizedBox(height: 12),
          Text('Goal: ${s.goal} kcal', style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          MacroBar('Protein', s.protein, (s.goal * .25 / 4).round(), cs.primary),
          MacroBar('Carbs', s.carbs, (s.goal * .5 / 4).round(), Colors.amber.shade700),
          MacroBar('Fat', s.fat, (s.goal * .25 / 9).round(), cs.secondary),
        ]),
      ),
    );

    final entries = s.log.isEmpty
        ? const Card(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: Text('Nothing logged yet.\nOpen Foods and add your first meal.', textAlign: TextAlign.center)),
            ),
          )
        : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            for (final m in meals)
              if (s.log.any((e) => e.meal == m)) ...[
                Section(m),
                for (final e in s.log.where((e) => e.meal == m))
                  Dismissible(
                    key: ObjectKey(e),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      margin: const EdgeInsets.only(bottom: 4),
                      decoration: BoxDecoration(color: cs.secondary, borderRadius: BorderRadius.circular(20)),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) => s.removeLog(e),
                    child: Card(
                      child: ListTile(
                        leading: Text(e.food.emoji, style: const TextStyle(fontSize: 28)),
                        title: Text(e.food.name),
                        subtitle: Text('${e.servings} serving(s)'),
                        trailing: Text('${e.kcal} kcal', style: const TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
              ],
          ]);

    return SingleChildScrollView(
      child: PageBody(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Hi, ${s.userName ?? 'there'}', style: Theme.of(context).textTheme.headlineMedium),
          const Text('Here is your day so far. Swipe an entry left to remove it.'),
          const SizedBox(height: 16),
          wide
              ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SizedBox(width: 360, child: summary),
                  const SizedBox(width: 20),
                  Expanded(child: entries),
                ])
              : Column(children: [summary, entries]),
          const SizedBox(height: 80),
        ]),
      ),
    );
  }
}

// ───────────── Foods (search + filter + GridView) ─────────────
class FoodsTab extends StatefulWidget {
  const FoodsTab({super.key});
  @override
  State<FoodsTab> createState() => _FoodsTabState();
}

class _FoodsTabState extends State<FoodsTab> {
  String _q = '';
  String? _cat;

  @override
  Widget build(BuildContext context) {
    final foods = context.watch<AppState>().foods.where((f) =>
        f.name.toLowerCase().contains(_q.toLowerCase()) && (_cat == null || f.category == _cat)).toList();
    return PageBody(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TextField(
          decoration: const InputDecoration(hintText: 'Search foods', prefixIcon: Icon(Icons.search)),
          onChanged: (v) => setState(() => _q = v),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 44,
          child: ListView(scrollDirection: Axis.horizontal, children: [
            for (final c in [null, ...categories])
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(c ?? 'All'),
                  selected: _cat == c,
                  onSelected: (_) => setState(() => _cat = c),
                ),
              ),
          ]),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: foods.isEmpty
              ? const Center(child: Text('No foods match. Try another search or add a new food.'))
              : GridView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 220, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.1),
                  itemCount: foods.length,
                  itemBuilder: (_, i) => FoodCard(foods[i],
                      onTap: () => Navigator.pushNamed(context, '/food', arguments: foods[i])),
                ),
        ),
      ]),
    );
  }
}

// ───────────── Food detail (log a meal) ─────────────
class FoodDetail extends StatefulWidget {
  final Food food;
  const FoodDetail({super.key, required this.food});
  @override
  State<FoodDetail> createState() => _FoodDetailState();
}

class _FoodDetailState extends State<FoodDetail> {
  double _servings = 1;
  String _meal = 'Lunch';

  @override
  Widget build(BuildContext context) {
    final f = widget.food;
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(f.name)),
      body: SingleChildScrollView(
        child: PageBody(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(children: [
                Hero(tag: f.name, child: Text(f.emoji, style: const TextStyle(fontSize: 96))),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text('${(f.kcal * _servings).round()} kcal',
                      key: ValueKey(_servings),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: cs.primary)),
                ),
                const SizedBox(height: 16),
                Row(children: [
                  for (final m in [('Protein', f.protein), ('Carbs', f.carbs), ('Fat', f.fat)])
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Column(children: [
                            Text('${(m.$2 * _servings).round()} g',
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                            Text(m.$1),
                          ]),
                        ),
                      ),
                    ),
                ]),
                const SizedBox(height: 12),
                Text('Servings: $_servings'),
                Slider(
                  value: _servings, min: .5, max: 5, divisions: 9,
                  label: '$_servings',
                  onChanged: (v) => setState(() => _servings = v),
                ),
                DropdownButtonFormField<String>(
                  value: _meal,
                  decoration: const InputDecoration(labelText: 'Meal'),
                  items: [for (final m in meals) DropdownMenuItem(value: m, child: Text(m))],
                  onChanged: (v) => setState(() => _meal = v!),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.add_task),
                    label: const Text('Add to today'),
                    onPressed: () {
                      context.read<AppState>().logFood(f, _servings, _meal);
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${f.name} added to $_meal')));
                      Navigator.pop(context);
                    },
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

// ───────────── Add custom food (Form + validation) ─────────────
class AddFood extends StatefulWidget {
  const AddFood({super.key});
  @override
  State<AddFood> createState() => _AddFoodState();
}

class _AddFoodState extends State<AddFood> {
  final _key = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _n = {for (final k in ['kcal', 'protein', 'carbs', 'fat']) k: TextEditingController()};
  String _cat = categories.first;

  String? _num(String? v, {int max = 5000}) {
    final n = int.tryParse(v ?? '');
    if (n == null) return 'Whole number';
    if (n < 0 || n > max) return '0 to $max';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final s = context.read<AppState>();
    Widget field(String k, String label, int max) => TextFormField(
          controller: _n[k],
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: label),
          validator: (v) => _num(v, max: max),
        );
    return Scaffold(
      appBar: AppBar(title: const Text('Add a food')),
      body: SingleChildScrollView(
        child: PageBody(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Form(
                key: _key,
                child: Column(children: [
                  TextFormField(
                    controller: _name,
                    decoration: const InputDecoration(labelText: 'Food name'),
                    validator: (v) {
                      final t = (v ?? '').trim();
                      if (t.isEmpty) return 'Enter a name';
                      if (s.foods.any((f) => f.name.toLowerCase() == t.toLowerCase())) return 'This food already exists';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _cat,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: [for (final c in categories) DropdownMenuItem(value: c, child: Text(c))],
                    onChanged: (v) => setState(() => _cat = v!),
                  ),
                  const SizedBox(height: 12),
                  field('kcal', 'Calories per serving (kcal)', 3000),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: field('protein', 'Protein (g)', 200)),
                    const SizedBox(width: 8),
                    Expanded(child: field('carbs', 'Carbs (g)', 500)),
                    const SizedBox(width: 8),
                    Expanded(child: field('fat', 'Fat (g)', 200)),
                  ]),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        if (!_key.currentState!.validate()) return;
                        int g(String k) => int.parse(_n[k]!.text);
                        s.addFood(Food(_name.text.trim(), '🍽️', _cat, g('kcal'), g('protein'), g('carbs'), g('fat')));
                        Navigator.pop(context);
                      },
                      child: const Text('Save food'),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ───────────── Profile: theme, goal calculator ─────────────
class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});
  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final _key = GlobalKey<FormState>();
  final _age = TextEditingController();
  final _h = TextEditingController();
  final _w = TextEditingController();
  bool _male = true;
  double _activity = 1.375;
  int? _result;

  String? _range(String? v, int lo, int hi) {
    final n = int.tryParse(v ?? '');
    return (n == null || n < lo || n > hi) ? 'Enter $lo to $hi' : null;
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return SingleChildScrollView(
      child: PageBody(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(s.userName ?? '', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Card(
            child: SwitchListTile(
              title: const Text('Dark mode'),
              secondary: const Icon(Icons.dark_mode),
              value: s.dark,
              onChanged: (_) => s.toggleDark(),
            ),
          ),
          const Section('Daily calorie goal'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _key,
                child: Column(children: [
                  Row(children: [
                    Expanded(child: TextFormField(controller: _age, keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Age'), validator: (v) => _range(v, 10, 100))),
                    const SizedBox(width: 8),
                    Expanded(child: TextFormField(controller: _h, keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Height (cm)'), validator: (v) => _range(v, 100, 250))),
                    const SizedBox(width: 8),
                    Expanded(child: TextFormField(controller: _w, keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Weight (kg)'), validator: (v) => _range(v, 30, 300))),
                  ]),
                  const SizedBox(height: 12),
                  SegmentedButton<bool>(
                    segments: const [ButtonSegment(value: true, label: Text('Male')), ButtonSegment(value: false, label: Text('Female'))],
                    selected: {_male},
                    onSelectionChanged: (v) => setState(() => _male = v.first),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<double>(
                    value: _activity,
                    decoration: const InputDecoration(labelText: 'Activity level'),
                    items: const [
                      DropdownMenuItem(value: 1.2, child: Text('Mostly sitting')),
                      DropdownMenuItem(value: 1.375, child: Text('Light exercise')),
                      DropdownMenuItem(value: 1.55, child: Text('Moderate exercise')),
                      DropdownMenuItem(value: 1.725, child: Text('Very active')),
                    ],
                    onChanged: (v) => setState(() => _activity = v!),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        if (!_key.currentState!.validate()) return;
                        final bmr = 10 * int.parse(_w.text) + 6.25 * int.parse(_h.text) -
                            5 * int.parse(_age.text) + (_male ? 5 : -161);
                        setState(() => _result = (bmr * _activity).round());
                      },
                      child: const Text('Calculate'),
                    ),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    child: _result == null
                        ? const SizedBox(width: double.infinity)
                        : Padding(
                            padding: const EdgeInsets.only(top: 14),
                            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Text('Maintenance: $_result kcal/day',
                                  style: const TextStyle(fontWeight: FontWeight.w700)),
                              OutlinedButton(
                                onPressed: () {
                                  s.setGoal(_result!);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Goal set to $_result kcal')));
                                },
                                child: const Text('Use as goal'),
                              ),
                            ]),
                          ),
                  ),
                ]),
              ),
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            icon: const Icon(Icons.logout),
            label: const Text('Log out'),
            onPressed: () {
              s.logout();
              Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
            },
          ),
          const SizedBox(height: 80),
        ]),
      ),
    );
  }
}
