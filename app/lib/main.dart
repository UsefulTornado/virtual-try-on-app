import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
  void _uploadPhoto() { // поменять функцию
    setState(() {
      http.get(Uri.parse('http://iocontrol.ru/api/sendData/alina/bulb_1/1')).then((response) {
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");
      }).catchError((error){
        print("Error: $error");
      });
    });
  }

  void _tryImg(int index) { // поменять функцию
    setState(() {
      print(index);
      http.get(Uri.parse('http://iocontrol.ru/api/sendData/alina/bulb_1/1')).then((response) {
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");
      }).catchError((error){
        print("Error: $error");
      });
    });
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
                child: const Text('Photo'),
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
                  onPressed: _uploadPhoto,
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
