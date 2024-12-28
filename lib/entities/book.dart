import 'package:flutter/material.dart';

class Book {
  final String cover;
  final String title;
  final String publisher;
  final String publishDate;
  final String isbn13;
  final String description;
  final String? subtitle;
  final String? series;
  final int numberOfPages;

  Book({
    required this.cover,
    required this.title,
    required this.publisher,
    required this.publishDate,
    required this.isbn13,
    required this.description,
    this.subtitle,
    this.series,
    required this.numberOfPages,
  });

  Map<String, dynamic> toJson() {
    return {
      'cover': cover,
      'title': title,
      'publisher': publisher,
      'publishDate': publishDate,
      'isbn13': isbn13,
      'description': description,
      'subtitle': subtitle,
      'series': series,
      'numberOfPages': numberOfPages,
    };
  }

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      cover: json['cover'],
      title: json['title'],
      publisher: json['publisher'],
      publishDate: json['publishDate'],
      isbn13: json['isbn13'],
      description: json['description'],
      subtitle: json['subtitle'],
      series: json['series'],
      numberOfPages: json['numberOfPages'],
    );
  }
}
