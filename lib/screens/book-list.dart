import 'package:flutter/material.dart';

class BookList extends StatefulWidget {
  const BookList({super.key});

  @override
  State<BookList> createState() => _BookListState();
}

class _BookListState extends State<BookList> {
  final List<Widget> items = [
    BookCard(),
    BookCard(),
    BookCard(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('FAB Pressed')),
          );
        },
        elevation: 10,
        backgroundColor: Colors.black,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return items[index];
        },
      ),
    );
  }
}

class BookCard extends StatefulWidget {
  const BookCard({super.key});

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
          child: Row(children: [
            Container(color: Colors.blue,width: 150,height: 200,),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Titulo",style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),),
                  Text("ISBN",style: TextStyle(fontSize: 20),),
                  Text("Data da leitura",style: TextStyle(fontSize: 20),)
                ],
              ),
            )
          ],)
        ),
      ),
    );
  }
}
