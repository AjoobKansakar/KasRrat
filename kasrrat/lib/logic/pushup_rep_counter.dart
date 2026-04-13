// pushup logic
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'workout_logic.dart'; // for angle calculations

// Rules for a complete pushup movement
class PushupCounter {
  int reps = 0;          // Strict counter to only count valid reps only
  int goodReps = 0;      // Matches reps for summary clarity
  int totalAttempts = 0; // to track every time the user pushes up after going down
  bool isDown = false;   // track if the user has reached the bottom position
  bool depthAchieved = false; // tracks if the user actually hit the required depth
  bool hasFormError = false;  // tracks if there is currently a form error
  bool repHadError = false;   // tracks if the current rep had a form mistake at any point
  String feedback = "Get Ready!";

  // store errors found during the set for review
  Set<String> errorsFound = {};

  // elbow angle detection for pushup 
  void processPose(Pose pose, {required Function() onRepCount, required Function() onFormError}) {

    // Get all the landmarks needed for push-up detection
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final leftElbow = pose.landmarks[PoseLandmarkType.leftElbow];
    final rightElbow = pose.landmarks[PoseLandmarkType.rightElbow];
    final leftWrist = pose.landmarks[PoseLandmarkType.leftWrist];
    final rightWrist = pose.landmarks[PoseLandmarkType.rightWrist];
    final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
    final rightHip = pose.landmarks[PoseLandmarkType.rightHip];
    final leftAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];
    final rightAnkle = pose.landmarks[PoseLandmarkType.rightAnkle];

    // Ensure all required points are visible before processing
    if (leftShoulder == null || rightShoulder == null ||
        leftElbow == null || rightElbow == null ||
        leftWrist == null || rightWrist == null ||
        leftHip == null || rightHip == null ||
        leftAnkle == null || rightAnkle == null) {
      feedback = "Ensure full body is visible";
      return;
    }

    // Horizontal Orientation Check
    // Comparing X distance (length) to Y distance (height) between shoulder and ankle
    double bodyLengthX = (leftShoulder.x - leftAnkle.x).abs();
    double bodyHeightY = (leftShoulder.y - leftAnkle.y).abs();

    // If Height (Y) is greater than Length (X), the user is standing up.
    if (bodyHeightY > bodyLengthX) {
      feedback = "Lye down on the floor!";
      hasFormError = true;
      return; // Stop processing further logic if the user is standing
    }

    // sideways oreintation check, to only let the user perform the movement with sideprofile view
    double shoulderWidth = (leftShoulder.x - rightShoulder.x).abs();
    double torsoHeight = (leftShoulder.y - leftHip.y).abs();

    if (shoulderWidth > torsoHeight * 0.6) {
      feedback = "Please lie down sideways to the camera";
      hasFormError = true;
      repHadError = true;
      errorsFound.add("Stand sideways");
      return; 
    }

    // when the users arms are bent, user is in down position
    // when the users arms are straight, user is in up position
    double leftElbowAngle = PoseMath.getAngle(leftShoulder, leftElbow, leftWrist);
    double rightElbowAngle = PoseMath.getAngle(rightShoulder, rightElbow, rightWrist);

   
    // Back form check 
    double leftBodyAngle = PoseMath.getAngle(leftShoulder, leftHip, leftAnkle);
    double rightBodyAngle = PoseMath.getAngle(rightShoulder, rightHip, rightAnkle);

    // Use whichever side has the more visible landmarks
    double bodyAngle = leftShoulder.likelihood > rightShoulder.likelihood
        ? leftBodyAngle
        : rightBodyAngle;

    // UPDATED: More visible side elbow for more robust detection
    double currentElbowAngle = leftElbow.likelihood > rightElbow.likelihood 
        ? leftElbowAngle 
        : rightElbowAngle;

    // if the hip is too high or too low, marking it as error
    // In a pushup, a body angle < 160 usually means the hips are sagging or piking
    if (bodyAngle < 160) {
      feedback = "Keep your body straight!";
      if (!hasFormError) onFormError(); // Trigger voice once
      hasFormError = true;
      repHadError = true; // Persistent memory that the body was not straight
      errorsFound.add("Back Bending"); // Record the error type
    } else {
      hasFormError = false;
    }

    // Down position detection 
    if (currentElbowAngle < 90) {
      isDown = true;
      depthAchieved = true;
      if (!hasFormError) feedback = "Push Up!";
    }
    // If partially down but not deep enough
    else if (currentElbowAngle < 130) {
      isDown = true;
      if (!depthAchieved) {
        hasFormError = true;
        feedback = "Go Lower!";
      }
    }

    // Up position detection
    if (currentElbowAngle > 160) {
      if (isDown) {
        totalAttempts++; // to count every pushup attempt

        // Rep is counted only if depth was achieved AND no form errors occurred
        if (depthAchieved && !repHadError) {
          reps++;
          goodReps++;
          onRepCount(); // rep count audio feedback
          feedback = "Good Repp!";
          hasFormError = false;
        } else if (repHadError) {
          // If form was bad, rep is not counted
          onFormError(); // Error audio feedback
          feedback = "Form was off, keep your body straight";
          hasFormError = true;
        } else if (!depthAchieved) {
          // If pushup depth was not enough, rep is not counted
          onFormError(); // Error audio feedback
          feedback = "Didn't go low enough, try again go deeper";
          hasFormError = true;
          errorsFound.add("Shallow Depth");
        }

        // Reset state for next rep
        isDown = false;
        depthAchieved = false;
        repHadError = false;
      } else {
        if (!hasFormError) feedback = "Go Down!";
      }
    }
  }
}