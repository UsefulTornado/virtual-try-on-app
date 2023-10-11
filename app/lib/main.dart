import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';


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

    // setState(() {
    //   selectedImage = XFile( "assets/images/img$index.jpg"); //проверка, как обновляется фото
    // });
  }

// загрузка фото из галереи
//   XFile? selectedImage;
//   void pickImageFromGallery() async {
//     final picker = ImagePicker();
//     final pickedImage = await picker.pickImage(source: ImageSource.gallery); //ImageSource.camera
//     if (pickedImage != null) {
//       setState(() {
//         selectedImage = pickedImage;
//       });
//     }
//   }


  void _tryImg1(String clothesId) async {
    String newPersonId = '';
    // Создание тела запроса с изображением в байтовом виде
    Map<String, dynamic> requestBody = {
      'person_image_id': personId,
      'clothes_image_id': clothesId,
    };

    // Отправка POST-запроса на сервер
    http.Response response = await http.post(
      Uri.parse('[host:port]/api/style_image'),
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
      Uri.parse(' [host:port]/api/get_image'),
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

  Uint8List? imageBytes;
  Image? containerImage;
  String personId = '';
  void pickImageFromGallery1() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery); //ImageSource.camera
    if (pickedImage != null) {
      final imageBytes = await pickedImage.readAsBytes();
      setState(() {
        containerImage = Image.memory(imageBytes);
      });
    }

    // Создание тела запроса с изображением в байтовом виде
    Map<String, dynamic> requestBody = {
      'image': base64Encode(imageBytes as List<int>),
    };

    // Отправка POST-запроса на сервер
    http.Response response = await http.post(
      Uri.parse('[host:port]/api/style_image'),
      body: jsonEncode(requestBody),
      headers: {'Content-Type': 'image/png'},
    );

    // Обработка ответа от сервера
    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      setState(() {
        personId = responseData['id'];
      });
      print('Изображение успешно отправлено на сервер. ID изображения: $personId');
    } else {
      print('Ошибка при отправке изображения на сервер');
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
          // decoration: BoxDecoration(
          //   border: Border.all(
          //     color: Colors.black,
          //     width: 2,
          //   ),
          // ),
          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 30, vertical: MediaQuery.of(context).size.height / 60),
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 14/15,
                height: MediaQuery.of(context).size.height * 29/60,
                margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height / 60),
                // child: Image.asset("assets/images/hoodie.jpg", fit:BoxFit.scaleDown),
                decoration: BoxDecoration( //здесь будет фото человека
                  border: Border.all(
                    color: Colors.black,
                    width: 2,
                  ),
                ),
                child: containerImage ?? const Text('Photo not selected'),
                // child: selectedImage != null ? Image.network(selectedImage!.path, fit:BoxFit.scaleDown) : const Text('Photo not selected'),
              ),
              Container(
                margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height / 60),
                height: MediaQuery.of(context).size.height / 30,
                // decoration: BoxDecoration(
                //   border: Border.all(
                //     color: Colors.red,
                //     width: 2,
                //   ),
                // ),
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
                // alignment: Alignment.center,
                margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height / 60),
                // decoration: BoxDecoration(
                //   border: Border.all(
                //     color: Colors.black,
                //     width: 2,
                //   ),
                // ),
                child: ListView.builder(
                  // padding: EdgeInsets.only(right: MediaQuery.of(context).size.width / 30, bottom: MediaQuery.of(context).size.height / 60),
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return Row(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 11/45,
                          height: MediaQuery.of(context).size.height * 6/30,
                          // decoration: BoxDecoration(
                          //   border: Border.all(
                          //     color: Colors.red,
                          //     width: 2,
                          //   ),
                          // ),
                          // child: Image.asset("assets/images/img$index.jpg", fit:BoxFit.scaleDown),
                          child: Column(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 11/45,
                                height: MediaQuery.of(context).size.height * 4/30,
                                // decoration: BoxDecoration(
                                //   border: Border.all(
                                //     color: Colors.green,
                                //     width: 2,
                                //   ),
                                // ),
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
