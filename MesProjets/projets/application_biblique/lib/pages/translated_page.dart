import 'dart:async';
import 'package:flutter/material.dart';
import 'package:application_biblique/providers/main_provider.dart';
import 'package:clipboard/clipboard.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:application_biblique/pages/books_page.dart';

class TranslatedPage extends StatefulWidget {
  final String language;

  const TranslatedPage({Key? key, required this.language}) : super(key: key);

  @override
  _TranslatedPageState createState() => _TranslatedPageState();
}

class _TranslatedPageState extends State<TranslatedPage> {
  bool _isLoading = true;
  late Timer _loadingTimer;
  String _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.language;
    _startLoadingTimer();
    _translateVerses();
  }

  void _startLoadingTimer() {
    _loadingTimer = Timer(Duration(seconds: 5), () {
      if (_isLoading) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _translateVerses() async {
    MainProvider mainProvider = Provider.of<MainProvider>(context, listen: false);
    await mainProvider.setCurrentLanguage(widget.language);
    _stopLoading();
  }

  void _stopLoading() {
    if (_isLoading) {
      setState(() {
        _isLoading = false;
      });
    }
    _loadingTimer.cancel();
  }

  @override
  void dispose() {
    _loadingTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MainProvider>(
      builder: (context, mainProvider, child) {
        final verses = mainProvider.translatedVerses;
        final currentVerse = mainProvider.currentVerse;
        final isSelected = mainProvider.selectedVerses.isNotEmpty;

        return Scaffold(
          appBar: AppBar(
            title: currentVerse == null || isSelected
                ? Text('Bible (${_selectedLanguage.toUpperCase()})')
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
                              items: ["fr", "en", "ja", "de"].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            );
                          },
                        ),
                        actions                     : <Widget>[
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
                Navigator.of(context).pushReplacement(
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
                      // Update the UI to show that copying is done
                    });
                  },
                );
              },
              icon: const Icon(Icons.copy_rounded),
            ),
        ],
      ),
      body: InteractiveViewer(
        maxScale: 4.0,
        minScale: 0.1,
        child: Stack(
          children: [
            ListView.builder(
              itemCount: verses.length,
              itemBuilder: (context, index) {
                final verse = verses[index];
                return ListTile(
                  title: Text(verse.text),
                  subtitle: Text('${verse.book} ${verse.chapter}:${verse.verse}'),
                  onTap: () => mainProvider.toggleVerse(verse: verse),
                  selected: mainProvider.selectedVerses.contains(verse),
                );
              },
            ),
            if (_isLoading)
              Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  },
);
  }}
