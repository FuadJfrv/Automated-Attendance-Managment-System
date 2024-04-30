import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';


class FaceIdentificationPrompt extends StatefulWidget {
  final String participantEmail;
  final int meetingId;

  const FaceIdentificationPrompt({super.key, required this.participantEmail, required this.meetingId});

  @override
  State<FaceIdentificationPrompt> createState() => _FaceIdentificationPromptState();
}

class _FaceIdentificationPromptState extends State<FaceIdentificationPrompt> {
  final ImagePicker _picker = ImagePicker();
  bool verified = false;
  late int id;

  Future<XFile?> captureImage() async {
    // Open camera to capture an image
    return await _picker.pickImage(source: ImageSource.camera);
  }

  Future<String> getImageBase64(XFile? image) async {
    File imageFile = File(image!.path);
    List<int> imageBytes = await imageFile.readAsBytes();
    return base64Encode(imageBytes);
  }

  Future<void> sendImageToRekognition(String imageBase64) async {
    var url = Uri.parse('https://lxmz2mxgj8.execute-api.eu-west-2.amazonaws.com/beta/facial-identification');
    var headers = {'Content-Type': 'application/json'};
    var body = jsonEncode({'imageData': imageBase64});

    var response = await http.post(url, headers: headers, body: body);
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      print("DATA: $data");
      bool identified = false;
      for (var participant in data) {
        if (participant['FullName'] == "$id" && participant['Confidence'] >= 98) {
          identified = true;

          return context.go("/participant/${widget.participantEmail}/recorded/${widget.meetingId}");
        }
      }
      if (!identified) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text('We were not able to identify you. Please try again.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }

    } else {
      print("Failed with status code: ${response.statusCode}");
      print("Error: ${response.body}");
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('Failed with status code: ${response.statusCode}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void processImageFromCamera() async {
    final XFile? image = await captureImage();
    if (image != null) {
      final String imageBase64 = await getImageBase64(image);
      await sendImageToRekognition(imageBase64);
    }
  }

  @override
  void initState() {
    super.initState();
    getPrefs();
  }

  void getPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    id = (await prefs.getInt("participantId"))!;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AWS Rekognition Test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.face,
              size: 200.0,
              color: Colors.grey,
            ),
            SizedBox(
              width: 200,
              height: 100,
              child: ElevatedButton(
                onPressed: processImageFromCamera,
                child: const Text('Verify Identity', style: TextStyle(fontSize: 24),),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
