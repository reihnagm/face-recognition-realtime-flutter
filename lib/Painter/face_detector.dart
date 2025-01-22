import 'package:face_recognition_realtime/ML/Recognition.dart';
import 'package:flutter/material.dart';

import 'dart:ui' as ui;

import 'package:camera/camera.dart';

class FaceDetectorPainter extends CustomPainter {
  FaceDetectorPainter(this.absoluteImageSize, this.faces, this.camDire2);

  final Size absoluteImageSize;
  final List<Recognition> faces;
  final CameraLensDirection camDire2;

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / absoluteImageSize.width;
    final double scaleY = size.height / absoluteImageSize.height;

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.indigoAccent;

    for (Recognition face in faces) {
      // Calculate the center and radius for the rounded mask
      double centerX = camDire2 == CameraLensDirection.front
      ? (absoluteImageSize.width - (face.location.left + face.location.right) / 2) * scaleX
      : ((face.location.left + face.location.right) / 2) * scaleX;

      double centerY = ((face.location.top + face.location.bottom) / 2) * scaleY;

      double radius = (face.location.width > face.location.height  ? face.location.height : face.location.width) *  scaleX / 2;

      // Draw a circle for each detected face
      canvas.drawCircle(Offset(centerX, centerY), radius, paint);

      // Optionally draw text (e.g., recognition name)
      TextSpan span = TextSpan(
        style: const TextStyle(color: Colors.white, fontSize: 20),
        text: face.name,
      );

      TextPainter tp = TextPainter(
        text: span,
        textAlign: TextAlign.center,
        textDirection: ui.TextDirection.rtl,
      );

      tp.layout();
      tp.paint(canvas, Offset(centerX - tp.width / 2, centerY - radius - 20));
    }
  }

  @override
  bool shouldRepaint(FaceDetectorPainter oldDelegate) {
    return true;
  }
}
