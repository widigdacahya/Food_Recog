import 'dart:io';
import 'dart:isolate';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class FoodClassifier {
  Interpreter? _interpreter;
  List<String>? _labels;

  Future<void> init() async {
    try {
      _interpreter =  await Interpreter.fromAsset('assets/1.tflite');

      final labelData = await rootBundle.loadString('assets/probability-labels-en.txt');
      _labels = labelData.split('\n').where((e) => e.isNotEmpty).toList();
    } catch(e) {
      print("Error model initialization");
    }
  }


  Future<Map<String, dynamic>?> predict(File imageFile) async {
    if(_interpreter == null || _labels == null) return null;

    final imageBytes = await imageFile.readAsBytes();

    // get rid to background thread so UI wouldnt freeze
    return await Isolate.run(() => _runInference(
      imageBytes,
      _interpreter!.address,
      _labels!
    ));
  }


  static Map<String, dynamic>? _runInference(Uint8List imageBytes, int interpreterAddress, List<String> labels) {
    final interpreter = Interpreter.fromAddress(interpreterAddress);

    final inputTensor = interpreter.getInputTensor(0);
    final inputShape = inputTensor.shape;
    final inputType = inputTensor.type;

    final int width = inputShape[1];
    final int height = inputShape[2];

    img.Image? decodedImage = img.decodeImage(imageBytes);

    if (decodedImage == null) return null;

    img.Image resizedImage = img.copyResize(decodedImage, width: width, height: height);


    Object input;

    if (inputType == TensorType.float32) {
      input = List.generate(1, (i) => List.generate(height, (y) => List.generate(width, (x) {
        final pixel = resizedImage.getPixel(x, y);
        return [pixel.r / 255.0, pixel.g / 255.0, pixel.b / 255.0];
      })));
    } else {
      input = List.generate(1, (i) => List.generate(height, (y) => List.generate(width, (x) {
        final pixel = resizedImage.getPixel(x, y);
        return [pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt()]; // tanpa normalisasi
      })));
    }

    final outputTensor = interpreter.getOutputTensor(0);
    final outputShape = outputTensor.shape;
    final outputType = outputTensor.type;

    Object output;
    if (outputType == TensorType.float32) {
      output = List.generate(1, (i) => List.filled(outputShape[1], 0.0));
    } else {
      output = List.generate(1, (i) => List.filled(outputShape[1], 0));
    }

    // model execution 🤖
    interpreter.run(input, output);


    // looking for highest confidence 🔎
    double maxScore = 0.0;
    int maxIndex = 0;

    if (outputType == TensorType.float32) {
      final result = (output as List)[0] as List<double>;

      for (int i = 0; i < result.length; i++) {
        if (result[i] > maxScore) {
          maxScore = result[i];
          maxIndex = i;
        }
      }

    } else {
      final result = (output as List)[0] as List<int>;

      for (int i = 0; i < result.length; i++) {
        if (result[i] > maxScore) {
          maxScore = result[i].toDouble();
          maxIndex = i;
        }
      }
      maxScore = maxScore / 255.0;
    }

    return {
      'label': labels[maxIndex],
      'confidence': maxScore,
    };


  }


}