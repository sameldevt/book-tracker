import 'dart:io';

import 'package:book_tracker/screens/book-list.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const BookList(),
    );
  }
}

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  File? selectedMedia;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildUI(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final ImagePicker picker = ImagePicker();
          final photo = await picker.pickImage(source: ImageSource.camera);

          if(photo != null){
            setState(() {
              selectedMedia = File(photo.path);
            });

          }
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildUI(){
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _imageView(),
        _extractTextView(),
      ],
    );
  }

  Widget _imageView(){
    if(selectedMedia == null){
      return Center(
        child: Text("pick an image for thext generation"),
      );
    }
    return Center(child: Image.file(selectedMedia!, width: 200,),);
  }

  Widget _extractTextView(){
    if(selectedMedia == null){
      return Center(
        child: Text("no result"),
      );
    }
    return FutureBuilder(future: _extractText(selectedMedia!), builder: (context, snapshot){
      return Text(snapshot.data ?? "");
    });
  }

  Future<String?> _extractText(File file) async {
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final InputImage inputImage = InputImage.fromFile(file);
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

    String text = recognizedText.text;
    textRecognizer.close();

    return text;
  }
}
