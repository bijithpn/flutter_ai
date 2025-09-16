import 'package:flutter/material.dart';
import '../models/models.dart';

/// Widget that overlays pose detection visualization on camera preview
class PoseOverlay extends StatelessWidget {
  final PoseData? poseData;
  final Size previewSize;
  final double confidence;

  const PoseOverlay({
    super.key,
    required this.poseData,
    required this.previewSize,
    this.confidence = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    if (poseData == null) {
      return const SizedBox.shrink();
    }

    return CustomPaint(
      size: previewSize,
      painter: SkeletonPainter(poseData: poseData!, confidence: confidence),
    );
  }
}

/// Custom painter for drawing pose skeleton
class SkeletonPainter extends CustomPainter {
  final PoseData poseData;
  final double confidence;

  // Define skeleton connections (bone structure)
  static const List<List<String>> _connections = [
    // Head connections
    ['nose', 'left_eye'],
    ['nose', 'right_eye'],
    ['left_eye', 'left_ear'],
    ['right_eye', 'right_ear'],

    // Torso connections
    ['left_shoulder', 'right_shoulder'],
    ['left_shoulder', 'left_hip'],
    ['right_shoulder', 'right_hip'],
    ['left_hip', 'right_hip'],

    // Left arm connections
    ['left_shoulder', 'left_elbow'],
    ['left_elbow', 'left_wrist'],

    // Right arm connections
    ['right_shoulder', 'right_elbow'],
    ['right_elbow', 'right_wrist'],

    // Left leg connections
    ['left_hip', 'left_knee'],
    ['left_knee', 'left_ankle'],

    // Right leg connections
    ['right_hip', 'right_knee'],
    ['right_knee', 'right_ankle'],
  ];

  SkeletonPainter({required this.poseData, required this.confidence});

  @override
  void paint(Canvas canvas, Size size) {
    final validKeyPoints = poseData.getValidKeyPoints(threshold: confidence);

    if (validKeyPoints.isEmpty) return;

    // Create paint objects
    final keypointPaint = Paint()
      ..color = _getKeypointColor(poseData.confidence)
      ..style = PaintingStyle.fill;

    final connectionPaint = Paint()
      ..color = _getConnectionColor(poseData.confidence)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw connections (bones)
    _drawConnections(canvas, size, connectionPaint);

    // Draw keypoints
    _drawKeypoints(canvas, size, keypointPaint);

    // Draw confidence indicator
    _drawConfidenceIndicator(canvas, size);
  }

  void _drawConnections(Canvas canvas, Size size, Paint paint) {
    for (final connection in _connections) {
      final startPoint = poseData.getKeyPoint(connection[0]);
      final endPoint = poseData.getKeyPoint(connection[1]);

      if (startPoint != null &&
          endPoint != null &&
          startPoint.isValid(threshold: confidence) &&
          endPoint.isValid(threshold: confidence)) {
        final start = _normalizedToScreen(startPoint, size);
        final end = _normalizedToScreen(endPoint, size);

        // Adjust paint opacity based on average confidence
        final avgConfidence = (startPoint.confidence + endPoint.confidence) / 2;
        paint.color = paint.color.withValues(alpha: avgConfidence);

        canvas.drawLine(start, end, paint);
      }
    }
  }

  void _drawKeypoints(Canvas canvas, Size size, Paint paint) {
    for (final keypoint in poseData.keyPoints) {
      if (keypoint.isValid(threshold: confidence)) {
        final screenPoint = _normalizedToScreen(keypoint, size);

        // Adjust paint opacity and size based on confidence
        paint.color = _getKeypointColor(keypoint.confidence);
        final radius = _getKeypointRadius(keypoint.confidence);

        // Draw keypoint circle
        canvas.drawCircle(screenPoint, radius, paint);

        // Draw keypoint border
        final borderPaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;
        canvas.drawCircle(screenPoint, radius, borderPaint);
      }
    }
  }

  void _drawConfidenceIndicator(Canvas canvas, Size size) {
    // Draw overall confidence bar in top-right corner
    const barWidth = 100.0;
    const barHeight = 8.0;
    const margin = 16.0;

    final barRect = Rect.fromLTWH(
      size.width - barWidth - margin,
      margin,
      barWidth,
      barHeight,
    );

    // Background
    final backgroundPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(barRect, const Radius.circular(4)),
      backgroundPaint,
    );

    // Confidence fill
    final confidenceWidth = barWidth * poseData.confidence;
    final confidenceRect = Rect.fromLTWH(
      barRect.left,
      barRect.top,
      confidenceWidth,
      barHeight,
    );

    final confidencePaint = Paint()
      ..color = _getConfidenceBarColor(poseData.confidence)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(confidenceRect, const Radius.circular(4)),
      confidencePaint,
    );
  }

  Offset _normalizedToScreen(KeyPoint keypoint, Size size) {
    // Convert normalized coordinates [0, 1] to screen coordinates
    return Offset(keypoint.x * size.width, keypoint.y * size.height);
  }

  Color _getKeypointColor(double confidence) {
    if (confidence >= 0.8) {
      return Colors.green.withValues(alpha: confidence);
    } else if (confidence >= 0.6) {
      return Colors.orange.withValues(alpha: confidence);
    } else {
      return Colors.red.withValues(alpha: confidence);
    }
  }

  Color _getConnectionColor(double confidence) {
    if (confidence >= 0.7) {
      return Colors.blue.withValues(alpha: 0.8);
    } else if (confidence >= 0.5) {
      return Colors.orange.withValues(alpha: 0.6);
    } else {
      return Colors.red.withValues(alpha: 0.4);
    }
  }

  double _getKeypointRadius(double confidence) {
    // Radius between 4 and 8 based on confidence
    return 4.0 + (confidence * 4.0);
  }

  Color _getConfidenceBarColor(double confidence) {
    if (confidence >= 0.8) {
      return Colors.green;
    } else if (confidence >= 0.6) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  bool shouldRepaint(covariant SkeletonPainter oldDelegate) {
    return oldDelegate.poseData != poseData ||
        oldDelegate.confidence != confidence;
  }
}
