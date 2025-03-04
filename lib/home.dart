import 'package:ai_nutritionist/ai_service.dart';
import 'package:ai_nutritionist/config/constants.dart';
import 'package:ai_nutritionist/models/nutrition.dart';
import 'package:ai_nutritionist/ui/nutrition_panel.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DateTime today = DateTime.now();
  final SpeechToText _speechToText = SpeechToText();
  Nutrition? totalNutrition;
  Nutrition? currentNutrition;
  Nutrition? lastNutrtion;
  bool _speechEnabled = false;
  bool _isLoad = true;
  String _lastWords = '';

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  /// This has to happen only once per app
  void _initSpeech() async {
    try {
      totalNutrition = Nutrition.fromJson((await AiService.getRequirements())!);
    } catch (_) {}
    if ((await Permission.microphone.request()).isDenied) return;
    _speechEnabled = await _speechToText.initialize(onStatus: _onSpeechStatus);
    setState(() => _isLoad = false);
  }

  void _onSpeechStatus(String status) {
    if (status == 'done') {
      setState(() {
        _isLoad = true;
        _lastWords = _speechToText.lastRecognizedWords;
      });

      AiService.getMealData(_lastWords).then((value) {
        final ret = () {
          try {
            lastNutrtion = Nutrition.fromJson(value!);
            if (currentNutrition == null) {
              currentNutrition = lastNutrtion;
            } else {
              currentNutrition = currentNutrition! + lastNutrtion!;
            }
            return currentNutrition;
          } catch (e) {
            return null;
          }
        }();

        setState(() => _isLoad = false);

        return ret;
      });
    }
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void _stopListening() async => await _speechToText.stop();

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() => _lastWords = result.recognizedWords);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('${weekdays[today.weekday - 1]}, '),
            Opacity(
              opacity: 0.5,
              child: Text('${months[today.month - 1]} ${today.day}'),
            ),
          ],
        ),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(flex: 4, child: Text('Nutrient')),
                Expanded(flex: 2, child: NText('Last')),
                Expanded(flex: 2, child: NText('Curr')),
                Expanded(flex: 2, child: NText('Totl')),
                Expanded(flex: 1, child: Text('')),
                Expanded(flex: 2, child: Text('')),
              ],
            ),
            Expanded(
              child:
                  (totalNutrition != null)
                      ? SingleChildScrollView(
                        child: NutritionPanel(
                          lastNutrition: lastNutrtion,
                          currentNutrition: currentNutrition,
                          totalNutrition: totalNutrition!,
                        ),
                      )
                      : const SizedBox(),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Last food: $_lastWords',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            if (!_speechEnabled) Text('Need mic permission!'),
            if (_isLoad) LinearProgressIndicator(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            // If not yet listening for speech start, otherwise stop
            _speechToText.isNotListening ? _startListening : _stopListening,
        tooltip: 'Listen',
        child: Icon(_speechToText.isNotListening ? Icons.mic_off : Icons.mic),
      ),
    );
  }
}
