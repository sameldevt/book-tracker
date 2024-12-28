import 'dart:io';

import 'package:book_tracker/screens/book-list-screen.dart';
import 'package:book_tracker/services/book-service.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../entities/book.dart';
import '../services/isbn-service.dart';

class AddBookScreen extends StatefulWidget {
  final Book book;

  const AddBookScreen({super.key, required this.book});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Adicionar livro',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.network(
                  widget.book.cover,
                  width: 300,
                  height: 400,
                  fit: BoxFit.cover,
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.book.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                ),
                Text(
                  widget.book.subtitle ?? "",
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                Text(
                  widget.book.publisher,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                SizedBox(height: 10,),
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    widget.book.description,
                    style: const TextStyle(fontSize: 14),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: 10,),
                Text(
                  'ISBN: ${widget.book.isbn13}',
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                )
              ],
            ),
            InkWell(
              onTap: () async {
                await BookService().saveBook(widget.book);

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const BookListScreen()),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.deepPurpleAccent,
                  borderRadius: BorderRadius.circular(6),
                ),
                width: double.maxFinite,
                height: 46,
                child: const Center(
                  child: Text(
                    'Adicionar',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      )
    );
  }

  Future<String?> _extractNumbers(File file) async {
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final InputImage inputImage = InputImage.fromFile(file);

    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);

    String text = recognizedText.text;
    String numbersOnly = text.replaceAll(RegExp(r'[^0-9]'), '');

    textRecognizer.close();

    return numbersOnly.isNotEmpty ? numbersOnly : null;
  }
}
