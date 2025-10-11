import 'package:ai_nutritionist/ai_service.dart';
import 'package:ai_nutritionist/config/constants.dart';
import 'package:ai_nutritionist/models/nutrition.dart';
import 'package:ai_nutritionist/models/user.dart';
import 'package:ai_nutritionist/obervers/observers.dart';
import 'package:ai_nutritionist/ui/nutrition_panel.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final DateTime today = DateTime.now();
  final SpeechToText _speechToText = SpeechToText();
  final AudioPlayer _audioPlayer = AudioPlayer();
  Nutrition? totalNutrition;
  Nutrition? currentNutrition;
  Nutrition? lastNutrtion;
  bool _speechEnabled = false;
  bool _isLoad = true;
  String _lastWords = '';
  User user = User();
  List<String> recentFoods = [];

  @override
  void initState() {
    super.initState();
    _initSpeech();
    userObserver.addCallback(updateUser);
  }

  @override
  void dispose() {
    userObserver.removeCallback(updateUser);
    _audioPlayer.dispose();
    super.dispose();
  }

  void updateUser(User newUser) async {
    setState(() => _isLoad = true);
    print(user.toJson());
    final totN = Nutrition.fromJson(
      (await AiService.getRequirements(newUser))!,
    );
    setState(() {
      user = newUser;
      totalNutrition = totN;
      _isLoad = false;
    });
  }

  /// This has to happen only once per app
  void _initSpeech() async {
    await _loadFromCache();
    if (totalNutrition == null) {
      try {
        totalNutrition = Nutrition.fromJson(
          (await AiService.getRequirements(user))!,
        );
        _saveToCache();
      } catch (_) {}
    }

    if ((await Permission.microphone.request()).isDenied) return;
    _speechEnabled = await _speechToText.initialize(onStatus: _onSpeechStatus);
    setState(() => _isLoad = false);
  }

  void _onSpeechStatus(String status) async {
    if (status == 'done') {
      await _audioPlayer.play(AssetSource('audio/beep.mp3'));
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
            _saveToCache();
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
    if (_lastWords != '') recentFoods.add(_lastWords);
    await _audioPlayer.play(AssetSource('audio/beep.mp3'));
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void _stopListening() async {
    await _speechToText.stop();
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() => _lastWords = result.recognizedWords);
  }

  Future<void> _saveToCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('date', today.millisecondsSinceEpoch);
    await prefs.setString('lastWords', _lastWords);
    if (totalNutrition != null) {
      await prefs.setString('totalNutrition', totalNutrition!.toJson());
    }
    if (currentNutrition != null) {
      await prefs.setString('currentNutrition', currentNutrition!.toJson());
    }
    if (lastNutrtion != null) {
      await prefs.setString('lastNutrition', lastNutrtion!.toJson());
    }
    await prefs.setString('user', user.toJson());
  }

  Future<void> _loadFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final oldDate = DateTime.fromMillisecondsSinceEpoch(
      prefs.getInt('date') ?? DateTime.now().millisecondsSinceEpoch,
    );
    if (oldDate.year == today.year &&
        oldDate.month == today.month &&
        oldDate.day == today.day) {
      _lastWords = prefs.getString('lastWords') ?? '';
      currentNutrition =
          prefs.getString('currentNutrition') != null
              ? Nutrition.fromJson(prefs.getString('currentNutrition')!)
              : null;
      lastNutrtion =
          prefs.getString('lastNutrition') != null
              ? Nutrition.fromJson(prefs.getString('lastNutrition')!)
              : null;
    }

    totalNutrition =
        prefs.getString('totalNutrition') != null
            ? Nutrition.fromJson(prefs.getString('totalNutrition')!)
            : null;

    user =
        prefs.getString('user') != null
            ? User.fromJson(prefs.getString('user')!)
            : User();
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
            Center(child: Opacity(opacity: 0.5, child: Text(user.toString()))),
            const SizedBox(height: 12),
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
            SizedBox(
              height: 150,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text(
                        'Recents:',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      ...recentFoods.map((t) => Text("- $t")),
                      Text("- $_lastWords"),
                    ],
                  ),
                ),
              ),
            ),
            if (!_speechEnabled) Text('Need mic permission!'),
            if (_isLoad) LinearProgressIndicator(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            _speechToText.isNotListening ? _startListening : _stopListening,
        tooltip: 'Listen',
        child: Icon(_speechToText.isNotListening ? Icons.mic_off : Icons.mic),
      ),
    );
  }
}
