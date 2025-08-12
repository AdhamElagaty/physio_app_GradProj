import 'package:flutter/material.dart';

class ExerciseControlsWidget extends StatelessWidget {
  final VoidCallback onStartPause;
  final VoidCallback onReset;
  final bool isExercising;
  final bool canStart;

  const ExerciseControlsWidget({
    super.key,
    required this.onStartPause,
    required this.onReset,
    required this.isExercising,
    required this.canStart,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            icon: Icon(isExercising
                ? Icons.pause_circle_filled
                : Icons.play_circle_filled),
            label: Text(isExercising ? 'PAUSE' : 'START'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: isExercising
                  ? Colors.orangeAccent
                  : Theme.of(context).colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            onPressed: canStart || isExercising ? onStartPause : null,
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('RESET'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[600],
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            onPressed: (isExercising || canStart)
                ? onReset
                : null, // Enable reset if ready or in progress
          ),
        ],
      ),
    );
  }
}
