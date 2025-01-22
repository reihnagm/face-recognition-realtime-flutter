import 'dart:developer';
import 'dart:io';

import 'dart:typed_data';

import 'package:image/image.dart' as img;

import 'package:path_provider/path_provider.dart';

class StorageHelper {

  static Future<Directory> getStorageDirectory() async {
    if (Platform.isAndroid) {
      return Directory("/storage/emulated/0/Download");
    } else {
      return await getApplicationDocumentsDirectory();
    }
  }

  static Future<void> saveImageToDownloads({
    required img.Image image, 
    required String filename
  }) async {
    Directory directory = Directory(""); 
    
    if (Platform.isAndroid) { 
      directory = Directory("/storage/emulated/0/Download"); 
    } else { 
      directory = await getApplicationDocumentsDirectory(); 
    }
  
    final exPath = directory.path;

    final file = File('$exPath/$filename');

    final imageBytes = Uint8List.fromList(img.encodePng(image));
    
    await file.writeAsBytes(imageBytes);

    log('IMG saved to ${file.path}');
  }

}