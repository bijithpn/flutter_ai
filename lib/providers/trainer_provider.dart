import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import '../models/models.dart';
import '../services/services.dart';

/// Provider for managing trainer/pose detection state
class TrainerProvider extends ChangeNotifier {
  final PoseDetectionService _poseDetectionService;
  final StorageRepository<WorkoutSession> _workoutRepository;

  // State variables
  TrainerState _state = TrainerState.idle;
  String? _errorMessage;
  PoseData? _currentPose;
  WorkoutSession? _currentSession;
  List<WorkoutSession> _workoutHistory = [];
  String _selectedExercise = 'general';

  // Session tracking
  DateTime? _sessionStartTime;
  final List<PoseData> _sessionPoses = [];
  int _correctPostureCount = 0;
  Timer? _sessionTimer;
  Duration _sessionDuration = Duration.zero;

  // Feedback system
  String _currentFeedback = '';
  FeedbackType _feedbackType = FeedbackType.neutral;

  // Stream subscription
  StreamSubscription<PoseData>? _poseSubscription;

  TrainerProvider({
    required PoseDetectionService poseDetectionService,
    required StorageRepository<WorkoutSession> workoutRepository,
  }) : _poseDetectionService = poseDetectionService,
       _workoutRepository = workoutRepository {
    _loadWorkoutHistory();
  }

  // Getters
  TrainerState get state => _state;
  String? get errorMessage => _errorMessage;
  PoseData? get currentPose => _currentPose;
  WorkoutSession? get currentSession => _currentSession;
  List<WorkoutSession> get workoutHistory => List.unmodifiable(_workoutHistory);
  String get selectedExercise => _selectedExercise;
  Duration get sessionDuration => _sessionDuration;
  String get currentFeedback => _currentFeedback;
  FeedbackType get feedbackType => _feedbackType;
  int get correctPostureCount => _correctPostureCount;
  int get totalPoseCount => _sessionPoses.length;

  bool get isDetecting => _state == TrainerState.detecting;
  bool get hasError => _state == TrainerState.error;
  bool get isInitializing => _state == TrainerState.initializing;

  double get accuracyPercentage {
    if (_sessionPoses.isEmpty) return 0.0;
    return (_correctPostureCount / _sessionPoses.length) * 100;
  }

  CameraController? get cameraController {
    if (_poseDetectionService is TensorFlowLitePoseService) {
      return _poseDetectionService.cameraController;
    }
    return null;
  }

  /// Initialize the pose detection service
  Future<void> initialize() async {
    if (_state == TrainerState.initializing) return;

    _setState(TrainerState.initializing);
    _clearError();

    try {
      // Check camera permissions first
      final permissionStatus =
          await CameraPermissionService.getPermissionStatus();

      if (permissionStatus == CameraPermissionStatus.permanentlyDenied) {
        throw TrainerException(
          'Camera permission permanently denied. Please enable in settings.',
        );
      }

      if (permissionStatus == CameraPermissionStatus.denied) {
        final granted = await CameraPermissionService.requestPermission();
        if (!granted) {
          throw TrainerException(
            'Camera permission is required for pose detection.',
          );
        }
      }

      // Initialize pose detection service
      await _poseDetectionService.initialize();

      _setState(TrainerState.ready);
    } catch (e) {
      _setError('Failed to initialize camera: ${e.toString()}');
    }
  }

  /// Start pose detection and workout session
  Future<void> startDetection() async {
    if (_state != TrainerState.ready) {
      await initialize();
    }

    if (_state != TrainerState.ready) return;

    try {
      _setState(TrainerState.detecting);

      // Start new session
      _startNewSession();

      // Start pose detection
      await _poseDetectionService.startDetection();

      // Subscribe to pose stream
      _poseSubscription = _poseDetectionService.poseStream.listen(
        _onPoseDetected,
        onError: (error) {
          _setError('Pose detection error: ${error.toString()}');
        },
      );

      // Start session timer
      _startSessionTimer();
    } catch (e) {
      _setError('Failed to start pose detection: ${e.toString()}');
    }
  }

  /// Stop pose detection and end session
  Future<void> stopDetection() async {
    if (_state != TrainerState.detecting) return;

    try {
      // Stop pose detection
      await _poseDetectionService.stopDetection();

      // Cancel subscriptions and timers
      await _poseSubscription?.cancel();
      _poseSubscription = null;
      _sessionTimer?.cancel();
      _sessionTimer = null;

      // End current session
      await _endCurrentSession();

      _setState(TrainerState.ready);
    } catch (e) {
      _setError('Failed to stop pose detection: ${e.toString()}');
    }
  }

  /// Set the selected exercise type
  void setSelectedExercise(String exercise) {
    if (_selectedExercise != exercise) {
      _selectedExercise = exercise;
      notifyListeners();
    }
  }

  /// Clear any error messages
  void clearError() {
    _clearError();
  }

  void _onPoseDetected(PoseData poseData) {
    _currentPose = poseData;
    _sessionPoses.add(poseData);

    // Analyze pose and provide feedback
    _analyzePose(poseData);

    notifyListeners();
  }

  void _analyzePose(PoseData poseData) {
    // Enhanced pose analysis with exercise-specific feedback
    if (poseData.isReliable()) {
      final validKeyPoints = poseData.getValidKeyPoints();
      final feedback = _getExerciseSpecificFeedback(poseData, validKeyPoints);

      if (validKeyPoints.length >= 10) {
        // At least 10 visible keypoints - good pose
        _correctPostureCount++;
        _setFeedback(feedback.message, feedback.type);
      } else if (validKeyPoints.length >= 5) {
        _setFeedback('Good form, try to stay in frame', FeedbackType.neutral);
      } else {
        _setFeedback(
          'Move closer to camera for better detection',
          FeedbackType.warning,
        );
      }
    } else {
      _setFeedback('Pose detection confidence low', FeedbackType.warning);
    }
  }

  PoseFeedback _getExerciseSpecificFeedback(
    PoseData poseData,
    List<KeyPoint> validKeyPoints,
  ) {
    switch (_selectedExercise) {
      case 'pushup':
        return _analyzePushupForm(poseData, validKeyPoints);
      case 'squat':
        return _analyzeSquatForm(poseData, validKeyPoints);
      case 'plank':
        return _analyzePlankForm(poseData, validKeyPoints);
      default:
        return _analyzeGeneralForm(poseData, validKeyPoints);
    }
  }

  PoseFeedback _analyzePushupForm(
    PoseData poseData,
    List<KeyPoint> validKeyPoints,
  ) {
    final leftShoulder = poseData.getKeyPoint('left_shoulder');
    final rightShoulder = poseData.getKeyPoint('right_shoulder');
    final leftElbow = poseData.getKeyPoint('left_elbow');
    final rightElbow = poseData.getKeyPoint('right_elbow');
    final leftWrist = poseData.getKeyPoint('left_wrist');
    final rightWrist = poseData.getKeyPoint('right_wrist');

    if (leftShoulder != null &&
        rightShoulder != null &&
        leftElbow != null &&
        rightElbow != null &&
        leftWrist != null &&
        rightWrist != null) {
      // Check arm alignment
      final shoulderWidth = (leftShoulder.x - rightShoulder.x).abs();
      final wristWidth = (leftWrist.x - rightWrist.x).abs();

      if ((wristWidth - shoulderWidth).abs() < 0.1) {
        return PoseFeedback(
          'Perfect push-up form! Arms aligned!',
          FeedbackType.positive,
        );
      } else if (wristWidth > shoulderWidth + 0.15) {
        return PoseFeedback(
          'Hands too wide - bring them closer',
          FeedbackType.warning,
        );
      } else if (wristWidth < shoulderWidth - 0.15) {
        return PoseFeedback(
          'Hands too narrow - spread them wider',
          FeedbackType.warning,
        );
      }
    }

    return PoseFeedback('Good push-up position!', FeedbackType.positive);
  }

  PoseFeedback _analyzeSquatForm(
    PoseData poseData,
    List<KeyPoint> validKeyPoints,
  ) {
    final leftHip = poseData.getKeyPoint('left_hip');
    final rightHip = poseData.getKeyPoint('right_hip');
    final leftKnee = poseData.getKeyPoint('left_knee');
    final rightKnee = poseData.getKeyPoint('right_knee');
    final leftAnkle = poseData.getKeyPoint('left_ankle');
    final rightAnkle = poseData.getKeyPoint('right_ankle');

    if (leftHip != null &&
        rightHip != null &&
        leftKnee != null &&
        rightKnee != null &&
        leftAnkle != null &&
        rightAnkle != null) {
      // Check squat depth (hip position relative to knees)
      final avgHipY = (leftHip.y + rightHip.y) / 2;
      final avgKneeY = (leftKnee.y + rightKnee.y) / 2;

      if (avgHipY > avgKneeY + 0.05) {
        return PoseFeedback(
          'Great squat depth! Keep it up!',
          FeedbackType.positive,
        );
      } else if (avgHipY > avgKneeY - 0.05) {
        return PoseFeedback(
          'Good form - try to go a bit deeper',
          FeedbackType.neutral,
        );
      } else {
        return PoseFeedback(
          'Squat deeper - hips below knees',
          FeedbackType.warning,
        );
      }
    }

    return PoseFeedback('Good squat position!', FeedbackType.positive);
  }

  PoseFeedback _analyzePlankForm(
    PoseData poseData,
    List<KeyPoint> validKeyPoints,
  ) {
    final leftShoulder = poseData.getKeyPoint('left_shoulder');
    final rightShoulder = poseData.getKeyPoint('right_shoulder');
    final leftHip = poseData.getKeyPoint('left_hip');
    final rightHip = poseData.getKeyPoint('right_hip');
    final leftAnkle = poseData.getKeyPoint('left_ankle');
    final rightAnkle = poseData.getKeyPoint('right_ankle');

    if (leftShoulder != null &&
        rightShoulder != null &&
        leftHip != null &&
        rightHip != null &&
        leftAnkle != null &&
        rightAnkle != null) {
      // Check body alignment (straight line from shoulders to ankles)
      final avgShoulderY = (leftShoulder.y + rightShoulder.y) / 2;
      final avgHipY = (leftHip.y + rightHip.y) / 2;
      final avgAnkleY = (leftAnkle.y + rightAnkle.y) / 2;

      final shoulderHipDiff = (avgShoulderY - avgHipY).abs();
      final hipAnkleDiff = (avgHipY - avgAnkleY).abs();

      if (shoulderHipDiff < 0.05 && hipAnkleDiff < 0.1) {
        return PoseFeedback(
          'Perfect plank! Body is straight!',
          FeedbackType.positive,
        );
      } else if (avgHipY > avgShoulderY + 0.05) {
        return PoseFeedback(
          'Lower your hips for better alignment',
          FeedbackType.warning,
        );
      } else if (avgHipY < avgShoulderY - 0.05) {
        return PoseFeedback('Raise your hips slightly', FeedbackType.warning);
      }
    }

    return PoseFeedback('Good plank position!', FeedbackType.positive);
  }

  PoseFeedback _analyzeGeneralForm(
    PoseData poseData,
    List<KeyPoint> validKeyPoints,
  ) {
    if (validKeyPoints.length >= 12) {
      return PoseFeedback('Excellent pose detection!', FeedbackType.positive);
    } else if (validKeyPoints.length >= 8) {
      return PoseFeedback('Good form! Keep it up!', FeedbackType.positive);
    } else {
      return PoseFeedback(
        'Stay in frame for better tracking',
        FeedbackType.neutral,
      );
    }
  }

  void _setFeedback(String message, FeedbackType type) {
    _currentFeedback = message;
    _feedbackType = type;
  }

  void _startNewSession() {
    _sessionStartTime = DateTime.now();
    _sessionPoses.clear();
    _correctPostureCount = 0;
    _sessionDuration = Duration.zero;
    _setFeedback('Session started! Begin your exercise', FeedbackType.positive);
  }

  void _startSessionTimer() {
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_sessionStartTime != null) {
        _sessionDuration = DateTime.now().difference(_sessionStartTime!);
        notifyListeners();
      }
    });
  }

  Future<void> _endCurrentSession() async {
    if (_sessionStartTime == null) return;

    final session = WorkoutSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      exerciseType: _selectedExercise,
      duration: _sessionDuration,
      poseHistory: List.from(_sessionPoses),
      correctPostureCount: _correctPostureCount,
      startTime: _sessionStartTime!,
    );

    try {
      // Save session to storage
      await _workoutRepository.save(session.id, session);

      // Add to history
      _workoutHistory.insert(0, session);
      _currentSession = session;

      _setFeedback(
        'Session completed! Accuracy: ${session.accuracyPercentage.toStringAsFixed(1)}%',
        FeedbackType.positive,
      );
    } catch (e) {
      debugPrint('Failed to save workout session: $e');
    }
  }

  Future<void> _loadWorkoutHistory() async {
    try {
      _workoutHistory = await _workoutRepository.loadAll();
      _workoutHistory.sort((a, b) => b.startTime.compareTo(a.startTime));
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load workout history: $e');
    }
  }

  void _setState(TrainerState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }

  void _setError(String message) {
    _errorMessage = message;
    _setState(TrainerState.error);
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      if (_state == TrainerState.error) {
        _setState(TrainerState.idle);
      }
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _poseSubscription?.cancel();
    _sessionTimer?.cancel();
    _poseDetectionService.dispose();
    super.dispose();
  }
}

/// Trainer state enum
enum TrainerState { idle, initializing, ready, detecting, error }

/// Feedback type enum
enum FeedbackType { positive, neutral, warning, error }

/// Custom exception for trainer errors
class TrainerException implements Exception {
  final String message;

  const TrainerException(this.message);

  @override
  String toString() => 'TrainerException: $message';
}

/// Pose feedback data class
class PoseFeedback {
  final String message;
  final FeedbackType type;

  const PoseFeedback(this.message, this.type);
}
