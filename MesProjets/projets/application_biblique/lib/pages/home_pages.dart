import 'package:flutter/material.dart';
import 'package:application_biblique/services/read_last_index.dart';
import 'package:application_biblique/pages/books_page.dart';
import 'package:application_biblique/pages/search_page.dart';
import 'package:application_biblique/pages/translated_page.dart'; 
import 'package:application_biblique/providers/main_provider.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:clipboard/clipboard.dart';
import 'package:translator/translator.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showShareButton = false;
  var translator = GoogleTranslator();
  var languageList = ["fr", "en", "ja", "de"];
  String _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    Future.delayed(
      const Duration(milliseconds: 100),
      () async {
        MainProvider mainProvider = Provider.of<MainProvider>(context, listen: false);
        await ReadLastIndex.execute().then((index) {
          if (index != null) {
            mainProvider.scrollToIndex(index: index);
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MainProvider>(
      builder: (context, mainProvider, child) {
        final verses = mainProvider.verses;
        final currentVerse = mainProvider.currentVerse;
        final isSelected = mainProvider.selectedVerses.isNotEmpty;

        return Scaffold(
          appBar: AppBar(
            title: currentVerse == null || isSelected
                ? null
                : GestureDetector(
                    onTap: () {
                      Get.to(
                        () => BooksPage(chapterIdx: currentVerse.chapter, bookIdx: currentVerse.book),
                        transition: Transition.leftToRight,
                      );
                    },
                    child: Text(currentVerse.book),
                  ),
            actions: [
              IconButton(
                onPressed: () async {
                  final selectedLanguage = await showDialog<String>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Choisissez une langue'),
                        content: StatefulBuilder(
                          builder: (BuildContext context, StateSetter setState) {
                            return DropdownButton<String>(
                              value: _selectedLanguage,
                              onChanged: (newValue) {
                                setState(() {
                                  _selectedLanguage = newValue!;
                                });
                              },
                              items: languageList.map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            );
                          },
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(_selectedLanguage);
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                  if (selectedLanguage != null) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => TranslatedPage(language: selectedLanguage),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.language),
              ),
              if (isSelected)
                IconButton(
                  onPressed: () async {
                    final string = mainProvider.formattedSelectedVerses();
                    await FlutterClipboard.copy(string).then(
                      (_) {
                        setState(() {
                          _showShareButton = true;
                        });
                      },
                    );
                  },
                  icon: const Icon(Icons.copy_rounded),
                ),
              if (!isSelected)
                IconButton(
                  onPressed: () async {
                    Get.to(
                      () => SearchPage(verses: verses),
                      transition: Transition.rightToLeft,
                    );
                  },
                  icon: const Icon(Icons.search_rounded),
                ),
            ],
          ),
          body: InteractiveViewer(
            maxScale: 4.0,
            minScale: 0.1,
            child: Stack(
              children: [
                ScrollablePositionedList.builder(
                  itemCount: verses.length,
                  itemBuilder: (context, index) {
                    final verse = verses[index];
                    return ListTile(
                      title: Text(verse.text), // Utiliser le texte traduit
                      subtitle: Text('${verse.book} ${verse.chapter}:${verse.verse}'),
                      onTap: () => mainProvider.toggleVerse(verse: verse),
                      selected: mainProvider.selectedVerses.contains(verse),
                    );
                  },
                  itemScrollController: mainProvider.itemScrollController,
                  itemPositionsListener: mainProvider.itemPositionsListener,
                ),
                Visibility(
                  visible: _showShareButton,
                  child: AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    bottom: isSelected ? 16 : -56,
                    left: 16,
                    child: FloatingActionButton(
                      onPressed: () async {
                        final string = mainProvider.formattedSelectedVerses();
                        await FlutterShare.share(title: 'Partager', text: string);
                      },
                      backgroundColor: Colors.white,
                      elevation: 3,
                      child: const Icon(Icons.share, color: Colors.black),
                    ),
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
