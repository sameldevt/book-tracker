import 'dart:io';

import 'package:book_tracker/screens/add-book-screen.dart';
import 'package:book_tracker/services/book-service.dart';
import 'package:book_tracker/services/isbn-service.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        title: Text(
          'Livros lidos',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                title: Text('Adicionar livro'),
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
                              SizedBox(height: 6),
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
                              SizedBox(height: 6),
                              InkWell(
                                onTap: () {
                  
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
            },
          );
        },
        elevation: 10,
        backgroundColor: Colors.deepPurple,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: FutureBuilder<List<Book>>(
        future: BookService().loadBooks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            print(snapshot.stackTrace);
            return Center(
                child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(
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
      ),
    );
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
          // Exibe mensagem de erro com melhor formatação
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


  Widget _buildBookCard() {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Adicionar livro',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            elevation: 12,
            child: SizedBox(
                width: double.maxFinite,
                height: 200,
                child: Row(
                  children: [
                    Image.network(
                      book!.cover,
                      width: 300,
                      height: 400,
                      fit: BoxFit.cover,
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book!.title,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          Text(
                            book!.subtitle ?? "",
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                          Text(
                            book!.publisher,
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                          Container(
                            width: 200,
                            child: Text(
                              book!.description,
                              style: TextStyle(fontSize: 14),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            book!.isbn13,
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
        ),
      ),
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
                        style: TextStyle(color: Colors.grey, fontSize: 14),
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
