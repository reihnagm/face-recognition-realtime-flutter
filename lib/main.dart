
import 'dart:io';
import 'package:face_recognition_realtime/auth_menu_page.dart';
import 'package:image/image.dart' as img;

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

// import 'package:dio/dio.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import 'package:face_recognition_realtime/DB/DatabaseHelper.dart';

import 'package:camera/camera.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp>  with WidgetsBindingObserver {
  late DatabaseHelper db;

  img.Image? image;
  String? username;
  String? createdAt;

  bool loading = true;

  Future<void> getData() async {

    await Permission.manageExternalStorage.request().then((value) async {
      if(value == PermissionStatus.denied || value == PermissionStatus.permanentlyDenied) {
        await Permission.manageExternalStorage.request();
      }
    });

    await db.init();

    List data = await db.queryAllRows();

    if(data.isNotEmpty) {

      String presenceDate = data.first['presence_date'];
      
      String getUsername = data.first['name'];
      String getPicture = data.first['picture'];
      String getCreatedAt = data.first['picture'];

      Directory directory = Directory(""); 
  
      if (Platform.isAndroid) { 
        directory = Directory("/storage/emulated/0/Download"); 
      } else { 
        directory = await getApplicationDocumentsDirectory(); 
      }
    
      final exPath = directory.path;

      final file = File('$exPath/$getPicture');

      final imageBytes = await file.readAsBytes();

      final getImage = img.decodeImage(imageBytes);

      username = getUsername;
      image = getImage;
      createdAt = getCreatedAt;

      String currDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      if(presenceDate == currDate) {

        setState(() {
          // isPresenceToday = true;
        });

      } else {

        setState(() {
          // isPresenceToday = false;
        });

      }

    }

    setState(() {
      loading = false;
    });

  }

  @override 
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    if(!mounted) return;
      db = DatabaseHelper();
    
    getData();
  }

  @override 
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    setState(() {
      if (state == AppLifecycleState.resumed) {

        Permission.manageExternalStorage.request().then((value) async {
          if(value == PermissionStatus.denied || value == PermissionStatus.permanentlyDenied) {
            await Permission.manageExternalStorage.request();
          }
        });

        debugPrint("=== RESUMED ===");
      } else if (state == AppLifecycleState.inactive) {
        debugPrint("=== INACTIVE ===");
      } else if (state == AppLifecycleState.paused) {
        debugPrint("=== PAUSED ===");
      } else if (state == AppLifecycleState.detached) {
        debugPrint("=== DETACHED ===");
      } else if (state == AppLifecycleState.hidden) {
        debugPrint("=== HIDDEN ===");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: loading 
      ? const Center(child: CircularProgressIndicator())
      : const AuthmenuPage()
    );
  }
}