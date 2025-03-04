import 'package:ai_nutritionist/ai_service.dart';
import 'package:ai_nutritionist/config/theme.dart';
import 'package:ai_nutritionist/helper/weight.dart';
import 'package:ai_nutritionist/models/nutrition.dart';
import 'package:ai_nutritionist/ui/text.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Future<String?> _totalRequirementsFuture = AiService.getRequirements();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Current Day'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: FutureBuilder(
          future: _totalRequirementsFuture,
          builder: (c, s) {
            if (s.connectionState == ConnectionState.done) {
              if (s.hasData) {
                return SingleChildScrollView(
                  child: NutritionPanel(Nutrition.fromJson(s.data!)),
                );
              }
              return Text('No Data');
            }

            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}

class NutritionPanel extends StatelessWidget {
  final Nutrition _nutrition;
  const NutritionPanel(this._nutrition, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ..._nutrition.basic.entries.map((e) => NutrionPanelTrack(e)),
        ..._nutrition.vitamins.entries.map((e) => NutrionPanelTrack(e)),
        ..._nutrition.minerals.entries.map((e) => NutrionPanelTrack(e)),
      ],
    );
  }
}

class NutrionPanelTrack extends StatelessWidget {
  final MapEntry<String, double> _entry;
  const NutrionPanelTrack(this._entry, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: darkColorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            MeText.headlineSmall(_entry.key),
            MeText.headlineSmall(
              (_entry.key == "calories")
                  ? _entry.value.round().toString()
                  : getWeightAsMetricClosesUnits(_entry.value),
            ),
          ],
        ),
      ),
    );
  }
}
