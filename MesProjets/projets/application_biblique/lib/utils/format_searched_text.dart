import 'package:flutter/material.dart';

// Fonction pour formater le texte recherché avec les correspondances en surbrillance
Text formatSearchText({
  required String input,
  required String text,
  required BuildContext context,
}) {
  // Vérifiez si l'entrée ou le texte est vide
  if (input.isEmpty || text.isEmpty) {
    return Text(input);
  }

  // Liste pour stocker les étendues de texte formatées
  List<TextSpan> textSpans = [];

  // Crée une expression régulière insensible à la casse pour le texte recherché
  RegExp regExp = RegExp(text, caseSensitive: false);

  // Recherche toutes les correspondances du texte recherché dans la chaîne d'entrée
  Iterable<Match> matches = regExp.allMatches(input);

  // Initialise l'index actuel
  int currentIndex = 0;

  // Parcourez les matchs
  for (Match match in matches) {
    // Ajouter une étendue de texte ne correspondant pas
    textSpans.add(TextSpan(text: input.substring(currentIndex, match.start)));

    // Ajouter une étendue de texte correspondante avec style
    textSpans.add(
      TextSpan(
        text: input.substring(match.start, match.end),
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    // met à jour l'index actuel
    currentIndex = match.end;
  }

 // Ajoute l'étendue de texte restante qui ne correspond pas
  textSpans.add(TextSpan(text: input.substring(currentIndex)));

  // Renvoie le texte formaté avec des étendues
  return Text.rich(TextSpan(children: textSpans));
}
