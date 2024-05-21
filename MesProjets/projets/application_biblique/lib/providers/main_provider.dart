import 'package:flutter/material.dart';
import 'package:application_biblique/models/book.dart';
import 'package:application_biblique/models/verse.dart';
import 'package:translator/translator.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MainProvider extends ChangeNotifier {
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();

  String _currentLanguageCode = 'en'; // Default language: English
  GoogleTranslator translator = GoogleTranslator();

  List<Verse> verses = [];
  List<Verse> originalVerses = []; // List of original verses
  List<Book> books = [];
  Verse? currentVerse;
  List<Verse> selectedVerses = [];
  List<Verse> translatedVerses = []; // New list for translated verses

  MainProvider() {
    // Initialization of controllers takes place here
  }

  // Method to translate all verses to the specified language
  Future<void> translateAllVerses(String languageCode) async {
  print("Starting translation of verses into $languageCode");
  _currentLanguageCode = languageCode;
  translatedVerses.clear(); // Clear the list of previously translated verses

  try {
    for (var verse in originalVerses) {
      String translatedText = await translateText(verse.text, languageCode);
      Verse translatedVerse = Verse(
        book: verse.book,
        chapter: verse.chapter,
        verse: verse.verse,
        text: translatedText,
        languageCode: languageCode,
      );
      translatedVerses.add(translatedVerse); // Add the translated verse to the new list
    }
    print('Verse translation completed');
  } catch (e, stackTrace) {
    print("Translation error: $e");
    print("Stack trace: $stackTrace");
    // If an error occurs during translation, add the original verses to the translated list
    translatedVerses.addAll(originalVerses);
  } finally {
    notifyListeners(); // Notify listeners after translation (whether successful or not)
  }
}


  Future<String> translateText(String text, String targetLanguage) async {
    final Uri url = Uri.parse(
        'https://translate.googleapis.com/translate_a/single?client=gtx&sl=$_currentLanguageCode&tl=$targetLanguage&dt=t&q=${Uri.encodeComponent(text)}');

    final http.Client client = http.Client();
    final http.Response response = await client.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse[0][0][0];
    } else {
      throw Exception('Failed to load translation');
    }
  }

  // Method to get the current translation language
  String get currentLanguageCode => _currentLanguageCode;

  // Method to add a verse to the list and notify listeners
  void addVerse({required Verse verse}) {
    verses.add(verse);
    originalVerses.add(verse);
    notifyListeners();
  }

  // Method to add a book to the list and notify listeners
  void addBook({required Book book}) {
    books.add(book);
    notifyListeners();
  }

  Future<void> setCurrentLanguage(String languageCode) async {
    await translateAllVerses(languageCode);
  }

  // Method to update the current verse and notify listeners
  void updateCurrentVerse({required Verse verse}) {
    currentVerse = verse;
    notifyListeners();
  }

  // Method to scroll to a specified index
  void scrollToIndex({required int index}) {
    itemScrollController.jumpTo(index: index);
  }

  // Method to toggle the selection state of a verse and notify listeners
  void toggleVerse({required Verse verse}) {
    if (selectedVerses.contains(verse)) {
      selectedVerses.remove(verse);
    } else {
      selectedVerses.add(verse);
    }
    notifyListeners();
  }

  // Method to get the selected verses formatted for sharing or copying
  String formattedSelectedVerses() {
    return selectedVerses.map((verse) {
      return '${verse.book} ${verse.chapter}:${verse.verse} - ${verse.text}';
    }).join('\n');
  }

  // Method to select all verses and notify listeners
  void selectAllVerses() {
    selectedVerses = List<Verse>.from(verses);
    notifyListeners();
  }

  // Method to deselect all verses and notify listeners
  void deselectAllVerses() {
    selectedVerses.clear();
    notifyListeners();
  }

  // New method to clear verses and notify listeners
  void clearVerses() {
    verses.clear();
    notifyListeners();
  }
}

