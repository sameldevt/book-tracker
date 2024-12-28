import 'package:flutter/material.dart';

class Book {
  final Widget cover;
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
}
