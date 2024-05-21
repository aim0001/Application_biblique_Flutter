import 'package:shared_preferences/shared_preferences.dart';

// Classe responsable de la sauvegarde de l'index actuel dans SharedPreferences

class SaveCurrentIndex {
  // Méthode statique pour exécuter le processus de sauvegarde
  static Future<void> execute({required int index}) async {
    // Obtention d'une instance de SharedPreferences
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();

    // Enregistre l'index actuel dans SharedPreference
    sharedPreferences.setInt('index', index);
  }
}
