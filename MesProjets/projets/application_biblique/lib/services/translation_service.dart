// services/translation_service.dart
import 'package:translator/translator.dart';

class TranslationService {
  final translator = GoogleTranslator();

  Future<String> translateText(String text, String targetLanguageCode) async {
    Translation translation = await translator.translate(text, to: targetLanguageCode);
    return translation.text;
  }
}
