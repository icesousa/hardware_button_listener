# Hardware Button Listener

**Hardware Button Listener** is a Flutter package that allows you to listen to physical hardware button presses on Android devices, such as volume buttons or other device-specific keys like devices with attached QRCODE read button.

## Features

- Detect physical hardware button presses.
- Provides key information, such as button name and key code.
- Easy-to-use API with a reactive stream-based approach.

## Installation

Add the following dependency to your `pubspec.yaml` file:

```yaml
dependencies:
  hardware_button_listener: latest_version
```

Run the command to fetch the package:

```sh
flutter pub get
```

## Usage

Here's an example of how to use the **Hardware Button Listener** package:

### Full Example

```dart

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
    _buttonSubscription = _hardwareButtonListener.listen((event) {
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
```

### Key Concepts

- **`HardwareButtonListener`**: The main class that provides a stream for listening to hardware button events.
- **`HardwareButton`**: A model representing the button press event, containing properties like `buttonKey` and `buttonName`.

### Handling Events

Use the `listen` method of `HardwareButtonListener` to subscribe to button press events and handle them as needed.

```dart
_hardwareButtonListener.listen((event) {
  print('Button Key: ${event.buttonKey}');
  print('Button Name: ${event.buttonName}');
  if(event.buttonKey == 120){
  doSomething();
  }
});
```

## Important Notes

- This package currently supports Android only.
- Ensure proper permissions and configurations are set if required by your specific device.

## Contributions

Contributions are welcome! Feel free to open issues or submit pull requests on the [GitHub repository](https://github.com/icesousa/hardware_button_listener).


