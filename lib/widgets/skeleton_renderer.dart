import 'package:flutter/material.dart';
import '../models/models.dart';

/// Advanced skeleton renderer widget for pose visualization
class SkeletonRenderer extends StatelessWidget {
  final PoseData? poseData;
  final Size renderSize;
  final double confidenceThreshold;
  final Color keypointColor;
  final Color connectionColor;
  final double keypointRadius;
  final double connectionWidth;
  final bool showConfidenceIndicator;
  final bool showKeyPointLabels;

  const SkeletonRenderer({
    super.key,
    required this.poseData,
    required this.renderSize,
    this.confidenceThreshold = 0.5,
    this.keypointColor = Colors.green,
    this.connectionColor = Colors.blue,
    this.keypointRadius = 6.0,
    this.connectionWidth = 3.0,
    this.showConfidenceIndicator = true,
    this.showKeyPointLabels = false,
  });

  @override
  Widget build(BuildContext context) {
    if (poseData == null) {
      return SizedBox.fromSize(size: renderSize);
    }

    return CustomPaint(
      size: renderSize,
      painter: AdvancedSkeletonPainter(
        poseData: poseData!,
        confidenceThreshold: confidenceThreshold,
        keypointColor: keypointColor,
        connectionColor: connectionColor,
        keypointRadius: keypointRadius,
        connectionWidth: connectionWidth,
        showConfidenceIndicator: showConfidenceIndicator,
        showKeyPointLabels: showKeyPointLabels,
      ),
    );
  }
}

/// Advanced custom painter for drawing pose skeleton with enhanced features
class AdvancedSkeletonPainter extends CustomPainter {
  final PoseData poseData;
  final double confidenceThreshold;
  final Color keypointColor;
  final Color connectionColor;
  final double keypointRadius;
  final double connectionWidth;
  final bool showConfidenceIndicator;
  final bool showKeyPointLabels;

  // Enhanced skeleton connections with body part groupings
  static const Map<String, List<List<String>>> _bodyPartConnections = {
    'head': [
      ['nose', 'left_eye'],
      ['nose', 'right_eye'],
      ['left_eye', 'left_ear'],
      ['right_eye', 'right_ear'],
    ],
    'torso': [
      ['left_shoulder', 'right_shoulder'],
      ['left_shoulder', 'left_hip'],
      ['right_shoulder', 'right_hip'],
      ['left_hip', 'right_hip'],
    ],
    'left_arm': [
      ['left_shoulder', 'left_elbow'],
      ['left_elbow', 'left_wrist'],
    ],
    'right_arm': [
      ['right_shoulder', 'right_elbow'],
      ['right_elbow', 'right_wrist'],
    ],
    'left_leg': [
      ['left_hip', 'left_knee'],
      ['left_knee', 'left_ankle'],
    ],
    'right_leg': [
      ['right_hip', 'right_knee'],
      ['right_knee', 'right_ankle'],
    ],
  };

  // Color scheme for different body parts
  static const Map<String, Color> _bodyPartColors = {
    'head': Colors.purple,
    'torso': Colors.blue,
    'left_arm': Colors.green,
    'right_arm': Colors.orange,
    'left_leg': Colors.red,
    'right_leg': Colors.cyan,
  };

  AdvancedSkeletonPainter({
    required this.poseData,
    required this.confidenceThreshold,
    required this.keypointColor,
    required this.connectionColor,
    required this.keypointRadius,
    required this.connectionWidth,
    required this.showConfidenceIndicator,
    required this.showKeyPointLabels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final validKeyPoints = poseData.getValidKeyPoints(
      threshold: confidenceThreshold,
    );

    if (validKeyPoints.isEmpty) return;

    // Draw connections by body part
    _drawBodyPartConnections(canvas, size);

    // Draw keypoints
    _drawKeypoints(canvas, size);

    // Draw keypoint labels if enabled
    if (showKeyPointLabels) {
      _drawKeyPointLabels(canvas, size);
    }

    // Draw confidence indicator if enabled
    if (showConfidenceIndicator) {
      _drawConfidenceIndicator(canvas, size);
    }

    // Draw pose quality indicator
    _drawPoseQualityIndicator(canvas, size);
  }

  void _drawBodyPartConnections(Canvas canvas, Size size) {
    for (final bodyPart in _bodyPartConnections.keys) {
      final connections = _bodyPartConnections[bodyPart]!;
      final bodyPartColor = _bodyPartColors[bodyPart] ?? connectionColor;

      for (final connection in connections) {
        final startPoint = poseData.getKeyPoint(connection[0]);
        final endPoint = poseData.getKeyPoint(connection[1]);

        if (startPoint != null &&
            endPoint != null &&
            startPoint.isValid(threshold: confidenceThreshold) &&
            endPoint.isValid(threshold: confidenceThreshold)) {
          final start = _normalizedToScreen(startPoint, size);
          final end = _normalizedToScreen(endPoint, size);

          // Calculate connection quality based on average confidence
          final avgConfidence =
              (startPoint.confidence + endPoint.confidence) / 2;
          final connectionPaint = Paint()
            ..color = bodyPartColor.withValues(alpha: avgConfidence)
            ..strokeWidth = connectionWidth * avgConfidence
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round;

          canvas.drawLine(start, end, connectionPaint);
        }
      }
    }
  }

  void _drawKeypoints(Canvas canvas, Size size) {
    for (final keypoint in poseData.keyPoints) {
      if (keypoint.isValid(threshold: confidenceThreshold)) {
        final screenPoint = _normalizedToScreen(keypoint, size);

        // Main keypoint circle
        final keypointPaint = Paint()
          ..color = _getKeypointColor(keypoint)
          ..style = PaintingStyle.fill;

        final radius = keypointRadius * keypoint.confidence;
        canvas.drawCircle(screenPoint, radius, keypointPaint);

        // Keypoint border
        final borderPaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.9)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;
        canvas.drawCircle(screenPoint, radius, borderPaint);

        // Inner confidence indicator
        if (keypoint.confidence > 0.8) {
          final innerPaint = Paint()
            ..color = Colors.white.withValues(alpha: 0.6)
            ..style = PaintingStyle.fill;
          canvas.drawCircle(screenPoint, radius * 0.4, innerPaint);
        }
      }
    }
  }

  void _drawKeyPointLabels(Canvas canvas, Size size) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (final keypoint in poseData.keyPoints) {
      if (keypoint.isValid(threshold: confidenceThreshold)) {
        final screenPoint = _normalizedToScreen(keypoint, size);

        textPainter.text = TextSpan(
          text: keypoint.name.replaceAll('_', ' ').toUpperCase(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.8),
                offset: const Offset(1, 1),
                blurRadius: 2,
              ),
            ],
          ),
        );

        textPainter.layout();

        // Position label above keypoint
        final labelOffset = Offset(
          screenPoint.dx - textPainter.width / 2,
          screenPoint.dy - keypointRadius - textPainter.height - 4,
        );

        textPainter.paint(canvas, labelOffset);
      }
    }
  }

  void _drawConfidenceIndicator(Canvas canvas, Size size) {
    const barWidth = 120.0;
    const barHeight = 12.0;
    const margin = 16.0;

    final barRect = Rect.fromLTWH(
      size.width - barWidth - margin,
      margin,
      barWidth,
      barHeight,
    );

    // Background
    final backgroundPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(barRect, const Radius.circular(6)),
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
      RRect.fromRectAndRadius(confidenceRect, const Radius.circular(6)),
      confidencePaint,
    );

    // Confidence text
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${(poseData.confidence * 100).toStringAsFixed(0)}%',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        barRect.center.dx - textPainter.width / 2,
        barRect.center.dy - textPainter.height / 2,
      ),
    );
  }

  void _drawPoseQualityIndicator(Canvas canvas, Size size) {
    final validKeyPoints = poseData.getValidKeyPoints(
      threshold: confidenceThreshold,
    );
    final totalKeyPoints = poseData.keyPoints.length;
    final visibilityRatio = validKeyPoints.length / totalKeyPoints;

    // Quality indicator in bottom-right corner
    const indicatorSize = 40.0;
    const margin = 16.0;

    final indicatorCenter = Offset(
      size.width - indicatorSize / 2 - margin,
      size.height - indicatorSize / 2 - margin,
    );

    // Background circle
    final backgroundPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(indicatorCenter, indicatorSize / 2, backgroundPaint);

    // Quality arc
    final qualityPaint = Paint()
      ..color = _getQualityColor(visibilityRatio)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * 3.14159 * visibilityRatio;
    canvas.drawArc(
      Rect.fromCenter(
        center: indicatorCenter,
        width: indicatorSize - 8,
        height: indicatorSize - 8,
      ),
      -3.14159 / 2, // Start from top
      sweepAngle,
      false,
      qualityPaint,
    );

    // Quality text
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${validKeyPoints.length}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        indicatorCenter.dx - textPainter.width / 2,
        indicatorCenter.dy - textPainter.height / 2,
      ),
    );
  }

  Offset _normalizedToScreen(KeyPoint keypoint, Size size) {
    return Offset(keypoint.x * size.width, keypoint.y * size.height);
  }

  Color _getKeypointColor(KeyPoint keypoint) {
    if (keypoint.confidence >= 0.8) {
      return Colors.green.withValues(alpha: keypoint.confidence);
    } else if (keypoint.confidence >= 0.6) {
      return Colors.orange.withValues(alpha: keypoint.confidence);
    } else {
      return Colors.red.withValues(alpha: keypoint.confidence);
    }
  }

  Color _getConfidenceBarColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.orange;
    return Colors.red;
  }

  Color _getQualityColor(double ratio) {
    if (ratio >= 0.8) return Colors.green;
    if (ratio >= 0.6) return Colors.orange;
    return Colors.red;
  }

  @override
  bool shouldRepaint(covariant AdvancedSkeletonPainter oldDelegate) {
    return oldDelegate.poseData != poseData ||
        oldDelegate.confidenceThreshold != confidenceThreshold ||
        oldDelegate.showConfidenceIndicator != showConfidenceIndicator ||
        oldDelegate.showKeyPointLabels != showKeyPointLabels;
  }
}
