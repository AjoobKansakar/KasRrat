// Bicep Curl Logic
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'workout_logic.dart'; // for angle calculations

// Rules for a complete bicep curl movement
class BicepCurlCounter {
  int reps = 0;          // Strict counter to only count valid reps only
  int goodReps = 0;      // Matches reps for summary review
  int totalAttempts = 0; // to track every time the user lowers the arm after curling up
  bool isUp = false;     // track if the user has reached the top curl position
  bool peakAchieved = false; // tracks if the user actually hit the required curl height
  bool hasFormError = false;  // tracks if there is a form error
  bool repHadError = false;   // tracks if the current rep had a form error at any point
  String feedback = "Get Ready!";

  // store errors found during the set for review
  Set<String> errorsFound = {};

  // Bicep curl pose detection logic
  // onSymmetryError to track simgle arm curls
  void processPose(Pose pose, {
    required Function() onRepCount, 
    required Function() onFormError, 
    required Function() onSymmetryError // both arms check
  }) {

    // Get all the landmarks needed for bicep curl detection
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final leftElbow = pose.landmarks[PoseLandmarkType.leftElbow];
    final rightElbow = pose.landmarks[PoseLandmarkType.rightElbow];
    final leftWrist = pose.landmarks[PoseLandmarkType.leftWrist];
    final rightWrist = pose.landmarks[PoseLandmarkType.rightWrist];
    final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
    final rightHip = pose.landmarks[PoseLandmarkType.rightHip];

    // Ensure all required points are visible before processing
    if (leftShoulder == null || rightShoulder == null ||
        leftElbow == null || rightElbow == null ||
        leftWrist == null || rightWrist == null ||
        leftHip == null || rightHip == null) {
      feedback = "Ensure upper body is visible";
      return;
    }

    // Orientation rule, so that the user could only perfrom the exercise facing sideways for clearer elbow visibility
    double shoulderWidth = (leftShoulder.x - rightShoulder.x).abs();
    double torsoHeight = (leftShoulder.y - leftHip.y).abs();

    if (shoulderWidth > torsoHeight * 0.6) {
      feedback = "Stand sideways infront of the camera please";
      hasFormError = true;
      repHadError = true;
      errorsFound.add("Stand sideways");
      return; 
    }

    // Shoulder --> elbow --> wrist angle calculation 
    // small angle --> arm curled up top position
    // Large angle --> arm down start position
    double leftElbowAngle  = PoseMath.getAngle(leftShoulder,  leftElbow,  leftWrist);
    double rightElbowAngle = PoseMath.getAngle(rightShoulder, rightElbow, rightWrist);

    // To ensure user is not performing cheat reps upper arm swinging is checked 
    // elbow should not swing forward during the curl
    double elbowX    = leftElbow.likelihood > rightElbow.likelihood ? leftElbow.x    : rightElbow.x;
    double shoulderX = leftElbow.likelihood > rightElbow.likelihood ? leftShoulder.x : rightShoulder.x;

    // If the elbow is more than 40px ahead of the shoulder → swinging cheat detected
    // (In ML Kit coordinates, a larger X value = further to the right in the raw image)
    bool isSwinging = (elbowX - shoulderX).abs() > 40 && (leftElbowAngle < 100 || rightElbowAngle < 100);

    if (isSwinging) {
      feedback = "Keep your elbow still, don't swing!";
      if (!hasFormError) onFormError(); // Trigger tts for form error
      hasFormError = true;
      repHadError = true; // Persistent memory to save that the elbow swung during the rep
      errorsFound.add("Elbow Swinging"); // Record the error type
    } else {
      hasFormError = false;
    }

    // Rep is only valid if Both arms are curled together
    bool bothAtPeak = leftElbowAngle < 60 && rightElbowAngle < 60;
    bool bothDown = leftElbowAngle > 150 && rightElbowAngle > 150;
    
    // Check for asymmetry curl
    if ((leftElbowAngle < 60 && rightElbowAngle > 100) || (rightElbowAngle < 60 && leftElbowAngle > 100)) {
      feedback = "Curl both arms together!";
      if (!hasFormError) onSymmetryError(); // Trigger tts for single arm curl error
      hasFormError = true;
      repHadError = true;
      errorsFound.add("Form Issues");
    }

    // top position detection (curl) --> Elbow < 60 
    if (bothAtPeak) {
      isUp = true;
      peakAchieved = true;
      if (!hasFormError) feedback = "Lower it down!";
    }
    // Partially curled but not high enough
    else if (leftElbowAngle < 90 || rightElbowAngle < 90) {
      isUp = true;
      if (!peakAchieved) {
        hasFormError = true;
        feedback = "Curl Higher!";
      }
    }

    // Bottom position detection (straight) --> Elbow > 150 
    if (bothDown) {
      if (isUp) {
        totalAttempts++; // counting every lowering as an attempt

        // Rep is counted only if peak was achieved AND no form errors occurred
        if (peakAchieved && !repHadError) {
          reps++;
          goodReps++;
          onRepCount(); // rep count audio feedback
          feedback = "Good Repp!";
          hasFormError = false;
        } else if (repHadError) {
          // If form was bad (elbow swinging), rep is not counted
          onFormError(); // Error audio feedback
          feedback = "Rep not counted, keep your elbow in a fixed position";
          hasFormError = true;
        } else if (!peakAchieved) {
          // If curl height wasn't enough, rep is not counted
          onFormError(); // Error audio feedback
          feedback = "You didn't curl high enough, try again";
          hasFormError = true;
          errorsFound.add("Shallow Curl");
        }

        // Reset state for next rep
        isUp = false;
        peakAchieved = false;
        repHadError = false;
      } else {
        if (!hasFormError) feedback = "Curl Up!";
      }
    }
  }
}