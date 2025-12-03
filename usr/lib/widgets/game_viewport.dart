import 'package:flutter/material.dart';
import 'dart:math' as math;

class GameViewport extends StatelessWidget {
  final dynamic mode; // GameMode
  final double speed;
  final double steeringAngle;
  final double distanceTraveled;

  const GameViewport({
    super.key,
    required this.mode,
    required this.speed,
    required this.steeringAngle,
    required this.distanceTraveled,
  });

  @override
  Widget build(BuildContext context) {
    // This simulates the 3D world render
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0D1B2A), // Night Sky
            Color(0xFF1B263B), // Horizon
            Color(0xFF415A77), // Ground/Road
          ],
          stops: [0.0, 0.4, 0.4],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Moving Road Lines (Simulation of speed)
          ...List.generate(5, (index) {
            double perspective = (index + 1) / 5;
            double offset = (distanceTraveled * 10 + index * 100) % 500;
            return Positioned(
              bottom: 0,
              left: MediaQuery.of(context).size.width / 2 - (10 * perspective),
              height: offset, // Simple perspective trick
              child: Transform.translate(
                offset: Offset(steeringAngle * -50 * perspective, 0),
                child: Container(
                  width: 20 * perspective,
                  height: 100,
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
            );
          }),

          // City Skyline (Parallax)
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.6,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(10, (index) {
                return Container(
                  width: 30 + (index % 3) * 20,
                  height: 50 + (index % 5) * 30,
                  color: Colors.black54,
                );
              }),
            ),
          ),

          // The Car (Interior or Exterior based on mode)
          if (mode.toString() == 'GameMode.driving' || mode.toString() == 'GameMode.entering')
            Align(
              alignment: Alignment.bottomCenter,
              child: Transform.rotate(
                angle: steeringAngle * 0.1, // Body roll
                child: Image.network(
                  'https://purepng.com/public/uploads/large/purepng.com-bmw-m5-white-carcarbmwvehicletransport-961524663045u6e7g.png', // Placeholder BMW M5
                  height: 300,
                  fit: BoxFit.contain,
                  errorBuilder: (c, e, s) => const Icon(Icons.directions_car, size: 200, color: Colors.white),
                ),
              ),
            ),
            
          // Character (Third Person)
          if (mode.toString() == 'GameMode.walking')
            const Align(
              alignment: Alignment.center,
              child: Icon(Icons.person, size: 100, color: Colors.white),
            ),
        ],
      ),
    );
  }
}
