import 'package:flutter/material.dart';
import 'package:application_biblique/models/verse.dart';
import 'package:application_biblique/providers/main_provider.dart';
import 'package:provider/provider.dart';

class VerseWidget extends StatelessWidget {
  final Verse verse;
  final int index;
  const VerseWidget({super.key, required this.verse, required this.index});

  @override
  Widget build(BuildContext context) {
    // Utilisation d'un widget Consumer pour écouter les modifications dans MainProvider
    return Consumer<MainProvider>(
      builder: (context, mainProvider, child) {
        // Vérifiez si le verset actuel est sélectionné
        bool isSelected = mainProvider.selectedVerses.any((e) => e == verse);
        return ListTile(
          onTap: () {
            // sélectionne ou désélectionne le verset
            mainProvider.toggleVerse(verse: verse);
          },
          title: RichText(
            text: TextSpan(
              style: DefaultTextStyle.of(context).style,
              children: <TextSpan>[
                // TextSpan pour le numéro de chapitre ou de verset
                TextSpan(
                  text: verse.verse == 1
                      ? "${verse.chapter}"
                      : "${verse.verse.toString()} ",
                  style: TextStyle(
                    fontSize: verse.verse == 1 ? 45 : 12,
                    fontWeight:
                        verse.verse == 1 ? FontWeight.bold : FontWeight.w500,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                // TextSpan pour le texte du verset
                TextSpan(
                  text: verse.text.trim(),
                  style: TextStyle(
                    color: isSelected ? Theme.of(context).colorScheme.primary : null,
                    decorationColor: Theme.of(context).colorScheme.primary,
                    decorationStyle: TextDecorationStyle.dotted,
                    decoration: isSelected ? TextDecoration.underline : null,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
