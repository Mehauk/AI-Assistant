import 'package:ai_nutritionist/config/theme.dart';
import 'package:ai_nutritionist/helper/weight.dart';
import 'package:ai_nutritionist/models/nutrition.dart';
import 'package:flutter/material.dart';

class NutritionPanel extends StatelessWidget {
  final Nutrition? lastNutrition;
  final Nutrition? currentNutrition;
  final Nutrition totalNutrition;
  const NutritionPanel({
    super.key,
    required this.lastNutrition,
    required this.currentNutrition,
    required this.totalNutrition,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...totalNutrition.basic.entries.map(
          (e) => NutrionPanelTrack(
            lastNutritionValue: lastNutrition?.basic[e.key] ?? 0,
            currentNutritionValue: currentNutrition?.basic[e.key] ?? 0,
            totalNutritionEntry: e,
          ),
        ),
        ...totalNutrition.vitamins.entries.map(
          (e) => NutrionPanelTrack(
            lastNutritionValue: lastNutrition?.vitamins[e.key] ?? 0,
            currentNutritionValue: currentNutrition?.vitamins[e.key] ?? 0,
            totalNutritionEntry: e,
          ),
        ),
        ...totalNutrition.minerals.entries.map(
          (e) => NutrionPanelTrack(
            lastNutritionValue: lastNutrition?.minerals[e.key] ?? 0,
            currentNutritionValue: currentNutrition?.minerals[e.key] ?? 0,
            totalNutritionEntry: e,
          ),
        ),
      ],
    );
  }
}

class NutrionPanelTrack extends StatelessWidget {
  final double lastNutritionValue;
  final double currentNutritionValue;
  final MapEntry<String, double> totalNutritionEntry;
  const NutrionPanelTrack({
    super.key,
    required this.lastNutritionValue,
    required this.currentNutritionValue,
    required this.totalNutritionEntry,
  });

  @override
  Widget build(BuildContext context) {
    final totalValue =
        (totalNutritionEntry.key == "calories")
            ? (totalNutritionEntry.value.round().toString(), '')
            : getWeightAsMetricClosesUnits(totalNutritionEntry.value);
    final currentValue =
        (totalNutritionEntry.key == "calories")
            ? (currentNutritionValue.round().toString(), '')
            : getWeightAsMetricClosesUnits(currentNutritionValue);
    final lastValue =
        (totalNutritionEntry.key == "calories")
            ? (lastNutritionValue.round().toString(), '')
            : getWeightAsMetricClosesUnits(lastNutritionValue);
    double stop0 = (lastNutritionValue) / (totalNutritionEntry.value);
    double stop = (currentNutritionValue) / (totalNutritionEntry.value);
    if (!stop0.isFinite) stop0 = 0.001;
    if (!stop.isFinite) stop = 0.007 + stop0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            colors: [
              Colors.amber,
              Colors.amber,
              Colors.deepPurple,
              Colors.deepPurple,
              darkColorScheme.surfaceBright,
              darkColorScheme.surfaceBright,
            ],
            stops: [0.001, stop0, stop0 + 0.007, stop, stop, 1],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 4, 6),
          child: Row(
            children: [
              Expanded(flex: 4, child: Text(totalNutritionEntry.key)),
              Expanded(flex: 2, child: NText(lastValue.$1)),
              Expanded(flex: 2, child: NText(currentValue.$1)),
              Expanded(flex: 2, child: NText(totalValue.$1)),
              Expanded(flex: 1, child: Text(totalValue.$2)),
              Expanded(flex: 2, child: Text('${(stop * 100).round()}%')),
            ],
          ),
        ),
      ),
    );
  }
}

class NText extends StatelessWidget {
  final String text;
  const NText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(text, textAlign: TextAlign.end, maxLines: 1);
  }
}
