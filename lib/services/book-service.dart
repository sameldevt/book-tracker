import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../entities/book.dart';

class BookService {
  final String _key = 'books';

  Future<void> saveBook(Book book) async {
    final prefs = await SharedPreferences.getInstance();

    final books = await loadBooks();
    books.add(book);

    final booksJson = books.map((book) => book.toJson()).toList();
    await prefs.setString(_key, jsonEncode(booksJson));
  }

  Future<List<Book>> loadBooks() async {
    final prefs = await SharedPreferences.getInstance();

    final booksJson = prefs.getString(_key);
    if (booksJson == null) {
      return [];
    }

    final List<dynamic> decoded = jsonDecode(booksJson);
    return decoded.map((json) => Book.fromJson(json)).toList();
  }
}