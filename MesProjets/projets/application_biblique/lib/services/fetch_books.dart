import 'package:application_biblique/models/book.dart';
import 'package:application_biblique/models/chapiter.dart';
import 'package:application_biblique/providers/main_provider.dart';
import 'package:application_biblique/models/verse.dart';

// Classe responsable de la récupération des livres basés sur les versets fournis

class FetchBooks {
  // Méthode statique pour exécuter le processus de récupération
  static Future<void> execute({required MainProvider mainProvider}) async {
    List<Verse> verses = mainProvider.verses;

    // Extraire les titres de livres uniques de la liste des versets
    List<String> bookTitles = verses.map((e) => e.book).toSet().toList();

    // Parcourez chaque titre de livre unique pour organiser les chapitres et les versets
    for (var bookTitle in bookTitles) {
      // Filter verses based on the current book title
      List<Verse> availableVerses =
          verses.where((v) => v.book == bookTitle).toList();

      // Extraire les numéros de chapitre uniques des versets filtrés
      List<int> availableChapters =
          availableVerses.map((e) => e.chapter).toSet().toList();

      List<Chapiter> chapters = [];

      // Parcourez chaque numéro de chapitre unique pour organiser les versets
      for (var element in availableChapters) {
        // Crée un objet Chapitre pour chaque chapitre unique
        Chapiter chapter = Chapiter(
          title: element,
          verses: availableVerses.where((v) => v.chapter == element).toList(),
        );

        chapters.add(chapter);
      }

      // Crée un objet Book pour le titre du livre actuel et ses chapitres organisés
      Book book = Book(title: bookTitle, chapiters: chapters);

      // Ajoute le livre créé à la liste des livres du fournisseur principal
      mainProvider.addBook(book: book);
    }
  }
}
