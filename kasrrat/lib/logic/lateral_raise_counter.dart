// Lateral Raise Logic
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'workout_logic.dart'; // for angle calculations

// Rules for a complete lateral raise movement
class LateralRaiseCounter {
  int reps = 0;          // Strict counter to only count valid reps only
  int goodReps = 0;      // Matches reps for summary review
  int totalAttempts = 0; // to track every time the user lowers arms after raising
  bool isUp = false;     // track if the user has reached the top position
  bool peakAchieved = false; // tracks if the user actually hit shoulder height
  bool hasFormError = false;  // tracks if there is a form error
  bool repHadError = false;   // tracks if the current rep had a form error at any point
  String feedback = "Get Ready!";

  // store errors found during the set for review
  Set<String> errorsFound = {};

  // Lateral raise pose detection logic
  void processPose(Pose pose, {required Function() onRepCount, required Function() onFormError}) {

    // Get landmarks needed for lateral raises
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final leftElbow = pose.landmarks[PoseLandmarkType.leftElbow];
    final rightElbow = pose.landmarks[PoseLandmarkType.rightElbow];
    final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
    final rightHip = pose.landmarks[PoseLandmarkType.rightHip];

    // Ensure upper body points are visible
    if (leftShoulder == null || rightShoulder == null ||
        leftElbow == null || rightElbow == null ||
        leftHip == null || rightHip == null) {
      feedback = "Ensure upper body is visible";
      return;
    }

    // Frontal Orientation rule, user are only allowed to perform the rep facing directly towards the camera if the shoulder width is too small user is standing sideways
    double shoulderWidth = (leftShoulder.x - rightShoulder.x).abs();
    double torsoHeight = (leftShoulder.y - leftHip.y).abs();

    if (shoulderWidth < torsoHeight * 0.5) {
      feedback = "Face directly infront of the camera";
      if (!hasFormError) onFormError(); 
      hasFormError = true;
      repHadError = true;
      errorsFound.add("Standing sideways");
      return; 
    }

    // for angle calculation the angle of hip --> shoulder --> elbow is calculated
    // arms down --> ( around 20 degree )
    // arms up around shoulder height --> ( around 90 degrees )
    double leftShoulderAngle = PoseMath.getAngle(leftHip, leftShoulder, leftElbow);
    double rightShoulderAngle = PoseMath.getAngle(rightHip, rightShoulder, rightElbow);

    // User must raise both arms for the rep to be counted
    double armDiff = (leftShoulderAngle - rightShoulderAngle).abs();
    if (armDiff > 25 && (leftShoulderAngle > 60 || rightShoulderAngle > 60)) {
      feedback = "Raise both arms evenly Together!";
      if (!hasFormError) onFormError();
      hasFormError = true;
      repHadError = true;
      errorsFound.add("Asymmetric Raise");
    } else {
      hasFormError = false;
    }

    // Top position --> arms at shoulder level
    if (leftShoulderAngle > 80 && rightShoulderAngle > 80) {
      isUp = true;
      peakAchieved = true;
      if (!hasFormError) feedback = "Now lower them slowly";
    }
    // Middle zone
    else if (leftShoulderAngle > 50 || rightShoulderAngle > 50) {
      isUp = true;
      if (!peakAchieved) {
        if (!hasFormError) feedback = "Raise to shoulder level!";
      }
    }

    // Bottom position --> arms down 
    if (leftShoulderAngle < 30 && rightShoulderAngle < 30) {
      if (isUp) {
        totalAttempts++; 

        if (peakAchieved && !repHadError) {
          reps++;
          goodReps++;
          onRepCount(); 
          feedback = "Good Repp!";
          hasFormError = false;
        } else if (repHadError) {
          onFormError(); 
          feedback = "Form was off, face the camera and be even";
          hasFormError = true;
        } else if (!peakAchieved) {
          onFormError();
          feedback = "Didn't raise high enough";
          hasFormError = true;
          errorsFound.add("Shallow Raise");
        }

        // Reset state
        isUp = false;
        peakAchieved = false;
        repHadError = false;
      } else {
        if (!hasFormError) feedback = "Raise your arms!";
      }
    }
  }
}