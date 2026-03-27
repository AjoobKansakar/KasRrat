import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'workout_logic.dart'; // for angle calculations

// Rules for a complete squat movement
class SquatCounter {
  int reps = 0;         // Strict counter to only count valid reps only
  int goodReps = 0;     // Matches reps for summary clarity
  int totalAttempts = 0; // to track every time the user stands up after going down
  bool isDown = false; // track if the user has reached the bottom
  bool depthAchieved = false; // tracks if the user actually hit the required depth
  bool hasFormError = false; // tracks if there is currently a form error 
  bool repHadError = false; // tracks if the current rep had a form mistake at any point
  String feedback = "Get Ready!";

  // store errors found during the set for review
  Set<String> errorsFound = {};

  // check if the user is standing sideways
  // callbacks for audio feedback
  void processPose(Pose pose, {required Function() onRepCount, required Function() onFormError}) {
    
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
      if (!hasFormError) onFormError(); // Trigger voice once
      hasFormError = true;
      repHadError = true; // to block the rep for bad form
      errorsFound.add("Stand sideways"); // Record the error type
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
      if (!hasFormError) onFormError(); // Trigger voice once
      hasFormError = true;
      repHadError = true; // Persistent memory that the back was bent during the rep
      errorsFound.add("Back Bending"); // Record the error type
    } else {
      hasFormError = false;
    }

    // To differentiate between a squat and a lunge
    double kneeDiff = (leftKneeAngle - rightKneeAngle).abs();

    // If one knee is bent significantly more than the other, then its considered a lunge
    if (kneeDiff > 40 && (leftKneeAngle < 130 || rightKneeAngle < 130)) {
      feedback = "Perform a Squat, thats a Lunge!";
      if (!hasFormError) onFormError(); // Trigger voice once
      hasFormError = true;
      repHadError = true; 
      errorsFound.add("Form Issues"); // Record the error type
      return; 
    }

    // Bilateral Check
    // uses && for both knees and both hips
    if (leftKneeAngle < 100 && rightKneeAngle < 100 && leftHipAngle < 120 && rightHipAngle < 120) {
      isDown = true;
      depthAchieved = true; 
      if (!hasFormError) feedback = "Now Stand Up!";
    } 
    // check if one leg is deep but the other is not
    else if ((leftKneeAngle < 100 && rightKneeAngle > 115) || (rightKneeAngle < 100 && leftKneeAngle > 115)) {
        feedback = "Balance your weight on both legs!";
        if (!hasFormError) onFormError(); // Trigger voice once
        hasFormError = true;
        repHadError = true; // if yes block the rep
        errorsFound.add("Form Issues");
    }
    // if the squat depth is not enough
    else if (leftKneeAngle < 140 || rightKneeAngle < 140) {
      isDown = true;
      if (!depthAchieved) {
        hasFormError = true; 
        feedback = "Go Lower!";
      }
    }

    // angle > 160, the user is standing straight
    if (leftKneeAngle > 165 && rightKneeAngle > 165) {
      if (isDown) {
        totalAttempts++; // count every stand-up as an attempt

        // reps are only counted if the form and depth was reached AND no errors occurs
        if (depthAchieved && !repHadError) {
          reps++;      
          goodReps++; 
          onRepCount(); // rep count feedback
          feedback = "Good Job!";
          hasFormError = false;
        } 
        else if (repHadError) {
          // If form was bad, rep is not counted
          onFormError(); // Error feedback
          feedback = "Form was not right, try again by keeping the back straight";
          hasFormError = true; 
        } 
        else if (!depthAchieved) {
          // If squat dept was not enough, rep is not counted
          onFormError(); // Error feedback
          feedback = "You did not go down enough. Try again with full range of motion";
          hasFormError = true; 
          errorsFound.add("Shallow Depth");
        }
        
        // Reset state for next rep
        isDown = false; 
        depthAchieved = false;
        repHadError = false; 
      } else {
        if (!hasFormError) feedback = "Squat Down!";
      }
    }
  }
}