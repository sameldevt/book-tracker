import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../entities/book.dart';

class IsbnService {
  final String _baseUrl = 'https://openlibrary.org';
  final String _coverUrl = 'https://covers.openlibrary.org/b/id';

  Future<Book?> getBook(String isbn) async {
    final Uri url = Uri.parse('$_baseUrl/isbn/$isbn.json');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      return Book(
        title: data['title'],
        publisher: data['publisher'] != null
            ? data['publisher'][0]
            : 'Unknown Publisher',
        publishDate: data['publish_date'] ?? 'Unknown Date',
        cover: _getCover(data['covers'][0].toString()),
        isbn13: data['isbn_13'] != null && data['isbn_13'].isNotEmpty
            ? data['isbn_13'][0].toString()
            : '',
        description: data['description'] != null
            ? data['description']['value']
            : 'No Description Available',
        subtitle: data['subtitle'] ?? 'No Subtitle',
        series: data['series'][0] ?? 'No Series',
        numberOfPages: data['number_of_pages'] ?? 0,
      );
    } else {
      return null;
    }
  }

  Widget _getCover(String coverId) {
    return Image.network(
      '$_coverUrl/$coverId-L.jpg',
      width: 130,
      height: 200,
      fit: BoxFit.cover,
    );
  }
}
