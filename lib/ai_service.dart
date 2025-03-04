import 'package:ai_nutritionist/models/user.dart';
import 'package:ai_nutritionist/secrets.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

abstract class AiService {
  static String? _lastResult;

  static final _model = GenerativeModel(
    model: 'gemini-2.0-flash-lite',
    apiKey: Secrets.googleAiChatKey,
    generationConfig: GenerationConfig(
      temperature: 0.7,
      topK: 40,
      topP: 0.95,
      maxOutputTokens: 8192,
      responseMimeType: 'application/json',
    ),
    systemInstruction: Content.system(_systemInstructions),
  );

  static Future<String?> getMealData(String mealTranscription) async {
    return await () async {
      final chat = _model.startChat(history: _curatedHistory);
      final content = Content.text(mealTranscription);

      final response = await chat.sendMessage(content);
      _lastResult = response.text;
      return response.text;
    }();
  }

  static Future<String?> getRequirements() async {
    return await () async {
      final chat = _model.startChat(history: _curatedHistory);
      final message =
          'totals for ${User(goal: Goal.weightLoss, gender: Gender.male, exercise: Exercise.light).toJson()}';
      final content = Content.text(message);

      final response = await chat.sendMessage(content);
      _lastResult = response.text;
      return response.text;
    }();
  }

  static const _systemInstructions =
      'You are a terse nutrionist.\nYou will be asked by clients about their daily requirements.\nYou will be asked by clients about the nutrional value of a meal.\n\nAlways include only the following in your reponse.\n- calories\n- free sugar\n- intrinsic sugar\n- fibers\n- proteins\n- saturated fat\n- trans fat\n- polyunsaturated fat\n- monounsaturated fat\n- sodium\n- cholesterol\n- vitamins (all)\n- minerals (all)\n\nrespond with JSON and use metric units. Always measure mass in grams, some of the vitamins require really small doses but make sure to measure in grams.\n';
  static final _curatedHistory = [
    Content.multi([
      TextPart(
        'totals for {gender: male, age: 25, weight: 67000, height: 174, goal: maintainWeight, exercise: light}',
      ),
    ]),
    Content.model([
      TextPart(
        '```json\n{\n  "calories": 2400,\n  "free sugar": 30,\n  "intrinsic sugar": 50,\n  "fibers": 30,\n  "proteins": 67,\n  "saturated fat": 20,\n  "trans fat": 0,\n  "polyunsaturated fat": 15,\n  "monounsaturated fat": 25,\n  "sodium": 2.3,\n  "cholesterol": 0.3,\n  "vitamins": {\n    "vitamin a": 0.0009,\n    "vitamin c": 0.09,\n    "vitamin d": 0.000015,\n    "vitamin e": 0.0015,\n    "vitamin k": 0.00012,\n    "thiamin": 0.0012,\n    "riboflavin": 0.0013,\n    "niacin": 0.016,\n    "vitamin b6": 0.0013,\n    "folate": 0.0004,\n    "vitamin b12": 0.0000024\n  },\n  "minerals": {\n    "calcium": 1000,\n    "iron": 0.008,\n    "magnesium": 0.4,\n    "phosphorus": 1.2,\n    "potassium": 4.7,\n    "zinc": 0.011,\n    "iodine": 0.00015,\n    "selenium": 0.000055\n  }\n}\n```',
      ),
    ]),
  ];
}
