import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:application_biblique/models/book.dart';
import 'package:application_biblique/models/chapiter.dart';
import 'package:application_biblique/providers/main_provider.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:expandable/expandable.dart';

class BooksPage extends StatefulWidget {
  final int chapterIdx;
  final String bookIdx;
  const BooksPage({super.key, required this.chapterIdx, required this.bookIdx});

  @override
  State<BooksPage> createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage> {
  // AutoScrollController pour le défilement automatique jusqu'au livre sélectionné
  final AutoScrollController _autoScrollController = AutoScrollController();

  // Liste des livres et le livre actuellement sélectionné
  List<Book> books = [];
  Book? currentBook;

  @override
  void initState() {
    // Accès au MainProvider pour obtenir les livres et le livre actuellement sélectionné
    MainProvider mainProvider =
        Provider.of<MainProvider>(context, listen: false);
    books = mainProvider.books;
    currentBook = mainProvider.books.firstWhere(
        (element) => element.title == mainProvider.currentVerse!.book);

    // Trouver l'index du livre actuel et y faire défiler
    int index = mainProvider.books.indexOf(currentBook!);
    _autoScrollController.scrollToIndex(
      index,
      preferPosition: AutoScrollPosition.begin,
      duration: Duration(milliseconds: (10 * books.length)),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MainProvider>(
      builder: (context, mainProvider, child) {
        return ExpandableNotifier(
          child: Scaffold(
            appBar: AppBar(
              title: const Text("Books"),
            ),
            body: ListView.builder(
              itemCount: books.length,
              physics: const BouncingScrollPhysics(),
              controller: _autoScrollController,
              itemBuilder: (context, index) {
                Book book = books[index];
                return AutoScrollTag(
                  key: ValueKey(index),
                  controller: _autoScrollController,
                  index: index,
                  child: ListTile(
                    // ExpandablePanel pour afficher les chapitres lorsque le livre est tapé
                    title: ExpandablePanel(
                      controller: ExpandableController(
                          initialExpanded: currentBook == book),
                      collapsed: const SizedBox.shrink(),
                      header: Text(book.title),
                      expanded: Wrap(
                        children: List.generate(
                          book.chapiters.length,
                          (index) {
                            Chapiter chapter = book.chapiters[index];
                            return SizedBox(
                              height: 45,
                              width: 45,
                              child: GestureDetector(
                                onTap: () {
                                  // Faites défiler jusqu'au chapitre sélectionné et fermez la page
                                  int idx = mainProvider.verses.indexWhere(
                                      (element) =>
                                          element.chapter == chapter.title &&
                                          element.book == book.title);
                                  mainProvider.updateCurrentVerse(
                                      verse: mainProvider.verses.firstWhere(
                                          (element) =>
                                              element.chapter ==
                                                  chapter.title &&
                                              element.book == book.title));
                                  mainProvider.scrollToIndex(index: idx);
                                  Get.back();
                                },
                                child: Card(
                                  // Style basé sur le chapitre sélectionné
                                  color: chapter.title == widget.chapterIdx &&
                                          widget.bookIdx == book.title
                                      ? Theme.of(context)
                                          .colorScheme
                                          .primaryContainer
                                      : null,
                                  elevation: 1,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(7.5)),
                                  child: Center(
                                    child: Text(
                                      chapter.title.toString(),
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
