import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:tmp_app/consts.dart';

void main() {
  runApp(const TryOnApp());
}

class TryOnApp extends StatelessWidget {
  const TryOnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Virtual try on app',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Virtual try on app Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String personId = '';

  void _tryImg1(String clothesId) async {
    Map<String, dynamic> requestBody = {
      'person_image_id': personId,
      'clothes_image_id': clothesId,
    };

    var request = http.Request(post, Uri.parse(styleImageURL));
    request.headers[contentType] = applicationJSON;
    request.body = jsonEncode(requestBody);

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      print('Image uploaded successfully');
      print('Response body: $responseBody');
      String styledPersonID = responseBody;
      downloadImage(styledPersonID);
      return;
    }

    print('Image upload failed');
    print('Response status: ${response.statusCode}');
    print('Response body: $responseBody');
  }

  void downloadImage(String imageID) async {
    Map<String, dynamic> requestBody = {
      'id': imageID,
    };

    var request = http.Request(post, Uri.parse(getImageURL));
    request.body = jsonEncode(requestBody);

    var response = await request.send();
    var responseBody = response.stream.toBytes() as Uint8List;

    if (response.statusCode == 200) {
      print('Image uploaded successfully');
      print('Response body: $responseBody');
      setState(() {
        containerImage = Image.memory(responseBody);
      });
      return;
    }

    print('Image upload failed');
    print('Response status: ${response.statusCode}');
    print('Response body: $responseBody');
  }

  Uint8List imageBytes = Uint8List(0);
  Image? containerImage;
  void pickImageFromGallery1() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery); //ImageSource.camera
    if (pickedImage != null) {
      imageBytes = await pickedImage.readAsBytes();
      setState(() {
        containerImage = Image.memory(imageBytes);
      });
    }

    var request = http.Request(post, Uri.parse(saveImageURL));
    request.bodyBytes = imageBytes;
    request.headers[contentType] = imagePNG;

    var response = await request.send();
    var responseBodyStr = await response.stream.bytesToString();
    var responseBody = jsonDecode(responseBodyStr);

    if (response.statusCode == 200) {
      print('Image uploaded successfully');
      personId = responseBody["image_id"];
      print('personId: $personId');
      return;
    }

    print('Image upload failed');
    print('Response status: ${response.statusCode}');
    print('Response body: $responseBodyStr');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        toolbarHeight: MediaQuery.of(context).size.height * 3/30,
      ),
      body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 30, vertical: MediaQuery.of(context).size.height / 60),
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 14/15,
                height: MediaQuery.of(context).size.height * 29/60,
                margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height / 60),
                decoration: BoxDecoration( //здесь будет фото человека
                  border: Border.all(
                    color: Colors.black,
                    width: 2,
                  ),
                ),
                child: containerImage ?? const Text('Photo not selected'),
              ),
              Container(
                margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height / 60),
                height: MediaQuery.of(context).size.height / 20,
                child: TextButton(
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                  ),
                  onPressed:  pickImageFromGallery1, //_uploadPhoto,
                  child: const Text('Upload Photo'),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 14/15,
                height: MediaQuery.of(context).size.height * 15/60,
                alignment: Alignment.center,
                margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height / 60),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 11/45,
                                height: MediaQuery.of(context).size.height * 4/30,
                                child: Image.asset("assets/images/img$index.jpg", fit:BoxFit.scaleDown),
                              ),
                              TextButton(
                                style: ButtonStyle(
                                  foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                                ),
                                onPressed:(){
                                  _tryImg1(index.toString());
                                },
                                child: const Text('Try'),
                              ),
                            ],
                          ),
                        SizedBox(width: MediaQuery.of(context).size.width * 3/45), // Расстояние между контейнерами
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
      ),
    );
  }
}
