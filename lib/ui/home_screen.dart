import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
        setState(() {
          _selectedImage = File(croppedFile.path);
        });
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
            Container(),

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
