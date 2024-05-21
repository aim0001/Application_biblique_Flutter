import 'package:shared_preferences/shared_preferences.dart';

// Classe responsable de la lecture du dernier index enregistré depuis SharedPreference

class ReadLastIndex {
  // Méthode statique pour exécuter le processus de lecture
  static Future<int?> execute() async {
    // Obtention d'une instance de SharedPreference
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();

    // Récupère le dernier index enregistré depuis SharedPreferences
    return sharedPreferences.getInt('index');
  }
}
