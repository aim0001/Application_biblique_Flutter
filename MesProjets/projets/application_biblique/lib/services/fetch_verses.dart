import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:application_biblique/models/verse.dart';
import 'package:application_biblique/providers/main_provider.dart';

// Classe chargée de récupérer les versets d'un fichier JSON

class FetchVerses {
  // Méthode statique pour exécuter le processus de récupération
  static Future<void> execute({required MainProvider mainProvider}) async {
    // Charge le contenu du fichier JSON sous forme de chaîne depuis le dossier Assets
    String jsonString = await rootBundle.loadString('assets/kjv.json');

    // Décode la chaîne JSON en une liste d'objets dynamiques
    List<dynamic> jsonList = json.decode(jsonString);

    // Parcourez chaque objet JSON, puis convertissez-le en vers et ajoutez-le à la liste du fournisseur

    for (var json in jsonList) {
      mainProvider.addVerse(verse: Verse.fromJson(json));
    }
  }
}
