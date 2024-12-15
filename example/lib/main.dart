import 'dart:developer';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:hardware_button_listener/hardware_button_listener.dart';
import 'package:hardware_button_listener/models/hardware_button.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _lastButtonPressed = 'No button pressed yet';

  final _hardwareButtonListener = HardwareButtonListener();
  late StreamSubscription<HardwareButton> _buttonSubscription;

  @override
  void initState() {
    super.initState();
    // Start listening for hardware button events
    startListeningToHardwareButtons();
  }

  @override
  void dispose() {
    // Cancel the subscription to free up resources
    _buttonSubscription.cancel();
    super.dispose();
  }

  // Listen for hardware button events and update the UI
  void startListeningToHardwareButtons() {
    _hardwareButtonListener.listen((event) {
      log(event.buttonKey.toString());
      log(event.buttonName.toString());
      setState(() {
        _lastButtonPressed = event.buttonKey.toString();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Hardware Button Listener Example'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Last button pressed:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                _lastButtonPressed,
                style: const TextStyle(fontSize: 16, color: Colors.blueAccent),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
