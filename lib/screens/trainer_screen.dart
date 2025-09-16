import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';

class TrainerScreen extends StatefulWidget {
  const TrainerScreen({super.key});

  @override
  State<TrainerScreen> createState() => _TrainerScreenState();
}

class _TrainerScreenState extends State<TrainerScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Consumer<TrainerProvider>(
      builder: (context, trainerProvider, child) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: _buildBody(context, trainerProvider),
          floatingActionButton: _buildFloatingActionButton(
            context,
            trainerProvider,
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, TrainerProvider trainerProvider) {
    switch (trainerProvider.state) {
      case TrainerState.idle:
        return _buildWelcomeScreen(context, trainerProvider);
      case TrainerState.initializing:
        return _buildInitializingScreen();
      case TrainerState.ready:
        return _buildReadyScreen(context, trainerProvider);
      case TrainerState.detecting:
        return _buildDetectionScreen(context, trainerProvider);
      case TrainerState.error:
        return _buildErrorScreen(context, trainerProvider);
    }
  }

  Widget _buildWelcomeScreen(
    BuildContext context,
    TrainerProvider trainerProvider,
  ) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Hero(
              tag: 'trainer-icon',
              child: Icon(Icons.fitness_center, size: 100, color: Colors.white),
            ),
            const SizedBox(height: 32),
            const Text(
              'AI Personal Trainer',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Get real-time pose detection and feedback during exercises to maintain proper form',
              style: TextStyle(fontSize: 16, color: Colors.grey[300]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),

            // Exercise selection
            _buildExerciseSelector(trainerProvider),

            const SizedBox(height: 32),

            // Workout history preview
            if (trainerProvider.workoutHistory.isNotEmpty)
              _buildWorkoutHistoryPreview(trainerProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseSelector(TrainerProvider trainerProvider) {
    const exercises = [
      {'id': 'general', 'name': 'General', 'icon': Icons.fitness_center},
      {'id': 'pushup', 'name': 'Push-ups', 'icon': Icons.accessibility_new},
      {
        'id': 'squat',
        'name': 'Squats',
        'icon': Icons.airline_seat_legroom_reduced,
      },
      {'id': 'plank', 'name': 'Plank', 'icon': Icons.horizontal_rule},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Exercise',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: exercises.map((exercise) {
            final isSelected =
                trainerProvider.selectedExercise == exercise['id'];
            return GestureDetector(
              onTap: () =>
                  trainerProvider.setSelectedExercise(exercise['id'] as String),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue : Colors.grey[800],
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey[600]!,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      exercise['icon'] as IconData,
                      color: isSelected ? Colors.white : Colors.grey[300],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      exercise['name'] as String,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[300],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildWorkoutHistoryPreview(TrainerProvider trainerProvider) {
    final lastWorkout = trainerProvider.workoutHistory.first;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Last Workout',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                lastWorkout.exerciseType.toUpperCase(),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[300],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${lastWorkout.accuracyPercentage.toStringAsFixed(1)}% accuracy',
                style: TextStyle(
                  fontSize: 14,
                  color: lastWorkout.accuracyPercentage >= 70
                      ? Colors.green
                      : Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInitializingScreen() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.blue),
          SizedBox(height: 24),
          Text(
            'Initializing camera...',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildReadyScreen(
    BuildContext context,
    TrainerProvider trainerProvider,
  ) {
    final cameraController = trainerProvider.cameraController;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return _buildInitializingScreen();
    }

    return Stack(
      children: [
        // Camera preview
        Positioned.fill(child: CameraPreview(cameraController)),

        // Ready overlay
        Positioned(
          bottom: 100,
          left: 0,
          right: 0,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Icon(Icons.videocam, color: Colors.green, size: 32),
                const SizedBox(height: 8),
                const Text(
                  'Camera Ready',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Exercise: ${trainerProvider.selectedExercise.toUpperCase()}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[300]),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetectionScreen(
    BuildContext context,
    TrainerProvider trainerProvider,
  ) {
    final cameraController = trainerProvider.cameraController;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return _buildInitializingScreen();
    }

    return Stack(
      children: [
        // Camera preview
        Positioned.fill(child: CameraPreview(cameraController)),

        // Pose overlay with enhanced skeleton renderer
        if (trainerProvider.currentPose != null)
          Positioned.fill(
            child: SkeletonRenderer(
              poseData: trainerProvider.currentPose,
              renderSize: MediaQuery.of(context).size,
              confidenceThreshold: 0.5,
              showConfidenceIndicator: true,
              showKeyPointLabels: false,
            ),
          ),

        // Feedback overlay
        FeedbackOverlay(
          feedback: trainerProvider.currentFeedback,
          feedbackType: trainerProvider.feedbackType,
          sessionDuration: trainerProvider.sessionDuration,
          accuracyPercentage: trainerProvider.accuracyPercentage,
          correctPostureCount: trainerProvider.correctPostureCount,
          totalPoseCount: trainerProvider.totalPoseCount,
        ),
      ],
    );
  }

  Widget _buildErrorScreen(
    BuildContext context,
    TrainerProvider trainerProvider,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.red),
            const SizedBox(height: 24),
            const Text(
              'Error',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              trainerProvider.errorMessage ?? 'An unknown error occurred',
              style: TextStyle(fontSize: 16, color: Colors.grey[300]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                trainerProvider.clearError();
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(
    BuildContext context,
    TrainerProvider trainerProvider,
  ) {
    switch (trainerProvider.state) {
      case TrainerState.idle:
        return FloatingActionButton.extended(
          onPressed: () => trainerProvider.initialize(),
          icon: const Icon(Icons.videocam),
          label: const Text('Start Training'),
          heroTag: 'trainer-fab',
          backgroundColor: Colors.blue,
        );

      case TrainerState.ready:
        return FloatingActionButton.extended(
          onPressed: () => trainerProvider.startDetection(),
          icon: const Icon(Icons.play_arrow),
          label: const Text('Begin Exercise'),
          heroTag: 'trainer-fab',
          backgroundColor: Colors.green,
        );

      case TrainerState.detecting:
        return FloatingActionButton.extended(
          onPressed: () => trainerProvider.stopDetection(),
          icon: const Icon(Icons.stop),
          label: const Text('Stop Training'),
          heroTag: 'trainer-fab',
          backgroundColor: Colors.red,
        );

      case TrainerState.initializing:
        return FloatingActionButton.extended(
          onPressed: null,
          icon: const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          label: const Text('Initializing...'),
          heroTag: 'trainer-fab',
          backgroundColor: Colors.grey,
        );

      case TrainerState.error:
        return FloatingActionButton.extended(
          onPressed: () => trainerProvider.clearError(),
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
          heroTag: 'trainer-fab',
          backgroundColor: Colors.orange,
        );
    }
  }
}
