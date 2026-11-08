import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'state.dart';

/// Responsive breakpoints used across the app.
class Bp {
  static bool wide(BuildContext c) => MediaQuery.of(c).size.width >= 800;
  static bool desktop(BuildContext c) => MediaQuery.of(c).size.width >= 1100;
}

/// Centres content and caps its width on large screens.
class PageBody extends StatelessWidget {
  final Widget child;
  const PageBody({super.key, required this.child});
  @override
  Widget build(BuildContext context) => Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Padding(padding: const EdgeInsets.all(16), child: child)));
}

class Section extends StatelessWidget {
  final String text;
  const Section(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(text, style: Theme.of(context).textTheme.titleLarge));
}

class _RingPainter extends CustomPainter {
  final double p;
  final Color fg, bg;
  _RingPainter(this.p, this.fg, this.bg);
  @override
  void paint(Canvas c, Size s) {
    final r = Rect.fromLTWH(14, 14, s.width - 28, s.height - 28);
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;
    c.drawArc(r, 0, math.pi * 2, false, base..color = bg);
    c.drawArc(r, -math.pi / 2, math.pi * 2 * p, false, base..color = fg);
  }

  @override
  bool shouldRepaint(_RingPainter o) => o.p != p || o.fg != fg;
}

/// Animated progress ring showing calories eaten vs goal.
class CalorieRing extends StatelessWidget {
  final int eaten, goal;
  final double size;
  const CalorieRing(this.eaten, this.goal, {super.key, this.size = 220});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final left = goal - eaten;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: (eaten / goal).clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (_, v, __) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _RingPainter(v, left < 0 ? cs.secondary : cs.primary,
              cs.surfaceContainerHighest),
          child: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('$eaten',
                  style: Theme.of(context)
                      .textTheme
                      .displaySmall
                      ?.copyWith(fontWeight: FontWeight.w800)),
              Text(left >= 0 ? '$left kcal left' : '${-left} kcal over',
                  style: TextStyle(color: left >= 0 ? null : cs.secondary)),
            ]),
          ),
        ),
      ),
    );
  }
}

class MacroBar extends StatelessWidget {
  final String label;
  final int grams, target;
  final Color color;
  const MacroBar(this.label, this.grams, this.target, this.color, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(label), Text('$grams / $target g'),
          ]),
          const SizedBox(height: 4),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: (grams / target).clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 700),
            builder: (_, v, __) => ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                    value: v, minHeight: 10, color: color,
                    backgroundColor: color.withOpacity(.15))),
          ),
        ]),
      );
}

class FoodCard extends StatelessWidget {
  final Food food;
  final VoidCallback onTap;
  const FoodCard(this.food, {super.key, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Hero(tag: food.name, child: Text(food.emoji, style: const TextStyle(fontSize: 40))),
              const Spacer(),
              Text(food.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              Text('${food.kcal} kcal', style: TextStyle(color: cs.primary)),
            ]),
          ),
          Positioned(
              top: 10, right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                    color: cs.primaryContainer, borderRadius: BorderRadius.circular(10)),
                child: Text(food.category, style: const TextStyle(fontSize: 11)),
              )),
        ]),
      ),
    );
  }
}
