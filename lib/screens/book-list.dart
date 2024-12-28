import 'dart:io';

import 'package:book_tracker/services/isbn-service.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

import '../entities/book.dart';

class BookList extends StatefulWidget {
  const BookList({super.key});

  @override
  State<BookList> createState() => _BookListState();
}

class _BookListState extends State<BookList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final ImagePicker picker = ImagePicker();
          final photo = await picker.pickImage(source: ImageSource.camera);

          if (photo != null) {
            final file = File(photo.path);
            final isbn = await _extractNumbers(file);

            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => EditImageScreen(
                        image: file,
                        text: isbn!,
                      )),
            );
          }
        },
        elevation: 10,
        backgroundColor: Colors.black,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: FutureBuilder<Book?>(future: IsbnService().getBook('9788545702870'), builder: (context, snapshot){

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator()); // Indicador de carregamento
        }

        if (snapshot.hasError) {
          print(snapshot.stackTrace);
          return Center(child: Text('Error: ${snapshot.error}')); // Erro na requisição
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return Center(child: Text('No data available')); // Caso não haja dados
        }

        final List<Widget> items = [
          BookCard(book: snapshot.data!),
          BookCard(book: snapshot.data!),
          BookCard(book: snapshot.data!),
        ];

        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            return items[index];
          },
        );
      })
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

class EditImageScreen extends StatefulWidget {
  final File image;
  final String text;

  const EditImageScreen({super.key, required this.image, required this.text});

  @override
  State<EditImageScreen> createState() => _EditImageScreenState();
}

class _EditImageScreenState extends State<EditImageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(width: 200, height: 200, child: Image.file(widget.image),),
        
            TextField(
              decoration: InputDecoration(
                hintText: widget.text,
                labelText: 'Campo de Texto',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}

class BookCard extends StatefulWidget {
  final Book book;
  const BookCard({super.key, required this.book});

  @override
  State<BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 12,
        child: SizedBox(
            width: double.maxFinite,
            height: 200,
            child: Row(
              children: [
                widget.book.cover,
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.book.title,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      Text(
                        widget.book.subtitle ?? "",
                        style: TextStyle(
                            color: Colors.grey, fontSize: 14),
                      ),
                      Text(
                        widget.book.publisher,
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      Container(
                        width: 200,
                        child: Text(
                          widget.book.description,
                          style: TextStyle(fontSize: 14),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        widget.book.isbn13,
                        style: TextStyle(fontSize: 14),
                      ),
                      Text(
                        DateTime.now().toString(),
                        style: TextStyle(fontSize: 14),
                      )
                    ],
                  ),
                )
              ],
            )),
      ),
    );
  }
}
