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

    setState(() {
      selectedImage = XFile( "assets/images/img$index.jpg"); //проверка, как обновляется фото
    });
  }

// загрузка фото из галереи
  XFile? selectedImage;
  void pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery); //ImageSource.camera
    if (pickedImage != null) {
      setState(() {
        selectedImage = pickedImage;
      });
    }
  }

  void _tryImgg(int id) async {
    final url = Uri.parse('http://example.com/upload'); // Замените на свой URL сервера
    final request = http.MultipartRequest('POST', url);
    request.files.add(await http.MultipartFile.fromPath('image',  selectedImage!.path)); //заполняем фото человека
    request.fields['id'] = id.toString(); //заполняем id

    final response = await request.send(); //отправляем

    if (response.statusCode == 200) {
      // Обработка успешной отправки фотографии на сервер
      print('Фотография успешно отправлена на сервер');
    } else {
      // Обработка ошибки при отправке фотографии на сервер
      print('Ошибка при отправке фотографии на сервер');
    }
    Timer.periodic(Duration(seconds: 20), (timer) {
      // Вызов другой функции
      print("запрос в базу о готовности"); //если готово вызываем функцию downloadImage()
    });
  }



  void downloadImage() async {
    final response = await http.get(Uri.parse('http://example.com/download'));

    if (response.statusCode == 200) {
      // Обработка успешного получения фотографии с сервера
      final bytes = response.bodyBytes;
      //для преобразования байтов в XFile
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;
      String tempFilePath = '$tempPath/temp_file.bin';

      File tempFile = File(tempFilePath);
      await tempFile.writeAsBytes(bytes);
      setState(() {
        selectedImage = XFile(tempFilePath);
      });

      // Дальнейшая обработка полученных байтов фотографии
      print('Фотография успешно получена с сервера');
    } else {
      // Обработка ошибки при получении фотографии с сервера
      print('Ошибка при получении фотографии с сервера');
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
                child: selectedImage != null ? Image.network(selectedImage!.path, fit:BoxFit.scaleDown) : const Text('Photo not selected'),
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
                  onPressed:  pickImageFromGallery, //_uploadPhoto,
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
