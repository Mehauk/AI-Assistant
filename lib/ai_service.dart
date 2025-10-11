import 'package:ai_nutritionist/models/user.dart';
import 'package:ai_nutritionist/secrets.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

abstract class AiService {
  static String? _lastResult;
  static String? _lastResult2;

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
    if (mealTranscription.length < 2) return null;
    return await () async {
      final chat = _model.startChat(history: []);
      final content = Content.text(mealTranscription);

      final response = await chat.sendMessage(content);
      _lastResult = response.text;
      return response.text;
    }();
  }

  static Future<String?> getRequirements(User user) async {
    return await () async {
      final chat = _model.startChat(history: []);
      final message = 'totals for $user';
      final content = Content.text(message);

      final response = await chat.sendMessage(content);
      _lastResult = response.text;
      return response.text;
    }();
  }

  static const _systemInstructions =
      'You are a terse nutrionist.\nYou will be asked by clients about their daily requirements.\nYou will be asked by clients about the nutrional value of a meal.\n\nAlways include only the following in your reponse.\n- calories\n- free sugar\n- intrinsic sugar\n- fibers\n- proteins\n- saturated fat\n- trans fat\n- polyunsaturated fat\n- monounsaturated fat\n- sodium\n- cholesterol\n- vitamins (all)\n- minerals (all)\n\nrespond with JSON and use metric units. Always measure mass in grams, some of the vitamins require really small doses but make sure to measure in grams. for vitamins use vitamin LETTER (NAME) format.\n\nHere is an example response:\n{\n    "calories": 2500,\n    "free sugar": 25,\n    "intrinsic sugar": 50,\n    "fibers": 30,\n    "proteins": 70,\n    "saturated fat": 20,\n    "trans fat": 0,\n    "polyunsaturated fat": 10,\n    "monounsaturated fat": 25,\n    "sodium": 2.3,\n    "cholesterol": 0.3,\n    "vitamins": {\n      "vitaminA (Retinol)": 0.0009,\n      "vitaminB1 (Thiamin)": 0.0012,\n      "vitaminB2 (Riboflavin)": 0.0013,\n      "vitaminB3 (Niacin)": 0.016,\n      "vitaminB5 (Pantothenic acid)": 0.005,\n      "vitaminB6 (Pyridoxine)": 0.0013,\n      "vitaminB7 (Biotin)": 0.00003,\n      "vitaminB9 (Folate)": 0.0004,\n      "vitaminB12 (Cobalamin)": 0.0000024,\n      "vitaminC (Ascorbic acid)": 0.09,\n      "vitaminD (Calciferol)": 0.000015,\n      "vitaminE (Tocopherol)": 0.0015,\n      "vitaminK (Phylloquinone)": 0.00012\n   },\n   "minerals": {\n      "calcium": 1000,\n      "iron": 0.008,\n      "magnesium": 0.4,\n      "phosphorus": 1.0,\n      "potassium": 4.7,\n      "zinc": 0.011,\n      "iodine": 0.00015,\n      "selenium": 0.000055,\n      "copper": 0.0009,\n      "manganese": 0.0023,\n      "chromium": 0.000035,\n      "molybdenum": 0.000045,\n   }\n  }\n';
}
