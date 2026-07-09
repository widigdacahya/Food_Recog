import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:foodrecog/service/food_classifier.dart';
import 'package:foodrecog/ui/result_screen.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  FoodClassifier _classifier = FoodClassifier();

  @override
  void initState() {
    super.initState();
    _classifier.init();
  }

  /*
  * Capture or take image (Camera or from Gallery)
  * */
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickeddFile = await _picker.pickImage(source: source);

      if (pickeddFile != null) {
        await _cropImage(pickeddFile.path);
      }

    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  /*
  * Crop the image
  * */
  Future<void> _cropImage(String imagePath) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imagePath,
        compressQuality: 80, // kompres dikit biar more enteng later waktu inferensi ML 😉
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Food Image✂️',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false
          ),
          IOSUiSettings(
            title: 'Crop Food Image✂️',
          )
        ]
      );

      if(croppedFile != null) {
        // setState(() {
        //   _selectedImage = File(croppedFile.path);
        // });

        final imageFile = File(croppedFile.path);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Analyzing food...'))
        );

        final prediction = await _classifier.predict(imageFile);

        if(mounted && prediction != null) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ResultScreen(
                      image: File(croppedFile.path),
                      predictedName: prediction['label'],
                      confidence: prediction['confidence'], // later changed
                  )
              )
          );
        }


      }
    } catch (e) {
      debugPrint("Error cropping image 🛑 : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Food Recognizer',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Preview image area 🌅
            Container(
              height: 300,
              width: 300,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blueGrey),
              ),
              child: _selectedImage != null
                ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                    _selectedImage!,
                    fit: BoxFit.cover
                  ),
                )
                : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_not_supported_outlined,
                    size: 48,
                    color: Colors.grey,
                  )
                ],
              ),
            ),

            SizedBox(height: 32),

            // Action button 🦋
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: Icon(Icons.camera_alt_rounded),
                  label: Text("Camera"),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: Icon(Icons.photo_library_outlined),
                    label: Text('Galery')
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
