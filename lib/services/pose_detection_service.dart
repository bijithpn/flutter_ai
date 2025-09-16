import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:camera/camera.dart';
import '../models/models.dart';

/// Abstract interface for pose detection services
abstract class PoseDetectionService {
  /// Stream of pose detection results
  Stream<PoseData> get poseStream;

  /// Whether the service is currently detecting poses
  bool get isDetecting;

  /// Initialize the service with camera and model
  Future<void> initialize();

  /// Start pose detection
  Future<void> startDetection();

  /// Stop pose detection
  Future<void> stopDetection();

  /// Dispose of resources
  Future<void> dispose();
}

/// Mock implementation of pose detection service for development/testing
class TensorFlowLitePoseService implements PoseDetectionService {
  static const int _numKeypoints = 17;

  // MoveNet keypoint names in order
  static const List<String> _keypointNames = [
    'nose',
    'left_eye',
    'right_eye',
    'left_ear',
    'right_ear',
    'left_shoulder',
    'right_shoulder',
    'left_elbow',
    'right_elbow',
    'left_wrist',
    'right_wrist',
    'left_hip',
    'right_hip',
    'left_knee',
    'right_knee',
    'left_ankle',
    'right_ankle',
  ];

  CameraController? _cameraController;
  bool _isInitialized = false;
  bool _isDetecting = false;
  Timer? _mockDetectionTimer;
  final Random _random = Random();

  final StreamController<PoseData> _poseStreamController =
      StreamController<PoseData>.broadcast();

  @override
  Stream<PoseData> get poseStream => _poseStreamController.stream;

  @override
  bool get isDetecting => _isDetecting;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize camera
      await _initializeCamera();

      _isInitialized = true;
    } catch (e) {
      throw PoseDetectionException('Failed to initialize pose detection: $e');
    }
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      throw PoseDetectionException('No cameras available');
    }

    // Use front camera if available, otherwise use first camera
    final camera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );

    await _cameraController!.initialize();
  }

  @override
  Future<void> startDetection() async {
    if (!_isInitialized) {
      throw PoseDetectionException('Service not initialized');
    }

    if (_isDetecting) return;

    _isDetecting = true;

    // Start mock pose detection with timer
    _startMockDetection();
  }

  @override
  Future<void> stopDetection() async {
    if (!_isDetecting) return;

    _isDetecting = false;

    // Stop mock detection timer
    _mockDetectionTimer?.cancel();
    _mockDetectionTimer = null;
  }

  void _startMockDetection() {
    // Generate mock pose data every 100ms (10 FPS)
    _mockDetectionTimer = Timer.periodic(const Duration(milliseconds: 100), (
      timer,
    ) {
      if (!_isDetecting) {
        timer.cancel();
        return;
      }

      final mockPoseData = _generateMockPoseData();

      if (!_poseStreamController.isClosed) {
        _poseStreamController.add(mockPoseData);
      }
    });
  }

  PoseData _generateMockPoseData() {
    final keypoints = <KeyPoint>[];
    double totalConfidence = 0.0;

    // Generate realistic mock keypoints
    for (int i = 0; i < _numKeypoints; i++) {
      // Generate coordinates that simulate a person in frame
      double x, y, confidence;

      switch (_keypointNames[i]) {
        case 'nose':
          x = 0.5 + (_random.nextDouble() - 0.5) * 0.1;
          y = 0.2 + (_random.nextDouble() - 0.5) * 0.1;
          confidence = 0.8 + _random.nextDouble() * 0.2;
          break;
        case 'left_eye':
        case 'right_eye':
          x = 0.5 + (_random.nextDouble() - 0.5) * 0.15;
          y = 0.18 + (_random.nextDouble() - 0.5) * 0.08;
          confidence = 0.7 + _random.nextDouble() * 0.3;
          break;
        case 'left_shoulder':
          x = 0.35 + (_random.nextDouble() - 0.5) * 0.1;
          y = 0.35 + (_random.nextDouble() - 0.5) * 0.1;
          confidence = 0.6 + _random.nextDouble() * 0.4;
          break;
        case 'right_shoulder':
          x = 0.65 + (_random.nextDouble() - 0.5) * 0.1;
          y = 0.35 + (_random.nextDouble() - 0.5) * 0.1;
          confidence = 0.6 + _random.nextDouble() * 0.4;
          break;
        case 'left_elbow':
          x = 0.25 + (_random.nextDouble() - 0.5) * 0.15;
          y = 0.5 + (_random.nextDouble() - 0.5) * 0.15;
          confidence = 0.5 + _random.nextDouble() * 0.4;
          break;
        case 'right_elbow':
          x = 0.75 + (_random.nextDouble() - 0.5) * 0.15;
          y = 0.5 + (_random.nextDouble() - 0.5) * 0.15;
          confidence = 0.5 + _random.nextDouble() * 0.4;
          break;
        case 'left_wrist':
          x = 0.2 + (_random.nextDouble() - 0.5) * 0.2;
          y = 0.65 + (_random.nextDouble() - 0.5) * 0.2;
          confidence = 0.4 + _random.nextDouble() * 0.4;
          break;
        case 'right_wrist':
          x = 0.8 + (_random.nextDouble() - 0.5) * 0.2;
          y = 0.65 + (_random.nextDouble() - 0.5) * 0.2;
          confidence = 0.4 + _random.nextDouble() * 0.4;
          break;
        case 'left_hip':
          x = 0.4 + (_random.nextDouble() - 0.5) * 0.1;
          y = 0.7 + (_random.nextDouble() - 0.5) * 0.1;
          confidence = 0.6 + _random.nextDouble() * 0.3;
          break;
        case 'right_hip':
          x = 0.6 + (_random.nextDouble() - 0.5) * 0.1;
          y = 0.7 + (_random.nextDouble() - 0.5) * 0.1;
          confidence = 0.6 + _random.nextDouble() * 0.3;
          break;
        case 'left_knee':
          x = 0.38 + (_random.nextDouble() - 0.5) * 0.15;
          y = 0.85 + (_random.nextDouble() - 0.5) * 0.1;
          confidence = 0.5 + _random.nextDouble() * 0.4;
          break;
        case 'right_knee':
          x = 0.62 + (_random.nextDouble() - 0.5) * 0.15;
          y = 0.85 + (_random.nextDouble() - 0.5) * 0.1;
          confidence = 0.5 + _random.nextDouble() * 0.4;
          break;
        case 'left_ankle':
          x = 0.36 + (_random.nextDouble() - 0.5) * 0.15;
          y = 0.95 + (_random.nextDouble() - 0.5) * 0.05;
          confidence = 0.4 + _random.nextDouble() * 0.4;
          break;
        case 'right_ankle':
          x = 0.64 + (_random.nextDouble() - 0.5) * 0.15;
          y = 0.95 + (_random.nextDouble() - 0.5) * 0.05;
          confidence = 0.4 + _random.nextDouble() * 0.4;
          break;
        default:
          x = 0.5 + (_random.nextDouble() - 0.5) * 0.3;
          y = 0.5 + (_random.nextDouble() - 0.5) * 0.3;
          confidence = 0.3 + _random.nextDouble() * 0.4;
      }

      // Clamp values to valid ranges
      x = x.clamp(0.0, 1.0);
      y = y.clamp(0.0, 1.0);
      confidence = confidence.clamp(0.0, 1.0);

      keypoints.add(
        KeyPoint(name: _keypointNames[i], x: x, y: y, confidence: confidence),
      );

      totalConfidence += confidence;
    }

    final averageConfidence = totalConfidence / _numKeypoints;

    return PoseData(
      keyPoints: keypoints,
      confidence: averageConfidence,
      timestamp: DateTime.now(),
    );
  }

  @override
  Future<void> dispose() async {
    _isDetecting = false;

    _mockDetectionTimer?.cancel();
    _mockDetectionTimer = null;

    await _cameraController?.dispose();

    if (!_poseStreamController.isClosed) {
      await _poseStreamController.close();
    }

    _isInitialized = false;
  }

  /// Get camera controller for UI preview
  CameraController? get cameraController => _cameraController;
}

/// Exception thrown by pose detection service
class PoseDetectionException implements Exception {
  final String message;

  const PoseDetectionException(this.message);

  @override
  String toString() => 'PoseDetectionException: $message';
}
