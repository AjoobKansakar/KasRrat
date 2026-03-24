// Calculate Pose detection angles 
// To calculate angles between hip, knee, and ankles for Squats
import 'dart:math' as math;
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PoseMath {
  // Function to calculate angle between Hip(A), Knee(B), and Ankle(C)
  static double getAngle(PoseLandmark firstPoint, PoseLandmark midPoint, PoseLandmark lastPoint) {
    // Using atan2 math function (Arctangent)
    // the logic is to find the angle of line from midPoint to firstPoint and subttract it from the angle of the line from midpoint to lastpoint
    var result = (math.atan2(lastPoint.y - midPoint.y, lastPoint.x - midPoint.x) -
                  math.atan2(firstPoint.y - midPoint.y, firstPoint.x - midPoint.x))
                  .abs() * (180 / math.pi); // Convert radians to degrees

    // Ensure the angle is always under 180 degree
    if (result > 180) {
      result = 360 - result;
    }
    return result;
  }
}
