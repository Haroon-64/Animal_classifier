import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;
  final imagePicker = ImagePicker();
  XFile? _image;
  List prediction = [];

  @override
  void initState() {
    loadModel();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  loadModel() async {
    await Tflite.loadModel(
      model: "assets/model/model.tflite",
      labels: "assets/model/label.csv",
    );
  }

  detectImage(File image) async {
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 9,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );

    setState(() {
      isLoading = false;
      prediction = output!;
    });
  }

  Future<void> loadImageFromGallery() async {
    final ImagePicker imagePicker = ImagePicker();

    try {
      XFile? image = await imagePicker.pickImage(source: ImageSource.gallery);

      if (image == null) {
        return;
      } else {
        setState(() {
          isLoading = false;
        });
        _image = XFile(image.path);
      }
      if (_image == null) {
      } else {
        detectImage(File(_image!.path));
      }
    } catch (e) {
      print('Error selecting image: $e');
    }
  }

  Future<void> loadImageFromCamera() async {
    final ImagePicker imagePicker = ImagePicker();

    try {
      XFile? image = await imagePicker.pickImage(source: ImageSource.camera);

      if (image == null) {
        return;
      } else {
        setState(() {
          isLoading = false;
        });
        _image = XFile(image.path);
      }
      if (_image == null) {
      } else {
        detectImage(File(_image!.path));
      }
    } catch (e) {
      print('Error selecting image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Image.asset('assets/images/icon.png', height: 100, width: 100),
              const Text(
                "Animal Classifier",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    loadImageFromCamera();
                  },
                  child: const Text("Capture"),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    loadImageFromGallery();
                  },
                  child: const Text("Gallery"),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                width: double.infinity,
                child: _image == null
                    ? const SizedBox()
                    : prediction.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : Column(
                            children: [
                              Image.file(File(_image!.path)),
                              const SizedBox(height: 20),
                              Text(prediction[0]['label'].toString(),
                                  style: const TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold)),
                              Text(
                                "Confidence: ${prediction[0]['confidence']}",
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
