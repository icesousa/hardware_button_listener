import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'hardware_button_listener_method_channel.dart';

abstract class HardwareButtonListenerPlatform extends PlatformInterface {
  /// Constructs a HardwareButtonListenerPlatform.
  HardwareButtonListenerPlatform() : super(token: _token);

  static final Object _token = Object();

  static HardwareButtonListenerPlatform _instance =
      MethodChannelHardwareButtonListener();

  /// The default instance of [HardwareButtonListenerPlatform] to use.
  ///
  /// Defaults to [MethodChannelHardwareButtonListener].
  static HardwareButtonListenerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [HardwareButtonListenerPlatform] when
  /// they register themselves.
  static set instance(HardwareButtonListenerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }
}
