import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:tmp_app/consts.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:logger/logger.dart';

class TryOnPage extends HookWidget {
  const TryOnPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    final personId = useState('');
    final imageBytes = useState(Uint8List(0));
    final containerImage = useState<Image?>(null);

    var logger = Logger(
      printer: PrettyPrinter(
          methodCount: 1,
          errorMethodCount: 1,
          lineLength: 120,
          colors: true,
          printEmojis: true,
          printTime: false
      ),
    );

    void getImage(String imageID) async {
      Map<String, String> requestBody = {
        'person_image_id': imageID,
      };

      var request = http.Request(post, Uri.parse(getImageURL));
      request.body = jsonEncode(requestBody);

      var response = await request.send();
      var responseBodyStr = await response.stream.bytesToString();
      var personImageStr = jsonDecode(responseBodyStr)["person_image"];

      if (response.statusCode == 200) {
        logger.i('Image got successfully');
        containerImage.value = Image.memory(base64.decode(personImageStr));
        return;
      }

      logger.e('Image getting failed');
      logger.e({'Response body': response, 'Response status': response.statusCode});
    }

    void styleImage(String clothesId) async {
      Map<String, String> requestBody = {
        'person_image_id': personId.value,
        'clothes_image_id': clothesId,
      };

      if (personId.value == "") {
        print('personID is empty');
        return;
      }

      var request = http.Request(post, Uri.parse(styleImageURL));
      request.headers[contentType] = applicationJSON;
      request.body = jsonEncode(requestBody);

      var response = await request.send();
      var responseBodyStr = await response.stream.bytesToString();
      var responseBody = jsonDecode(responseBodyStr);

      if (response.statusCode == 200) {
        logger.i('Image styled successfully');
        var styledPersonID = responseBody;
        getImage(styledPersonID);
        return;
      }

      logger.e('Image styling failed');
      logger.e({'Response body': response, 'Response status': response.statusCode});
    }

    void saveImage() async {
      final picker = ImagePicker();
      final pickedImage = await picker.pickImage(source: ImageSource.gallery);

      if (pickedImage != null) {
        imageBytes.value = await pickedImage.readAsBytes();
        containerImage.value = Image.memory(imageBytes.value);
      }
      
      var request = http.Request(post, Uri.parse(saveImageURL));
      request.bodyBytes = imageBytes.value;
      request.headers[contentType] = imagePNG;


      var response = await request.send();
      var responseBodyStr = await response.stream.bytesToString();
      var responseBody = jsonDecode(responseBodyStr);

      if (response.statusCode == 200) {
        logger.i('Image saved successfully');
        personId.value = responseBody["image_id"];
        return;
      }

      logger.e('Image saving failed');
      logger.e({'Response body': response, 'Response status': response.statusCode});
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
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
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 2,
                ),
              ),
              child: containerImage.value != null ? containerImage.value as Image : const Text('Photo not selected'),
            ),
            Container(
              margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height / 60),
              height: MediaQuery.of(context).size.height / 20,
              child: TextButton(
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                ),
                onPressed: saveImage,
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
                              styleImage(index.toString());
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
