import 'dart:math';
import 'package:intl/intl.dart';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import '../DB/DatabaseHelper.dart';
import 'Recognition.dart';

class Recognizer {
  late Interpreter interpreter;
  late InterpreterOptions interpreterOptions;
  
  static const int WIDTH = 112;
  static const int HEIGHT = 112;

  final dbHelper = DatabaseHelper();

  Map<String, Recognition> registered = {};
  
  String get modelName => 'assets/mobile_face_net.tflite';

  Recognizer({int? numThreads}) {
    interpreterOptions = InterpreterOptions();

    if (numThreads != null) {
      interpreterOptions.threads = numThreads;
    }

    loadModel();
    initDB();
  }

  initDB() async {
    await dbHelper.init();
    loadRegisteredFaces();
  }

  void loadRegisteredFaces() async {
    registered.clear();
    
    final allRows = await dbHelper.queryAllRows();

    for (final row in allRows) {
      String name = row[DatabaseHelper.columnName];
      List<double> embd = row[DatabaseHelper.columnEmbedding].split(',').map((e) => double.parse(e)).toList().cast<double>();
      Recognition recognition = Recognition(
        row[DatabaseHelper.columnName], 
        row[DatabaseHelper.columnCreatedAt], 
        Rect.zero, embd, 0
      );
      
      registered[name] = recognition;
    }
  }

  void registerFaceInDB(String name, String filename, List<double> embedding) async {
    Map<String, dynamic> row = {
      DatabaseHelper.columnName: name,
      DatabaseHelper.columnPic: filename,
      DatabaseHelper.columnEmbedding: embedding.join(","),
      DatabaseHelper.columnPresenceDate: DateFormat('yyyy-MM-dd').format(DateTime.now().toLocal()),
      DatabaseHelper.columnIsLoggedIn: true.toString(),
      DatabaseHelper.columnCreatedAt: DateFormat('yyyy-MM-dd hh:mm').format(DateTime.now().toLocal()),
    };
    
    await dbHelper.insert(row);

    loadRegisteredFaces();
  }

  Future<void> loadModel() async {
    try {
      interpreter = await Interpreter.fromAsset(
        modelName, 
        options: interpreterOptions
      );
    } catch (e) {
      debugPrint('Unable to create interpreter, Caught Exception: ${e.toString()}');
    }
  }

  List<dynamic> imageToArray(img.Image inputImage) {
    img.Image resizedImage = img.copyResize(inputImage, width: WIDTH, height: HEIGHT);
    List<double> flattenedList = resizedImage.getBytes().map((value) => value.toDouble()).toList();
    Float32List float32Array = Float32List.fromList(flattenedList);
    int channels = 3;
    int height = HEIGHT;
    int width = WIDTH;
    Float32List reshapedArray = Float32List(1 * height * width * channels);
    for (int c = 0; c < channels; c++) {
      for (int h = 0; h < height; h++) {
        for (int w = 0; w < width; w++) {
          int index = c * height * width + h * width + w;
          reshapedArray[index] = (float32Array[index] - 127.5) / 127.5;
        }
      }
    }
    return reshapedArray.reshape([1, 112, 112, 3]);
  }

  Recognition recognize(img.Image image, Rect location) {
    var input = imageToArray(image);

    List output = List.filled(1 * 192, 0).reshape([1, 192]);

    interpreter.run(input, output);

    List<double> outputArray = output.first.cast<double>();

    Pair pair = findNearest(outputArray);

    return Recognition(pair.name, pair.createdAt, location, outputArray, pair.distance);
  }

  Pair findNearest(List<double> emb) {
    Pair pair = Pair("Unknown", "", double.infinity);

    double inputNorm = sqrt(emb.fold(0, (sum, element) => sum + element * element));
    List<double> normalizedEmb = emb.map((e) => e / inputNorm).toList();

    for (var item in registered.entries) {
      final String name = item.key;
      final String createdAt = item.value.createdAt;
      
      List<double> knownEmb = item.value.embeddings;

      // Normalize registered embedding
      double knownNorm = sqrt(knownEmb.fold(0, (sum, element) => sum + element * element));
      List<double> normalizedKnownEmb = knownEmb.map((e) => e / knownNorm).toList();

      // Calculate weighted squared Euclidean distance
      double distance = 0;
      for (int i = 0; i < normalizedEmb.length; i++) {
        double diff = normalizedEmb[i] - normalizedKnownEmb[i];
        distance += diff * diff;
      }

      if (distance < pair.distance) {
        pair.distance = distance;
        pair.name = name;
        pair.createdAt = createdAt;
      }
    }
    return pair;
  }

  void close() {
    interpreter.close();
  }
}

class Pair {
  String name;
  String createdAt;
  double distance;
  Pair(this.name, this.createdAt, this.distance);
}