import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
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

  void _tryImg(int index) { // временно, чтобы ничего не ломалось
    print(index);
  }

  void _tryImg1(String clothesId) async {
    String newPersonId = '';
    // Создание тела запроса с изображением в байтовом виде
    Map<String, dynamic> requestBody = {
      'person_image_id': personId,
      'clothes_image_id': clothesId,
    };

    // Отправка POST-запроса на сервер
    http.Response response = await http.post(
      Uri.parse('http://127.0.0.1:1101/api/style_image'),
      body: jsonEncode(requestBody),
    );

    // Обработка ответа от сервера
    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      setState(() {
        newPersonId = responseData['id'];
      });
      print('Изображение успешно отправлено на сервер. ID сгенерированного изображения: $newPersonId');
    } else {
      print('Ошибка при отправке изображения на сервер');
    }


    Timer.periodic(Duration(seconds: 20), (timer) {
      // Вызов другой функции
      print("запрос в базу о готовности"); //если готово вызываем функцию downloadImage(newPersonId)
    });
  }



  void downloadImage(String newPersonId) async {
    // Создание тела запроса с изображением в байтовом виде
    Map<String, dynamic> requestBody = {
      'id': newPersonId,
    };

    // Отправка POST-запроса на сервер
    http.Response response = await http.post(
      Uri.parse('http://192.168.1.78:1101/api/get_image'),
      body: jsonEncode(requestBody),
    );

    // Обработка ответа от сервера
    if (response.statusCode == 200) {
      final modifiedImageBytes = response.bodyBytes;
      setState(() {
        containerImage = Image.memory(modifiedImageBytes);
      });
      print('Изображение успешно обработано');
    } else {
      print('Ошибка при получении');
    }
  }

  Uint8List imageBytes = Uint8List(0);
  Image? containerImage;
  String personId = '';
  void pickImageFromGallery1() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery); //ImageSource.camera
    if (pickedImage != null) {
      imageBytes = await pickedImage.readAsBytes();
      setState(() {
        containerImage = Image.memory(imageBytes);
      });
    }

    for (var i = 0; i < 8; ++i) {
      print(imageBytes[i]);
    }

    // Создание тела запроса с изображением в байтовом виде
    Map<String, dynamic> requestBody = {
      'image': imageBytes,
    };
    print('------------------');
    var request = http.Request('post', Uri.parse('http://192.168.1.78:1101/api/save_image'));
    request.bodyBytes = imageBytes;
    request.headers["Content-Type"] = "image/png";

    var response = await request.send();

    var responseBody = await response.stream.toBytes();

    // Handle the response
    if (response.statusCode == 200) {
      print('Image uploaded successfully');
      print('Response body: $responseBody');
    } else {
      print('Image upload failed');
      print('Response status: ${response.statusCode}');
      print('Response body: $responseBody');
    }
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
                                  _tryImg(index);
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
