import 'package:flutter/material.dart';
import 'dart:math' as math;

class DrivingControls extends StatefulWidget {
  final Function(double) onSteer;
  final Function(double) onGas;
  final Function(double) onBrake;
  final Function(int) onGearChange;

  const DrivingControls({
    super.key,
    required this.onSteer,
    required this.onGas,
    required this.onBrake,
    required this.onGearChange,
  });

  @override
  State<DrivingControls> createState() => _DrivingControlsState();
}

class _DrivingControlsState extends State<DrivingControls> {
  double _steeringValue = 0.0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Left: Steering Wheel
        Positioned(
          bottom: 40,
          left: 40,
          child: GestureDetector(
            onPanUpdate: (details) {
              // Simple steering logic based on horizontal drag
              setState(() {
                _steeringValue += details.delta.dx * 0.01;
                _steeringValue = _steeringValue.clamp(-1.0, 1.0);
              });
              widget.onSteer(_steeringValue);
            },
            onPanEnd: (_) {
              // Auto-center steering
              setState(() => _steeringValue = 0.0);
              widget.onSteer(0.0);
            },
            child: Transform.rotate(
              angle: _steeringValue * math.pi, // Visual rotation
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  gradient: const RadialGradient(
                    colors: [Colors.black54, Colors.black87],
                  ),
                ),
                child: const Icon(Icons.directions_car, color: Colors.white, size: 40),
              ),
            ),
          ),
        ),

        // Right: Pedals
        Positioned(
          bottom: 40,
          right: 40,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Brake
              _buildPedal(
                label: "BRAKE",
                color: Colors.redAccent,
                onPress: widget.onBrake,
              ),
              const SizedBox(width: 20),
              // Gas
              _buildPedal(
                label: "GAS",
                color: Colors.greenAccent,
                onPress: widget.onGas,
              ),
            ],
          ),
        ),

        // Top Right: Gear Shift
        Positioned(
          top: 40,
          right: 40,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildGearBtn("D", 2),
                const SizedBox(height: 8),
                _buildGearBtn("N", 1),
                const SizedBox(height: 8),
                _buildGearBtn("R", 0),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPedal({required String label, required Color color, required Function(double) onPress}) {
    return GestureDetector(
      onTapDown: (_) => onPress(1.0),
      onTapUp: (_) => onPress(0.0),
      onTapCancel: () => onPress(0.0),
      child: Container(
        width: 60,
        height: 120,
        decoration: BoxDecoration(
          color: color.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Center(
          child: RotatedBox(
            quarterTurns: 3,
            child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget _buildGearBtn(String label, int gearIndex) {
    return GestureDetector(
      onTap: () => widget.onGearChange(gearIndex),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white24,
          shape: BoxShape.circle,
        ),
        child: Center(child: Text(label, style: const TextStyle(color: Colors.white))),
      ),
    );
  }
}
