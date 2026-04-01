// // Lunges Logic 
// import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
// import 'workout_logic.dart'; // for angle calculations

// // Rules for a complete lunge movement
// class LungeCounter {
//   int reps = 0;          // Strict counter to only count valid reps only
//   int goodReps = 0;      // For reps summary countinh
//   int totalAttempts = 0; // to track every time the user stands back up after going down
//   bool isDown = false;   // track if the user has reached the bottom lunge position
//   bool depthAchieved = false; // tracks if the user actually hit the required lunge depth
//   bool hasFormError = false;  // tracks if there is currently a form error
//   bool repHadError = false;   // tracks if the current rep had a form mistake at any point
//   String feedback = "Get Ready!";

//   // store errors found during the set for review
//   Set<String> errorsFound = {};

//   // Lunge pose detection logic --> Opposite of squats
//   void processPose(Pose pose, {required Function() onRepCount, required Function() onFormError}) {

//     // landmarks needed for lunge detection
//     final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
//     final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
//     final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
//     final rightHip = pose.landmarks[PoseLandmarkType.rightHip];
//     final leftKnee = pose.landmarks[PoseLandmarkType.leftKnee];
//     final rightKnee = pose.landmarks[PoseLandmarkType.rightKnee];
//     final leftAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];
//     final rightAnkle = pose.landmarks[PoseLandmarkType.rightAnkle];

//     // Ensure all required points are visible before processing
//     if (leftShoulder == null || rightShoulder == null ||
//         leftHip == null || rightHip == null ||
//         leftKnee == null || rightKnee == null ||
//         leftAnkle == null || rightAnkle == null) {
//       feedback = "Ensure full body is visible";
//       return;
//     }

//     // Knee angle for rep counting (Hip --> Kneww --> Ankle)
//     double leftKneeAngle = PoseMath.getAngle(leftHip, leftKnee, leftAnkle);
//     double rightKneeAngle = PoseMath.getAngle(rightHip, rightKnee, rightAnkle);

//     // to identify front and back knee --> front knee is more bent which indicates the lunge depth
//     double frontKneeAngle = leftKneeAngle < rightKneeAngle ? leftKneeAngle : rightKneeAngle;
//     double backKneeAngle = leftKneeAngle < rightKneeAngle ? rightKneeAngle : leftKneeAngle;

//     // To validate its a lunge and not a squat movement
//     double kneeDiff = (leftKneeAngle - rightKneeAngle).abs();
//     if (kneeDiff < 20 && frontKneeAngle < 140) {
//       feedback = "This is a Squat movement!, Step one leg forward for a Lunge!";
//       if (!hasFormError) onFormError(); // Trigger voice once
//       hasFormError = true;
//       repHadError = true;
//       errorsFound.add("Incorrect Form");
//       return;
//     }

//     // Back Straightness check
//     double torsoAngle = leftShoulder.likelihood > rightShoulder.likelihood
//         ? PoseMath.getAngle(
//             PoseLandmark(type: PoseLandmarkType.leftShoulder, x: leftShoulder.x, y: leftShoulder.y - 100, z: 0, likelihood: 1),
//             leftHip, leftShoulder)
//         : PoseMath.getAngle(
//             PoseLandmark(type: PoseLandmarkType.rightShoulder, x: rightShoulder.x, y: rightShoulder.y - 100, z: 0, likelihood: 1),
//             rightHip, rightShoulder);

//     // If the torso leans forward more than 35 degrees, taking it as bad form
//     if (torsoAngle > 35) {
//       feedback = "Keep your torso upright!";
//       if (!hasFormError) onFormError(); // Trigger voice once
//       hasFormError = true;
//       repHadError = true; // Persistent memory that the torso leaned too much fot the review
//       errorsFound.add("Torso Lean"); // Record error type
//     } else {
//       hasFormError = false;
//     }

//     // Down position detection --> frontknee < 100 and backknee < 130 = bottom position of lunge
//     if (frontKneeAngle < 100 && backKneeAngle < 130) {
//       isDown = true;
//       depthAchieved = true;
//       if (!hasFormError) feedback = "Push Back Up!";
//     }
//     // down but not deep enough, marked as bad form
//     else if (frontKneeAngle < 135) {
//       isDown = true;
//       if (!depthAchieved) {
//         hasFormError = true;
//         feedback = "Lunge Deeper!";
//       }
//     }

//     // Up position detection --> both knees (> 160) straight 
//     if (leftKneeAngle > 160 && rightKneeAngle > 160) {
//       if (isDown) {
//         totalAttempts++; // count every stand-up as an attempt

//         // Rep is counted only if depth was achieved AND no form errors occurred
//         if (depthAchieved && !repHadError) {
//           reps++;
//           goodReps++;
//           onRepCount(); // rep count audio feedback
//           feedback = "Good Rep!";
//           hasFormError = false;
//         } else if (repHadError) {
//           // If form was bad, rep is not counted
//           onFormError(); // Error audio feedback
//           feedback = "Form was off, keep your torso upright";
//           hasFormError = true;
//         } else if (!depthAchieved) {
//           // If lunge depth was not enough, rep is not counted
//           onFormError(); // Error audio feedback
//           feedback = "Didn't lunge deep enough, try again";
//           hasFormError = true;
//           errorsFound.add("Shallow Depth");
//         }

//         // Reset state for next rep
//         isDown = false;
//         depthAchieved = false;
//         repHadError = false;
//       } else {
//         if (!hasFormError) feedback = "Lunge Down!";
//       }
//     }
//   }
// }