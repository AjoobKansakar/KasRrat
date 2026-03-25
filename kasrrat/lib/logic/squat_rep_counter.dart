import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'workout_logic.dart'; // for angle calculations

// Rules for a complete squat movement
class SquatCounter {
  int reps = 0;
  bool isDown = false; // track if the user has reached the bottom
  bool depthAchieved = false; // tracks if the user actually hit the required depth
  bool hasFormError = false; // tracks if there is currently a form error 
  bool repHadError = false; // tracks if the current rep had a form mistake at any point
  String feedback = "Get Ready!";

  // check if the user is standing sideways
  void processPose(Pose pose) {
    
    // user sideways check by checking the horizontal distance between the shoulders compared to the height of the torse
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
    final rightHip = pose.landmarks[PoseLandmarkType.rightHip];
    final leftKnee = pose.landmarks[PoseLandmarkType.leftKnee];
    final rightKnee = pose.landmarks[PoseLandmarkType.rightKnee];
    final leftAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];
    final rightAnkle = pose.landmarks[PoseLandmarkType.rightAnkle];

    // Ensure all required points are visible
    if (leftShoulder == null || rightShoulder == null || leftHip == null || 
        rightHip == null || leftKnee == null || rightKnee == null || 
        leftAnkle == null || rightAnkle == null) {
      feedback = "Ensure full body is visible";
      return;
    }

    double shoulderWidth = (leftShoulder.x - rightShoulder.x).abs();
    double torsoHeight = (leftShoulder.y - leftHip.y).abs();

    // If shoulder width is too large compared to torso height, they are facing the camera
    if (shoulderWidth > torsoHeight * 0.6) {
      feedback = "Stand sideways infront of the camera please";
      hasFormError = true;
      repHadError = true; // to mark  this attempt is invalid
      return; 
    }
   
    // Knee angles for both sides
    double leftKneeAngle = PoseMath.getAngle(leftHip, leftKnee, leftAnkle);
    double rightKneeAngle = PoseMath.getAngle(rightHip, rightKnee, rightAnkle);

    // Hip angles for all sides (Shoulder -> Hip -> Knee)
    double leftHipAngle = PoseMath.getAngle(leftShoulder, leftHip, leftKnee);
    double rightHipAngle = PoseMath.getAngle(rightShoulder, rightHip, rightKnee);

    // Back Straightness Check 
    double torsoAngle = leftShoulder.likelihood > rightShoulder.likelihood
        ? PoseMath.getAngle(
            PoseLandmark(type: PoseLandmarkType.leftShoulder, x: leftShoulder.x, y: leftShoulder.y - 100, z: 0, likelihood: 1), 
            leftHip, leftShoulder)
        : PoseMath.getAngle(
            PoseLandmark(type: PoseLandmarkType.rightShoulder, x: rightShoulder.x, y: rightShoulder.y - 100, z: 0, likelihood: 1), 
            rightHip, rightShoulder);

    if (torsoAngle > 30) {
      feedback = "Keep your back straight!";
      hasFormError = true;
      repHadError = true; // Persistent memory that the back was bent during the rep
    } else {
      hasFormError = false;
    }

    // To differentiate between a squat and a lunge
    // Calculate the difference between the two knees to detect lunges
    double kneeDiff = (leftKneeAngle - rightKneeAngle).abs();

    // If one knee is bent significantly more than the other, then its considered a lunge
    if (kneeDiff > 40 && (leftKneeAngle < 130 || rightKneeAngle < 130)) {
      feedback = "Perform a Squat, thats a Lunge!";
      hasFormError = true;
      repHadError = true; // Mark as mistake
      return; // Stop processing this frame to prevent lunge reps from counting
    }

    // Bilateral Check
    // uses && for both knees and both hips
    if (leftKneeAngle < 100 && rightKneeAngle < 100 && leftHipAngle < 120 && rightHipAngle < 120) {
      isDown = true;
      depthAchieved = true; 
      if (!hasFormError) feedback = "Now Stand Up!";
    } 
    // Errors check
    // If one leg is deep but the other is not
    else if ((leftKneeAngle < 100 && rightKneeAngle > 115) || (rightKneeAngle < 100 && leftKneeAngle > 115)) {
        feedback = "Balance your weight on both legs!";
        hasFormError = true;
        repHadError = true;
    }
    // if the squat depth is not enough shows red screen
    else if (leftKneeAngle < 140 || rightKneeAngle < 140) {
      isDown = true;
      if (!depthAchieved) {
        hasFormError = true; // Trigger red screen for less depth
        feedback = "Go Lower!";
      }
    }

    // angle > 160, the user is standing straight
    if (leftKneeAngle > 165 && rightKneeAngle > 165) {
      if (isDown) {
        // rep count only if the required depth is reached && no form error happened during the whole move
        if (depthAchieved && !repHadError) {
          reps++;      
          feedback = "Good Job!";
          hasFormError = false;
        } else if (repHadError) {
          // if the rep was completed by the form was bad 
          feedback = "Form was not right, try again by keeping the back straight";
          hasFormError = true; 
        } else if (!depthAchieved) {
          feedback = "You did not go down enough. Try again with full range of motion";
          hasFormError = true; // Keep screen red for the failure message
        }
        
        // Reset for next rep
        isDown = false; 
        depthAchieved = false;
        repHadError = false; // Reset the mistake memory for the next rep
      } else {
        if (!hasFormError) feedback = "Squat Down!";
      }
    }
  }
}