import 'package:flutter/material.dart';
import 'dart:math' as math;

class DashboardOverlay extends StatelessWidget {
  final double speed;
  final double rpm;
  final int gear;
  final double opacity;

  const DashboardOverlay({
    super.key,
    required this.speed,
    required this.rpm,
    required this.gear,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: MainAxisAlignment.end,
            children: [
              // Left: RPM Gauge
              _buildGauge(
                label: "RPM",
                value: rpm,
                maxValue: 8000,
                color: Colors.orangeAccent,
              ),
              
              // Center: Digital Speed & Gear
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    _getGearLabel(gear),
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.yellowAccent,
                    ),
                  ),
                  Text(
                    "${speed.toInt()}",
                    style: const TextStyle(
                      fontSize: 80,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      fontFamily: 'Courier', // Monospaced for digital look
                    ),
                  ),
                  const Text(
                    "KM/H",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                ],
              ),

              // Right: Turbo/Fuel (Mock)
              _buildGauge(
                label: "TURBO",
                value: rpm * 0.0001, // Mock turbo pressure
                maxValue: 1.0,
                color: Colors.blueAccent,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getGearLabel(int gear) {
    switch (gear) {
      case 0: return "R";
      case 1: return "N";
      case 2: return "D";
      default: return "D";
    }
  }

  Widget _buildGauge({required String label, required double value, required double maxValue, required Color color}) {
    return SizedBox(
      width: 150,
      height: 150,
      child: CustomPaint(
        painter: GaugePainter(value: value, maxValue: maxValue, color: color),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}

class GaugePainter extends CustomPainter {
  final double value;
  final double maxValue;
  final Color color;

  GaugePainter({required this.value, required this.maxValue, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final startAngle = -math.pi * 1.2;
    final sweepAngle = math.pi * 1.4;

    // Background Arc
    final bgPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      bgPaint,
    );

    // Value Arc
    final valuePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    final currentSweep = (value / maxValue).clamp(0.0, 1.0) * sweepAngle;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      currentSweep,
      false,
      valuePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
