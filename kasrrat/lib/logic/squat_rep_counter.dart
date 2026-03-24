import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'workout_logic.dart'; // for angle calculations

// Rules for a complete squat movement
class SquatCounter {
  int reps = 0;
  bool isDown = false; // track if the user has reached the bottom
  bool depthAchieved = false; // tracks if the user actually hit the required depth
  bool hasFormError = false; // tracks if there is currently a form error 
  String feedback = "Get Ready!";

  // check if the user is standing sideways
  void processPose(double kneeAngle, Pose pose) {
    
    // user sideways check by checking the horizontal distance between the shoulders compared to the height of the torse
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
    final rightHip = pose.landmarks[PoseLandmarkType.rightHip];

    if (leftShoulder != null && rightShoulder != null && leftHip != null && rightHip != null) {
      double shoulderWidth = (leftShoulder.x - rightShoulder.x).abs();
      double torsoHeight = (leftShoulder.y - leftHip.y).abs();

      // If shoulder width is too large compared to torso height, they are facing the camera
      if (shoulderWidth > torsoHeight * 0.6) {
        feedback = "Stand sideways infront of the camera please";
        hasFormError = true;
        return; 
      }

      // Form logic for Squats
      // angle of the torso (Shoulder to Hip) relative to a vertical line
      double torsoAngle;
      if (leftShoulder.likelihood > rightShoulder.likelihood) {
        // if the user is facing right
        torsoAngle = PoseMath.getAngle(
          PoseLandmark(type: PoseLandmarkType.leftShoulder, x: leftShoulder.x, y: leftShoulder.y - 100, z: 0, likelihood: 1), // Vertical point
          leftHip, 
          leftShoulder
        );
      } else {
        // if the user is facing left
        torsoAngle = PoseMath.getAngle(
          PoseLandmark(type: PoseLandmarkType.rightShoulder, x: rightShoulder.x, y: rightShoulder.y - 100, z: 0, likelihood: 1), // Vertical point
          rightHip, 
          rightShoulder
        );
      }

      if (torsoAngle > 30) {
        feedback = "Keep your back straight!";
        hasFormError = true;
        return; // Stop processing further if the back is bent
      } else {
        hasFormError = false;
      }
    }

    // Squats rep count logic 
    // angle < 100, the user has reached the valid depth
    if (kneeAngle < 100) {
      isDown = true;
      depthAchieved = true; 
      hasFormError = false; // Clear error because they reached the goal
      feedback = "Now Stand Up!";
    } 
    // if the squat depth is not enough shows red screen
    else if (kneeAngle < 140) {
      isDown = true;
      if (!depthAchieved) {
        hasFormError = true; // Trigger red screen for less depth
        feedback = "Go Lower!";
      }
    }

    // angle > 160, the user is standing straight
    if (kneeAngle > 165) {
      if (isDown) {
        // rep count only if the required depth is reached
        if (depthAchieved && !hasFormError) {
          reps++;      
          feedback = "Good Job!";
          hasFormError = false;
        } else if (!depthAchieved) {
          feedback = "You did not go down enough. Try again with full range of motion";
          hasFormError = true; // Keep screen red for the failure message
        }
        
        // Reset for next rep
        isDown = false; 
        depthAchieved = false;
      } else {
        feedback = "Squat Down!";
        hasFormError = false; // Reset error when standing straight and ready
      }
    }
  }
}