import 'package:flutter/material.dart';
import 'package:flutter_location_button/flutter_location_button.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool? _granted;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Location Button Example')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Tap the button below to request location authorization:',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              Center(
                child: LocationButton(
                  width: double.maxFinite,
                  options: const LocationButtonOptions(
                    android: AndroidLocationButtonOptions(
                      cornerRadius: 16,
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      text: AndroidLocationButtonText.usePreciseLocation,
                    ),
                  ),
                  onPermissionResult: (granted) => setState(() {
                    _granted = granted;
                    _error = null;
                  }),
                  onPermissionError: (e) =>
                      setState(() => _error = e.toString()),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Permission granted: ${_granted ?? '-'}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Error: $_error',
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
