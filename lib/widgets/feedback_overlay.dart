import 'package:flutter/material.dart';
import '../providers/providers.dart';

/// Widget that displays live feedback for posture correction
class FeedbackOverlay extends StatelessWidget {
  final String feedback;
  final FeedbackType feedbackType;
  final Duration sessionDuration;
  final double accuracyPercentage;
  final int correctPostureCount;
  final int totalPoseCount;

  const FeedbackOverlay({
    super.key,
    required this.feedback,
    required this.feedbackType,
    required this.sessionDuration,
    required this.accuracyPercentage,
    required this.correctPostureCount,
    required this.totalPoseCount,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent],
          ),
        ),
        padding: const EdgeInsets.fromLTRB(16, 48, 16, 24),
        child: Column(
          children: [
            // Session stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard(
                  icon: Icons.timer,
                  label: 'Time',
                  value: _formatDuration(sessionDuration),
                  color: Colors.blue,
                ),
                _buildStatCard(
                  icon: Icons.trending_up,
                  label: 'Accuracy',
                  value: '${accuracyPercentage.toStringAsFixed(1)}%',
                  color: _getAccuracyColor(accuracyPercentage),
                ),
                _buildStatCard(
                  icon: Icons.check_circle,
                  label: 'Good Poses',
                  value: '$correctPostureCount/$totalPoseCount',
                  color: Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Feedback message
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _getFeedbackBackgroundColor(feedbackType),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _getFeedbackBorderColor(feedbackType),
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getFeedbackIcon(feedbackType),
                    color: _getFeedbackIconColor(feedbackType),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      feedback,
                      style: TextStyle(
                        color: _getFeedbackTextColor(feedbackType),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= 80) return Colors.green;
    if (accuracy >= 60) return Colors.orange;
    return Colors.red;
  }

  Color _getFeedbackBackgroundColor(FeedbackType type) {
    switch (type) {
      case FeedbackType.positive:
        return Colors.green.withValues(alpha: 0.9);
      case FeedbackType.neutral:
        return Colors.blue.withValues(alpha: 0.9);
      case FeedbackType.warning:
        return Colors.orange.withValues(alpha: 0.9);
      case FeedbackType.error:
        return Colors.red.withValues(alpha: 0.9);
    }
  }

  Color _getFeedbackBorderColor(FeedbackType type) {
    switch (type) {
      case FeedbackType.positive:
        return Colors.green;
      case FeedbackType.neutral:
        return Colors.blue;
      case FeedbackType.warning:
        return Colors.orange;
      case FeedbackType.error:
        return Colors.red;
    }
  }

  Color _getFeedbackTextColor(FeedbackType type) {
    return Colors.white;
  }

  Color _getFeedbackIconColor(FeedbackType type) {
    return Colors.white;
  }

  IconData _getFeedbackIcon(FeedbackType type) {
    switch (type) {
      case FeedbackType.positive:
        return Icons.check_circle;
      case FeedbackType.neutral:
        return Icons.info;
      case FeedbackType.warning:
        return Icons.warning;
      case FeedbackType.error:
        return Icons.error;
    }
  }
}
