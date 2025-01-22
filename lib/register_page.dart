

import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:image/image.dart' as img;

import 'package:face_recognition_realtime/main.dart';

import 'package:face_recognition_realtime/Helper/Image.dart';
import 'package:face_recognition_realtime/Helper/directory.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import 'package:face_recognition_realtime/ML/Recognition.dart';

import 'ML/Recognizer.dart';

class RegisterPage extends StatefulWidget {
  final String username;

  const RegisterPage({
    required this.username,
    Key? key
  }) : super(key: key);

  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  
  late CameraController controller;

  String text1 = "Please scan your face to register";
  String text2 = "";

  bool isBusy = false;
  bool btnRegister = false;
  bool register = false;
  bool waitForScanSucceded = true;
  bool alreadyRegistered = false;

  img.Image? image;
  
  List<Recognition> scanResults = [];
  CameraImage? frame;

  int frameSkip = 60;
  int frameCounter = 0;

  CameraLensDirection camDirec = CameraLensDirection.front;

  late Size size;
  late CameraDescription description = cameras[1];
  late List<Recognition> recognitions = [];
  late FaceDetector faceDetector;
  late Recognizer recognizer;

  Future<void> initializeCamera() async {
    controller = CameraController(
      description,
      ResolutionPreset.medium,
      imageFormatGroup: Platform.isAndroid
    ? ImageFormatGroup.nv21 
    : ImageFormatGroup.bgra8888, 
      enableAudio: false
    ); 

    await controller.initialize();
      
    controller.startImageStream((image) {
      if (!isBusy && frameCounter % frameSkip == 0) {
        isBusy = true;
        frame = image;
        doFaceDetectionOnFrame();
      }
      frameCounter++;
    });
  }

  Future<void> doFaceDetectionOnFrame() async {
    InputImage? inputImage = ImageHelper.getInputImage(controller, camDirec, cameras, frame!);
    if (inputImage == null) return;

    List<Face> faces = await faceDetector.processImage(inputImage);
    
    await performFaceRecognition(faces);
  }

  Future<void> performFaceRecognition(List<Face> faces) async {
    if (frame == null) return;

    img.Image baseImage = ImageHelper.processCameraFrame(frame, camDirec);

    recognitions = [];

    for (Face face in faces) {
      Recognition recognition = await processFaceRecognition(baseImage, face);

      if (register) {
        showFaceRegistrationDialogue(img.copyCrop(baseImage, 
          x: face.boundingBox.left.toInt(),
          y: face.boundingBox.top.toInt(),
          width: face.boundingBox.width.toInt(),
          height: face.boundingBox.height.toInt()),
          recognition
        );
        register = false;
      }

      recognitions.add(recognition);
    }

    if (mounted) {
      setState(() {
        isBusy = false;
        scanResults = recognitions;
      });
    }
  }

  Future<Recognition> processFaceRecognition(img.Image image, Face face) async {
    Rect faceRect = face.boundingBox;

    img.Image croppedFace = img.copyCrop(
      image,
      x: faceRect.left.toInt(),
      y: faceRect.top.toInt(),
      width: faceRect.width.toInt(),
      height: faceRect.height.toInt()
    );

    Recognition recognition = recognizer.recognize(croppedFace, faceRect);

    if (recognition.distance > 1.0) {
      recognition.name = "Not Registered";
      setState(() => text1 = "Not Registered");
      setState(() => text2 = "Take your photo to register account");
      setState(() => alreadyRegistered = false);
      setState(() => waitForScanSucceded = false);
    } else {
      setState(() => text1 = "Already Registered ! AS ${recognition.name}");
      setState(() => text2 = "");
      setState(() => alreadyRegistered = true);
    }

    return recognition;
  }

  void showFaceRegistrationDialogue(img.Image croppedFace, Recognition recognition) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
      title: const Text("Face Registration",
        textAlign: TextAlign.center
      ),
      alignment: Alignment.center,
      content: SizedBox(
        height: 340.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            
            const SizedBox(height: 20.0),

            Image.memory(
              Uint8List.fromList(
                img.encodeBmp(croppedFace)
              ),
              width: 200.0,
              height: 200.0
            ),

            const SizedBox(height: 10.0),

            StatefulBuilder(
              builder: (BuildContext context, Function s) {
                return ElevatedButton(
                  onPressed: () async {
                    // save to local
                    s(() => btnRegister = true);

                    await StorageHelper.saveImageToDownloads(
                      image: croppedFace, 
                      filename: widget.username
                    );

                    recognizer.registerFaceInDB(
                      widget.username, 
                      widget.username, 
                      recognition.embeddings
                    );

                    Future.delayed(const Duration(seconds: 2), () async {
                      if(!mounted) return;
                        s(() => btnRegister = false);
                    });
                  
                    if(!mounted) return;
                      Navigator.pop(context);

                    // save to api (on progress)
                    // try {
                    //   Dio dio = Dio();
                    //   Response res = await dio.post("https://api-rakhsa.inovatiftujuh8.com/api/v1/auth/register-fr", 
                    //     data: {
                    //       "embedding": recognition.embeddings.join(",")
                    //     }
                    //   );

                    //   setState(() => btnRegister = false);

                    //   if(!mounted) return;
                    //     Navigator.pop(context);

                    //   debugPrint("=== FACE REGISTERED ${res.statusMessage.toString()} ===");
                    // } on DioException catch(e) {
                    //   debugPrint(e.response!.data.toString());
                    //   debugPrint(e.response!.statusCode.toString());
                    // } catch(e) {
                    //   debugPrint(e.toString());
                    // }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:const Color(0xffFE1717),
                    textStyle: const TextStyle(
                      color: Color(0xffFFFFFF)
                    ),
                    minimumSize: const Size(200, 40)
                  ),
                  child: btnRegister 
                  ? const SizedBox(
                      width: 16.0,
                      height: 16.0,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      )
                    ) 
                  : const Text("Register",
                    style: TextStyle(
                      color: Colors.white
                    ),
                  )
                );
              },
            )
          ],
        ),
      ),
      contentPadding: EdgeInsets.zero,
    ));
  }

  Widget buildResult() {
    if (!controller.value.isInitialized) {
      return const Center(
        child: Text('Camera is not initialized',
          style: TextStyle(
            color: Colors.white
          ),
        )
      );
    }

    // final Size imageSize = Size(
    //   controller.value.previewSize!.height,
    //   controller.value.previewSize!.width,
    // );
    
    // CustomPainter painter = FaceDetectorPainter(imageSize, scanResults, camDirec);
    
    // return CustomPaint(painter: painter);

    return const SizedBox();
  }

  void toggleCameraDirection() async {

    if (camDirec == CameraLensDirection.back) {
      camDirec = CameraLensDirection.front;
      description = cameras[1];
    } else {
      camDirec = CameraLensDirection.back;
      description = cameras[0];
    }
    await controller.stopImageStream();

    setState(() => controller);

    initializeCamera();
  }
  
  @override
  void initState() {
    super.initState();

    var options = FaceDetectorOptions(
      enableLandmarks: false,
      enableContours: true,
      enableTracking: true,
      enableClassification: true,
      performanceMode: FaceDetectorMode.fast
    );
    
    faceDetector = FaceDetector(options: options);
    
    recognizer = Recognizer();
    
    initializeCamera();
  }

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    List<Widget> stackChildren = [];
    
    size = MediaQuery.of(context).size;

    if (!controller.value.isInitialized) {
      stackChildren.add(
        Positioned(
          top: 0.0,
          left: 0.0,
          width: size.width,
          height: size.height,
          child: Container(
          child: (controller.value.isInitialized)
          ? AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: CameraPreview(controller),
            )
          : const SizedBox(),
          ),
        ),
      );

      stackChildren.add(
        Positioned(
          top: 0.0,
          left: 0.0,
          width: size.width,
          height: size.height,
          child: buildResult()
        ),
      );
    }

    stackChildren.add(Positioned(
      top: size.height - 140,
      left: 0,
      width: size.width,
      height: 80.0,
      child: Card(
        margin: const EdgeInsets.only(
          left: 20.0, 
          right: 20.0
        ),
        color: Colors.white,
        child: Center(
          child:  Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text("Photo",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 22.0,
                  fontWeight: ui.FontWeight.bold
                ),
              ),

              const SizedBox(height: 10.0),

              Container(
                padding: const EdgeInsets.all(1.0),
                decoration: BoxDecoration(
                  color: const Color(0xff211F1F).withOpacity(0.2),
                  shape: BoxShape.circle
                ),
                child: IconButton(
                  highlightColor: const Color(0xff211F1F),
                  icon: const Icon(
                    Icons.circle,
                  ),
                  iconSize: 50.0,
                  onPressed: () {
                    setState(() => register = true);
                  },
                ),
              ),
            ],
          ),
        ),
      )),
    );

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          forceMaterialTransparency: true,
          leading: CupertinoNavigationBarBackButton(
            color: Colors.white,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Container(
          margin: const EdgeInsets.only(top: 0.0),
          color: Colors.black,
          child: Stack(
            clipBehavior: Clip.none,
            children: [

              Positioned(
                top: 0.0,
                left: 0.0,
                width: size.width,
                height: size.height,
                child: (controller.value.isInitialized)
                ? Align(
                    alignment: Alignment.topCenter,
                    child: ClipOval(
                      child: SizedBox(
                        width: size.width * 0.8, 
                        height: size.width * 0.8, 
                        child: OverflowBox(
                          alignment: Alignment.center,
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              height: 1,
                              child: AspectRatio(
                                aspectRatio: 1 / controller.value.aspectRatio,
                                child: CameraPreview(controller),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox(),
              ),

              // for scanning image
              Positioned(
                top: 0.0,
                left: 0.0,
                width: size.width,
                height: size.height,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: size.width * 0.8, 
                    height: size.width * 0.8, 
                    child: buildResult()
                  )
                ),
              ),

              Positioned(
                top: MediaQuery.of(context).size.height * 0.5,
                left: 0.0,
                right: 0.0,
                child: Center(
                  child: Column(
                    children: [
                      Text(text1,
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                        ),
                      ),
                      Text(text2,
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                        ),
                      )
                    ],
                  ) 
                )
              ), 

              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
              ),

              Positioned(
                left: 0.0,
                bottom: 0.0,
                width: size.width,
                height: 180.0,
                child: Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [

                        const Text("Photo",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 22.0,
                            fontWeight: ui.FontWeight.bold
                          ),
                        ),

                        const SizedBox(height: 10.0),

                        Container(
                          padding: const EdgeInsets.all(1.0),
                          decoration: BoxDecoration(
                            color: alreadyRegistered 
                            ? Colors.grey.withOpacity(0.2)
                            : waitForScanSucceded 
                            ? Colors.grey.withOpacity(0.2) 
                            : const Color(0xff211F1F).withOpacity(0.2),
                            shape: BoxShape.circle
                          ),
                          child: IconButton(
                            highlightColor: alreadyRegistered 
                            ? Colors.grey.withOpacity(0.2) 
                            : waitForScanSucceded 
                            ? Colors.grey.withOpacity(0.2) 
                            :const Color(0xff211F1F),
                            icon: Icon(
                              Icons.circle,
                              color: alreadyRegistered 
                            ? Colors.grey.withOpacity(0.2)
                            : waitForScanSucceded 
                            ? Colors.grey.withOpacity(0.2)
                            : const Color(0xff211F1F),
                            ),
                            iconSize: 50.0,
                            onPressed: alreadyRegistered 
                            ? () {} 
                            : waitForScanSucceded 
                            ? () {} 
                            : () {
                              setState(() => register = true);
                            },
                          ),
                        ),

                      ],
                    ),
                  ),
                ),
              ),

            ] ,
          )
        ),
      ),
    );
  }
}