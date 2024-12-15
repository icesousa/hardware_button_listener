import 'dart:async';

import 'package:flutter/services.dart';
import 'package:hardware_button_listener/models/hardware_button.dart';

class HardwareButtonListener {
  /// Listens for hardware button events.
  ///
  /// The stream emits [HardwareButton] instances for  physical pressed buttons
  ///
  /// Example usage:
  /// ```dart
  /// final subscription = HardwareButtonListener().listen((event) {
  ///   print('Button pressed: ${event.type}');
  /// });
  /// ```
  /// Returns a [StreamSubscription] for managing the event stream.
  StreamSubscription<HardwareButton> listen(
    void Function(HardwareButton event) onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    const EventChannel streamEventsChannel = EventChannel(
      'hardware_button_listener_event',
      HardwareButtonMethodCodec(),
    );

    return streamEventsChannel.receiveBroadcastStream().map((dynamic event) {
      if (event is HardwareButton) {
        return HardwareButton.decode(event);
      }
      throw Exception('Invalid event type: $event');
    }).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}
