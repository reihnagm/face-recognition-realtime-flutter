
// import 'dart:io';
// import 'dart:ui' as ui;
// import 'package:face_recognition_realtime/DB/DatabaseHelper.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import 'package:flutter/services.dart';
// import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
// import 'package:image/image.dart' as img;
// import 'package:intl/intl.dart';
// import 'package:lottie/lottie.dart';

// import 'package:face_recognition_realtime/ML/Recognition.dart';
// import 'package:face_recognition_realtime/navigate_to_presence.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';

// import 'ML/Recognizer.dart';

// late List<CameraDescription> cameras;
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   cameras = await availableCameras();
//   runApp(const MyApp());
// }

// class MyApp extends StatefulWidget {
//   const MyApp({super.key});

//   @override
//   State<MyApp> createState() => MyAppState();
// }

// class MyAppState extends State<MyApp>  with WidgetsBindingObserver {
//   late DatabaseHelper db;

//   bool isPresenceToday = false;

//   img.Image? image;
//   String? username;
//   String? createdAt;

//   bool loading = true;

//   @override 
//   void initState() {
//     super.initState();

//     WidgetsBinding.instance.addObserver(this);

//     if(!mounted) return;
//       db = DatabaseHelper();
    
//     getData();
//   }

//   @override 
//   void dispose() {
//     super.dispose();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     super.didChangeAppLifecycleState(state);

//     setState(() {
//       if (state == AppLifecycleState.resumed) {

//         // Permission.camera.request().then((value) async {
//         // if(value != PermissionStatus.granted) {
//         //     openAppSettings();
//         //   }
//         // });

//         Permission.manageExternalStorage.request().then((value) async {
//           if(value == PermissionStatus.denied || value == PermissionStatus.permanentlyDenied) {
//             await Permission.manageExternalStorage.request();
//           }
//         });

//         debugPrint("///Resumed///");
//       } else if (state == AppLifecycleState.inactive) {
//         debugPrint("///Inactive///");
//       } else if (state == AppLifecycleState.paused) {
//         debugPrint("///Paused///");
//       } else if (state == AppLifecycleState.detached) {
//         debugPrint("///Detached///");
//       } else if (state == AppLifecycleState.hidden) {
//         debugPrint("///Hidden///");
//       }
//     });
//   }

//   Future<void> getData() async {

//     // await Permission.camera.request().then((value) async {
//     //   if(value == PermissionStatus.granted) {
//     //     openAppSettings();
//     //   }
//     // });

//     await Permission.manageExternalStorage.request().then((value) async {
//       if(value == PermissionStatus.denied || value == PermissionStatus.permanentlyDenied) {
//         await Permission.manageExternalStorage.request();
//       }
//     });

//     await db.init();

//     Future.delayed(const Duration(seconds: 1), () async {
//       List data = await db.queryAllRows();

//       if(data.isNotEmpty) {

//         String presenceDate = data.first['presence_date'];
        
//         String getUsername = data.first['name'];
//         String getPicture = data.first['picture'];
//         String getCreatedAt = data.first['picture'];

//         Directory directory = Directory(""); 
    
//         if (Platform.isAndroid) { 
//           directory = Directory("/storage/emulated/0/Download"); 
//         } else { 
//           directory = await getApplicationDocumentsDirectory(); 
//         }
      
//         final exPath = directory.path;

//         final file = File('$exPath/$getPicture');

//         final imageBytes = await file.readAsBytes();

//         final getImage = img.decodeImage(imageBytes);

//         username = getUsername;
//         image = getImage;
//         createdAt = getCreatedAt;

//         String currDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

//         if(presenceDate == currDate) {

//           setState(() {
//             isPresenceToday = true;
//           });

//         } else {

//           setState(() {
//             isPresenceToday = false;
//           });

//         }

//       }

//     });

//     Future.delayed(const Duration(seconds: 1), () async {
//       setState(() {
//         loading = false;
//       });
//     });

//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: loading 
//       ? const Center(child: CircularProgressIndicator())
//       : const MyHomePage()
//       // : isPresenceToday 
//       // ? 
//       // NavigateToPresence(
//       //     image: image, 
//       //     username: username.toString(), 
//       //     createdAt: createdAt.toString()
//       // ) 
//       // : const MyHomePage()
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({Key? key}) : super(key: key);

//   @override
//   MyHomePageState createState() => MyHomePageState();
// }

// class MyHomePageState extends State<MyHomePage> {
  
//   late CameraController controller;

//   bool isBusy = false;
//   bool isBlinkMode = false;
//   bool isBlinkGuide = false;
//   bool register = false;

//   img.Image? image;
  
//   List<Recognition> scanResults = [];
//   CameraImage? frame;

//   CameraLensDirection camDirec = CameraLensDirection.front;

//   late Size size;
//   late CameraDescription description = cameras[1];
//   late List<Recognition> recognitions = [];
//   late FaceDetector faceDetector;
//   late Recognizer recognizer;

//   @override
//   void initState() {
//     super.initState();

//     var options = FaceDetectorOptions(
//       enableLandmarks: false,
//       enableContours: true,
//       enableTracking: true,
//       enableClassification: true,
//       performanceMode: FaceDetectorMode.accurate
//     );
    
//     faceDetector = FaceDetector(options: options);
    
//     recognizer = Recognizer();
    
//     initializeCamera();
//   }

//   Future<void> initializeCamera() async {
//     controller = CameraController(description, ResolutionPreset.medium,imageFormatGroup: Platform.isAndroid
//     ? ImageFormatGroup.nv21 
//     : ImageFormatGroup.bgra8888,enableAudio: false); 

//     await controller.initialize();
      
//     controller.startImageStream((image) {
//       if (!isBusy) {
//         isBusy = true; 
//         frame = image;
//         doFaceDetectionOnFrame();
//       }
//     });

//   }

//   @override
//   void dispose() {
//     controller.dispose();
//     super.dispose();
//   }

//   Future<void> doFaceDetectionOnFrame() async {
//     InputImage? inputImage = getInputImage();
//     if (inputImage == null) return;

//     List<Face> faces = await faceDetector.processImage(inputImage);
//     await performFaceRecognition(faces);
//   }

//   Future<void> performFaceRecognition(List<Face> faces) async {
//     if (frame == null) return;

//     recognitions = [];
//     isBlinkGuide = false;

//     img.Image baseImage = _processCameraFrame();
//     for (Face face in faces) {
//       Recognition recognition = await _processFaceRecognition(baseImage, face);

//       if (register) {
//         showFaceRegistrationDialogue(img.copyCrop(baseImage, 
//           x: face.boundingBox.left.toInt(),
//           y: face.boundingBox.top.toInt(),
//           width: face.boundingBox.width.toInt(),
//           height: face.boundingBox.height.toInt()),
//           recognition);
//         register = false;
//       }

//       recognitions.add(recognition);
//     }

//     if (mounted) {
//       setState(() {
//         isBusy = false;
//         scanResults = recognitions;
//       });
//     }
//   }

//   img.Image _processCameraFrame() {
//     img.Image image = Platform.isIOS 
//         ? convertBGRA8888ToImage(frame!) as img.Image 
//         : convertNV21(frame!);
//     return img.copyRotate(image, angle: camDirec == CameraLensDirection.front ? 270 : 90);
//   }

// Future<Recognition> _processFaceRecognition(img.Image image, Face face) async {
//   Rect faceRect = face.boundingBox;
//   img.Image croppedFace = img.copyCrop(image,
//       x: faceRect.left.toInt(),
//       y: faceRect.top.toInt(),
//       width: faceRect.width.toInt(),
//       height: faceRect.height.toInt());

//   Recognition recognition = recognizer.recognize(croppedFace, faceRect);

//   if (recognition.distance > 1.0) {
//     recognition.name = "Unknown";
//   } else {
//     await handleBlinkAndNavigate(face, recognition);
//   }

//   return recognition;
// }

// Future<void> handleBlinkAndNavigate(Face face, Recognition recognition) async {
//   if (face.leftEyeOpenProbability != null &&
//       face.rightEyeOpenProbability != null &&
//       face.leftEyeOpenProbability! < 0.15 &&
//       face.rightEyeOpenProbability! < 0.15) {
//     isBlinkMode = true;

//     Directory directory = await getStorageDirectory();
//     String filePath = '${directory.path}/${recognition.name}.png';
//     img.Image? savedImage = await readImageFromFile(filePath);

//     if (savedImage != null) {
//       Future.delayed(const Duration(seconds: 1), () {
//         // Navigator.of(context).pushAndRemoveUntil(
//         //   MaterialPageRoute(
//         //     builder: (context) => NavigateToPresence(
//         //       image: savedImage,
//         //       username: recognition.name,
//         //       createdAt: recognition.createdAt,
//         //     ),
//         //   ),
//         //   (route) => false,
//         // );
//       });
//     }
//   }
// }

// Future<Directory> getStorageDirectory() async {
//   if (Platform.isAndroid) {
//     return Directory("/storage/emulated/0/Download");
//   } else {
//     return await getApplicationDocumentsDirectory();
//   }
// }

// Future<img.Image?> readImageFromFile(String filePath) async {
//   File file = File(filePath);
//   if (!file.existsSync()) return null;

//   final imageBytes = await file.readAsBytes();
//   return img.decodeImage(imageBytes);
// }


//   Future<void> saveImageToDownloads({
//     required img.Image image, 
//     required String filename
//   }) async {
//     Directory directory = Directory(""); 
    
//     if (Platform.isAndroid) { 
//       directory = Directory("/storage/emulated/0/Download"); 
//     } else { 
//       directory = await getApplicationDocumentsDirectory(); 
//     }
  
//     final exPath = directory.path;

//     final file = File('$exPath/$filename');

//     final imageBytes = Uint8List.fromList(img.encodePng(image));
    
//     await file.writeAsBytes(imageBytes);

//     debugPrint('IMG saved to ${file.path}');
//   }

//   TextEditingController textEditingController = TextEditingController();

//   showFaceRegistrationDialogue(img.Image croppedFace, Recognition recognition) {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//       title: const Text("Face Registration",
//         textAlign: TextAlign.center
//       ),
//       alignment: Alignment.center,
//       content: SizedBox(
//         height: 340.0,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             const SizedBox(height: 20.0),
//             Image.memory(
//               Uint8List.fromList(
//                 img.encodeBmp(croppedFace)
//               ),
//               width: 200.0,
//               height: 200.0
//             ),
//             SizedBox(
//               width: 200.0,
//               child: TextField(
//                 controller: textEditingController,
//                 decoration: const InputDecoration(
//                   fillColor: Colors.white, 
//                   filled: true,
//                   hintText: "Enter Name"
//                 )
//               ),
//             ),
//             const SizedBox(height: 10.0),
//             ElevatedButton(
//               onPressed: () async {

//                 if(textEditingController.text.isEmpty) {
//                   Future.delayed(Duration.zero, () {
//                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//                       content: Text("Username is required"),
//                     ));
//                   });
//                   return;
//                 }

//                 String filename = "${textEditingController.text}.png";

//                 await saveImageToDownloads(image: croppedFace, filename: filename);

//                 recognizer.registerFaceInDB(textEditingController.text, filename, recognition.embeddings);

//                 textEditingController.text = "";
                
//                 Future.delayed(Duration.zero, () {
//                   Navigator.pop(context);
//                 });

//                 Future.delayed(Duration.zero, () {
//                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//                     content: Text("Face Registered"),
//                   ));
//                 });
                
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor:Colors.blue,
//                 minimumSize: const Size(200, 40)
//               ),
//               child: const Text("Register")
//             )
//           ],
//         ),
//       ),
//       contentPadding: EdgeInsets.zero,
//     ));
//   }
//   static var iosbytesoffset = 28;

//    static img.Image convertBGRA8888ToImage(CameraImage cameraImage) {
//     final plane = cameraImage.planes[0];

//     return img.Image.fromBytes(
//       width: cameraImage.width,
//       height: cameraImage.height,
//       bytes: plane.bytes.buffer,
//       rowStride: plane.bytesPerRow,
//       bytesOffset: iosbytesoffset,
//       order: img.ChannelOrder.bgra,
//     );
//   }

//   static img.Image convertNV21(CameraImage image) {

//     final width = image.width.toInt();
//     final height = image.height.toInt();

//     Uint8List yuv420sp = image.planes[0].bytes;

//     final outImg = img.Image(height:height, width:width);
//     final int frameSize = width * height;

//     for (int j = 0, yp = 0; j < height; j++) {
//       int uvp = frameSize + (j >> 1) * width, u = 0, v = 0;
//       for (int i = 0; i < width; i++, yp++) {
//         int y = (0xff & yuv420sp[yp]) - 16;
//         if (y < 0) y = 0;
//         if ((i & 1) == 0) {
//           v = (0xff & yuv420sp[uvp++]) - 128;
//           u = (0xff & yuv420sp[uvp++]) - 128;
//         }
//         int y1192 = 1192 * y;
//         int r = (y1192 + 1634 * v);
//         int g = (y1192 - 833 * v - 400 * u);
//         int b = (y1192 + 2066 * u);

//         if (r < 0) {
//           r = 0;
//         } else if (r > 262143) { r = 262143; }
//         if (g < 0) {
//           g = 0;
//         }
//         else if (g > 262143) { g = 262143; }
//         if (b < 0) {
//           b = 0;
//         }
//         else if (b > 262143) { b = 262143; }

//         outImg.setPixelRgb(i, j, ((r << 6) & 0xff0000) >> 16,
//         ((g >> 2) & 0xff00) >> 8, (b >> 10) & 0xff);
//       }
//     }
//     return outImg;
//   }

//   img.Image convertYUV420ToImage(CameraImage cameraImage) {
//     final width = cameraImage.width;
//     final height = cameraImage.height;

//     final yRowStride = cameraImage.planes[0].bytesPerRow;
//     final uvRowStride = cameraImage.planes[1].bytesPerRow;
//     final uvPixelStride = cameraImage.planes[1].bytesPerPixel!;

//     final image = img.Image(width:width, height:height);

//     for (var w = 0; w < width; w++) {
//       for (var h = 0; h < height; h++) {
//         final uvIndex = uvPixelStride * (w / 2).floor() + uvRowStride * (h / 2).floor();
//         final yIndex = h * yRowStride + w;

//         final y = cameraImage.planes[0].bytes[yIndex];
//         final u = cameraImage.planes[1].bytes[uvIndex];
//         final v = cameraImage.planes[2].bytes[uvIndex];

//         image.data!.setPixelR(w, h, yuv2rgb(y, u, v));
//       }
//     }
//     return image;
//   }
//   int yuv2rgb(int y, int u, int v) {
//     var r = (y + v * 1436 / 1024 - 179).round();
//     var g = (y - u * 46549 / 131072 + 44 - v * 93604 / 131072 + 91).round();
//     var b = (y + u * 1814 / 1024 - 227).round();

//     r = r.clamp(0, 255);
//     g = g.clamp(0, 255);
//     b = b.clamp(0, 255);

//     return 0xff000000 |
//     ((b << 16) & 0xff0000) |
//     ((g << 8) & 0xff00) |
//     (r & 0xff);
//   }


//   final orientations = {
//     DeviceOrientation.portraitUp: 0,
//     DeviceOrientation.landscapeLeft: 90,
//     DeviceOrientation.portraitDown: 180,
//     DeviceOrientation.landscapeRight: 270,
//   };

//   InputImage? getInputImage() {
//     final camera =
//     camDirec == CameraLensDirection.front ? cameras[1] : cameras[0];
//     final sensorOrientation = camera.sensorOrientation;

//     InputImageRotation? rotation;
    
//     if (Platform.isIOS) {
//       rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
//     } else if (Platform.isAndroid) {
//       var rotationCompensation = orientations[controller.value.deviceOrientation];
//       if (rotationCompensation == null) return null;
//       if (camera.lensDirection == CameraLensDirection.front) {
//         rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
//       } else {
//         rotationCompensation = (sensorOrientation - rotationCompensation + 360) % 360;
//       }
//       rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
//     }

//     if (rotation == null) return null;

//     final format = InputImageFormatValue.fromRawValue(frame!.format.raw);
//     if (format == null || (Platform.isAndroid && format != InputImageFormat.nv21) || (Platform.isIOS && format != InputImageFormat.bgra8888)) return null;

//     if (frame!.planes.length != 1) return null;
//     final plane = frame!.planes.first;

//     return InputImage.fromBytes(
//       bytes: plane.bytes,
//       metadata: InputImageMetadata(
//         size: Size(frame!.width.toDouble(), frame!.height.toDouble()),
//         rotation: rotation,
//         format: format,
//         bytesPerRow: plane.bytesPerRow,
//       ),
//     );
//   }

//   Widget buildResult() {
//     if (!controller.value.isInitialized) {
//       return const Center(
//         child: Text('Camera is not initialized',
//           style: TextStyle(
//             color: Colors.white
//           ),
//         )
//       );
//     }

//     final Size imageSize = Size(
//       controller.value.previewSize!.height,
//       controller.value.previewSize!.width,
//     );

//     CustomPainter painter = FaceDetectorPainter(imageSize, scanResults, camDirec);
//       return CustomPaint(
//         painter: painter,
//       );
//     }

//   void toggleCameraDirection() async {

//     if (camDirec == CameraLensDirection.back) {
//       camDirec = CameraLensDirection.front;
//       description = cameras[1];
//     } else {
//       camDirec = CameraLensDirection.back;
//       description = cameras[0];
//     }
//     await controller.stopImageStream();
//     setState(() {
//       controller;
//     });

//     initializeCamera();
//   }

//   @override
//   Widget build(BuildContext context) {
    
//     List<Widget> stackChildren = [];
    
//     size = MediaQuery.of(context).size;

//     if (!controller.value.isInitialized) {

//       stackChildren.add(
//         Positioned(
//           top: 0.0,
//           left: 0.0,
//           width: size.width,
//           height: size.height,
//           child: Container(
//             child: (controller.value.isInitialized)
//                 ? AspectRatio(
//               aspectRatio: controller.value.aspectRatio,
//               child: CameraPreview(controller),
//             )
//                 : Container(),
//           ),
//         ),
//       );

//       stackChildren.add(
//         Positioned(
//           top: 0.0,
//           left: 0.0,
//           width: size.width,
//           height: size.height,
//           child: buildResult()
//         ),
//       );

//     }

//     stackChildren.add(Positioned(
//       top: size.height - 140,
//       left: 0,
//       width: size.width,
//       height: 80,
//       child: Card(
//         margin: const EdgeInsets.only(
//           left: 20.0, 
//           right: 20.0
//         ),
//         color: Colors.white,
//         child: Center(
//           child:  Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     IconButton(
//                       icon: const Icon(
//                         Icons.app_registration,
//                         color: Colors.black,
//                       ),
//                       iconSize: 40,
//                       color: Colors.black,
//                       onPressed: () {
//                         setState(() {
//                           register = true;
//                         });
//                       },
//                     )
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );

//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         body: isBlinkMode 
//         ? const Center(
//             child: SizedBox(
//               width: 80.0,
//               height: 80.0,
//               child: CircularProgressIndicator(),
//             ),
//           ) 
//         : Container(
//             margin: const EdgeInsets.only(top: 0.0),
//             color: Colors.black,
//             child: Stack(
//               clipBehavior: Clip.none,
//               children: [

//               Positioned(
//                 top: 0.0,
//                 left: 0.0,
//                 width: size.width,
//                 height: size.height,
//                 child: Container(
//                   child: (controller.value.isInitialized)
//                   ? AspectRatio(
//                       aspectRatio: controller.value.aspectRatio,
//                       child: CameraPreview(controller),
//                     )
//                   : const SizedBox(),
//                 ),
//               ),

//               Positioned(
//                 top: 0.0,
//                 left: 0.0,
//                 width: size.width,
//                 height: size.height,
//                 child: buildResult()
//               ),

//               Positioned(
//                 top: size.height - 140,
//                 left: 0,
//                 width: size.width,
//                 height: 100.0,
//                 child: Card(
//                   margin: const EdgeInsets.only(
//                     left: 20.0, 
//                     right: 20.0
//                   ),
//                   color: Colors.white,
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                          Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               IconButton(
//                                 icon: const Icon(
//                                   Icons.app_registration,
//                                   color: Colors.black,
//                                 ),
//                                 iconSize: 40.0,
//                                 color: Colors.black,
//                                 onPressed: () {
//                                   setState(() {
//                                     register = true;
//                                   });
//                                 },
//                               )
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),

//             ] ,
//           )
//         ),
//       ),
//     );
//   }
// }

// class FaceDetectorPainter extends CustomPainter {
//   FaceDetectorPainter(this.absoluteImageSize, this.faces, this.camDire2);

//   final Size absoluteImageSize;
//   final List<Recognition> faces;
//   CameraLensDirection camDire2;

//   @override
//   void paint(Canvas canvas, Size size) {
//     final double scaleX = size.width / absoluteImageSize.width;
//     final double scaleY = size.height / absoluteImageSize.height;

//     final Paint paint = Paint()
//     ..style = PaintingStyle.stroke
//     ..strokeWidth = 2.0
//     ..color = Colors.indigoAccent;

//     for (Recognition face in faces) {
//       canvas.drawRect(
//         Rect.fromLTRB(
//           camDire2 == CameraLensDirection.front
//           ? (absoluteImageSize.width - face.location.right) * scaleX
//           : face.location.left * scaleX,
//           face.location.top * scaleY,
//           camDire2 == CameraLensDirection.front
//           ? (absoluteImageSize.width - face.location.left) * scaleX
//           : face.location.right * scaleX,
//           face.location.bottom * scaleY,
//         ),
//         paint,
//       );

//       TextSpan span = TextSpan(
//         style: const TextStyle(
//           color: Colors.white, 
//           fontSize: 20,
//         ),
//         text: face.name
//       );
      
//       TextPainter tp = TextPainter(
//         text: span,
//         textAlign: TextAlign.center,
//         textDirection: ui.TextDirection.rtl
//       );

//       tp.layout();
//       tp.paint(canvas, Offset(face.location.left*scaleX, face.location.top*scaleY));
//     }

//   }

//   @override
//   bool shouldRepaint(FaceDetectorPainter oldDelegate) {
//     return true;
//   }
// }