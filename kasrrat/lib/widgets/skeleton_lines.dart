import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PosePainter extends CustomPainter {
  final List<Pose> poses;
  final Size imageSize;
  final InputImageRotation rotation;

  PosePainter(this.poses, this.imageSize, this.rotation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = Colors.cyanAccent;

    final dotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;

    for (final pose in poses) {
      // translate AI coordinates to Screen coordinates
      double translateX(double x) {
        // for andriod screen height 
        return size.width - (x * size.width / imageSize.height);
      }

      double translateY(double y) {
        // for andriod screen width
        return y * size.height / imageSize.width;
      }

      // landmarks points
      // Using a for-in loop instead of for.each
      // for high-frequency repainting 
      for (final entry in pose.landmarks.entries) {
        final type = entry.key;
        final landmark = entry.value;

        // only marking body points so <10 landmarks only used
        if (type.index <= 10) continue; 

        canvas.drawCircle(
          Offset(translateX(landmark.x), translateY(landmark.y)),
          5,
          dotPaint,
        );
      }

      // for connection lines between the dots
      void paintLine(PoseLandmarkType type1, PoseLandmarkType type2) {
        final p1 = pose.landmarks[type1];
        final p2 = pose.landmarks[type2];
        if (p1 != null && p2 != null) {
          canvas.drawLine(
            Offset(translateX(p1.x), translateY(p1.y)),
            Offset(translateX(p2.x), translateY(p2.y)),
            paint,
          );
        }
      }

      // For Squats
      // Upper parts
      paintLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder);
      paintLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow);
      paintLine(PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist);
      paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow);
      paintLine(PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist);

      // Torso
      paintLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip);
      paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip);
      paintLine(PoseLandmarkType.leftHip, PoseLandmarkType.rightHip);

      // Legs
      paintLine(PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee);
      paintLine(PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle);
      paintLine(PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee);
      paintLine(PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle);
    }
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) => oldDelegate.poses != poses;
}