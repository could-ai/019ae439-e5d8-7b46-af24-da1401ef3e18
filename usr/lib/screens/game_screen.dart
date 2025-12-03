import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/game_viewport.dart';
import '../widgets/dashboard_overlay.dart';
import '../widgets/driving_controls.dart';
import '../widgets/character_controls.dart';

enum GameMode { walking, driving, entering, exiting }

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  // Game State
  GameMode _mode = GameMode.walking;
  
  // Car Physics State
  double _speed = 0.0; // km/h
  double _rpm = 0.0;
  double _steeringAngle = 0.0;
  double _gasPedal = 0.0;
  double _brakePedal = 0.0;
  int _gear = 1; // 0: R, 1: N, 2: D
  
  // World State
  double _distanceTraveled = 0.0;
  
  // Character State
  Offset _characterPosition = const Offset(0, 0);
  
  // Animation Controllers
  late AnimationController _doorController;
  Timer? _gameLoop;

  @override
  void initState() {
    super.initState();
    _doorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    // Start Game Loop (60 FPS)
    _gameLoop = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      _updatePhysics();
    });
  }

  @override
  void dispose() {
    _gameLoop?.cancel();
    _doorController.dispose();
    super.dispose();
  }

  void _updatePhysics() {
    setState(() {
      if (_mode == GameMode.driving) {
        // Simple Car Physics Simulation
        if (_gasPedal > 0) {
          _speed += _gasPedal * 0.5;
          _rpm += _gasPedal * 100;
        } else {
          _speed *= 0.99; // Friction
          _rpm = max(800, _rpm * 0.98); // Idle RPM
        }

        if (_brakePedal > 0) {
          _speed -= _brakePedal * 1.0;
        }

        // Cap speed and RPM
        _speed = _speed.clamp(0.0, 320.0); // Max 320 km/h
        _rpm = _rpm.clamp(800.0, 8000.0); // Max 8000 RPM

        // Simulate movement
        _distanceTraveled += _speed * 0.01;
      }
    });
  }

  void _toggleEnterExit() async {
    if (_mode == GameMode.walking) {
      // Enter Car Sequence
      setState(() => _mode = GameMode.entering);
      await _doorController.forward();
      // Simulate sitting animation delay
      await Future.delayed(const Duration(milliseconds: 500));
      await _doorController.reverse();
      setState(() => _mode = GameMode.driving);
    } else if (_mode == GameMode.driving) {
      // Exit Car Sequence
      setState(() => _mode = GameMode.exiting);
      await _doorController.forward();
      // Simulate getting out delay
      await Future.delayed(const Duration(milliseconds: 500));
      await _doorController.reverse();
      setState(() => _mode = GameMode.walking);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. 3D World Viewport (Simulated)
          GameViewport(
            mode: _mode,
            speed: _speed,
            steeringAngle: _steeringAngle,
            distanceTraveled: _distanceTraveled,
          ),

          // 2. HUD & Dashboard (Only visible when driving)
          if (_mode == GameMode.driving || _mode == GameMode.entering || _mode == GameMode.exiting)
            DashboardOverlay(
              speed: _speed,
              rpm: _rpm,
              gear: _gear,
              opacity: _mode == GameMode.driving ? 1.0 : 0.5,
            ),

          // 3. Controls Layer
          SafeArea(
            child: Stack(
              children: [
                // Driving Controls
                if (_mode == GameMode.driving)
                  DrivingControls(
                    onSteer: (val) => _steeringAngle = val,
                    onGas: (val) => _gasPedal = val,
                    onBrake: (val) => _brakePedal = val,
                    onGearChange: (val) => setState(() => _gear = val),
                  ),

                // Character Controls
                if (_mode == GameMode.walking)
                  CharacterControls(
                    onMove: (offset) => setState(() {
                      _characterPosition += offset;
                    }),
                    onEnterCar: _toggleEnterExit,
                  ),
                  
                // Enter/Exit Button (Contextual)
                if (_mode == GameMode.driving)
                   Positioned(
                    top: 20,
                    right: 20,
                    child: IconButton(
                      icon: const Icon(Icons.exit_to_app, color: Colors.white, size: 30),
                      onPressed: _toggleEnterExit,
                      style: IconButton.styleFrom(backgroundColor: Colors.black54),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
