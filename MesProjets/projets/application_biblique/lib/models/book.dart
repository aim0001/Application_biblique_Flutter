
import 'package:application_biblique/models/chapiter.dart';

class Book {
  final String title;
  final List<Chapiter> chapiters;
  Book({
    required this.title,
    required this.chapiters,
  });
}
