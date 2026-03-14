import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PoseDetectorService {
  final PoseDetector _poseDetector = PoseDetector(
    options: PoseDetectorOptions(
      mode: PoseDetectionMode.stream,
      model: PoseDetectionModel.base,
    ),
  );

  Future<List<Pose>> detectPose(InputImage inputImage) async {
    try {
      return await _poseDetector.processImage(inputImage);
    } catch (e) {
      return [];
    }
  }

  void dispose() {
    _poseDetector.close();
  }
}