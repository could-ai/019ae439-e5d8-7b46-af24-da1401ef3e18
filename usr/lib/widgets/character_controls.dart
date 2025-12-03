import 'package:flutter/material.dart';

class CharacterControls extends StatelessWidget {
  final Function(Offset) onMove;
  final VoidCallback onEnterCar;

  const CharacterControls({
    super.key,
    required this.onMove,
    required this.onEnterCar,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Joystick (Simulated)
        Positioned(
          bottom: 50,
          left: 50,
          child: GestureDetector(
            onPanUpdate: (details) {
              onMove(details.delta);
            },
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.2),
                border: Border.all(color: Colors.white30),
              ),
              child: Center(
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Action Buttons
        Positioned(
          bottom: 50,
          right: 50,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                onPressed: onEnterCar,
                backgroundColor: Colors.blue,
                child: const Icon(Icons.directions_car),
              ),
              const SizedBox(height: 16),
              FloatingActionButton(
                onPressed: () {}, // Jump or Interact
                backgroundColor: Colors.grey,
                child: const Icon(Icons.arrow_upward),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
