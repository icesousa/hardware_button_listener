import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'hardware_button_listener_platform_interface.dart';

/// An implementation of [HardwareButtonListenerPlatform] that uses method channels.
class MethodChannelHardwareButtonListener
    extends HardwareButtonListenerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('hardware_button_listener');
  final eventChannel = const EventChannel('hardware_button_listener_event');
}
