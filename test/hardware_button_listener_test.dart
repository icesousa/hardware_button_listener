import 'package:flutter_test/flutter_test.dart';
import 'package:hardware_button_listener/hardware_button_listener.dart';
import 'package:hardware_button_listener/hardware_button_listener_platform_interface.dart';
import 'package:hardware_button_listener/hardware_button_listener_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockHardwareButtonListenerPlatform
    with MockPlatformInterfaceMixin
    implements HardwareButtonListenerPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final HardwareButtonListenerPlatform initialPlatform = HardwareButtonListenerPlatform.instance;

  test('$MethodChannelHardwareButtonListener is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelHardwareButtonListener>());
  });


}
