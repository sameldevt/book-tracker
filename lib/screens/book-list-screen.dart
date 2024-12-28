import 'dart:io';

import 'package:book_tracker/screens/add-book-screen.dart';
import 'package:book_tracker/services/book-service.dart';
import 'package:book_tracker/services/isbn-service.dart';
import 'package:book_tracker/util/date-formatter.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

import '../entities/book.dart';

class BookListScreen extends StatefulWidget {
  const BookListScreen({super.key});

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Book? book;
  File? selectedMedia;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      floatingActionButton: const AddBookFab(),
      body: BookList(),
    );
  }
}

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget{
  const CustomAppBar({super.key});

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: null,
      title: const Text(
        'Livros lidos',
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.deepPurple,
    );
  }
}

class AddBookFab extends StatefulWidget {
  const AddBookFab({super.key});

  @override
  State<AddBookFab> createState() => _AddBookFabState();
}

class _AddBookFabState extends State<AddBookFab> {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const SearchBookDialog();
          },
        );
      },
      backgroundColor: Colors.deepPurple,
      elevation: 10,
      child: const Icon(
        Icons.add,
        color: Colors.white,
      ),
    );
  }
}

class BookList extends StatefulWidget {
  const BookList({super.key});

  @override
  State<BookList> createState() => _BookListState();
}

class _BookListState extends State<BookList> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Book>>(
      future: BookService().loadBooks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          print(snapshot.stackTrace);
          return Center(
              child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(
              child: Text('No data available'));
        }

        final items = snapshot.data;

        return ListView.builder(
          itemCount: items!.length,
          itemBuilder: (context, index) {
            return BookCard(book: items[index]);
          },
        );
      },
    );
  }
}


class SearchBookDialog extends StatefulWidget {
  const SearchBookDialog({super.key});

  @override
  State<SearchBookDialog> createState() => _SearchBookDialogState();
}

class _SearchBookDialogState extends State<SearchBookDialog> {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Book? book;
  File? selectedMedia;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
      title: const Text('Adicionar livro'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              width: double.maxFinite,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Digite o ISBN do livro",
                        labelText: 'ISBN',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'O campo precisa ser preenchido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () async {
                        String isbn = _controller.text;
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => _searchBook(isbn)),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.deepPurple,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        width: double.maxFinite,
                        height: 46,
                        child: const Center(
                          child: Text(
                            'Buscar livro',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () async {
                        final ImagePicker picker = ImagePicker();
                        final photo = await picker.pickImage(source: ImageSource.camera);

                        if(photo != null){
                          var isbn = await _extractNumbers(File(photo.path));
                          _controller.text = isbn!;
                        }
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
                            'Tirar foto',
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
              ),
            ),
          ],
        ),
      ),
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

  Widget _searchBook(String isbn) {
    return FutureBuilder<Book?>(
      future: IsbnService().getBook(isbn),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: Colors.black.withOpacity(0.1),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(
            child: Text(
              'No data available',
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        final Book book = snapshot.data!;

        return AddBookScreen(book: book);
      },
    );
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
    DateTime currentDate = DateTime.now();
    String formattedDate =  DateFormatter().formatDate(currentDate);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 12,
        child: SizedBox(
            width: double.maxFinite,
            height: 200,
            child: Row(
              children: [
                Image.network(
                  widget.book.cover,
                  width: 130,
                  height: 200,
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.book.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      Text(
                        widget.book.subtitle ?? "",
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      Text(
                        widget.book.publisher,
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      Container(
                        width: 200,
                        child: Text(
                          widget.book.description,
                          style: const TextStyle(fontSize: 14),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        'ISBN: ${widget.book.isbn13}',
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      Text(
                        '$formattedDate',
                        style: const TextStyle(fontSize: 14),
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
