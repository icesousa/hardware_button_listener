import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hardware_button_listener/hardware_button_listener.dart';
import 'package:hardware_button_listener/hardware_button_listener_platform_interface.dart';
import 'package:hardware_button_listener/hardware_button_listener_method_channel.dart';
import 'package:hardware_button_listener/models/hardware_button.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockHardwareButtonListenerPlatform
    with MockPlatformInterfaceMixin
    implements HardwareButtonListenerPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final HardwareButtonListenerPlatform initialPlatform = HardwareButtonListenerPlatform.instance;

  test('$MethodChannelHardwareButtonListener is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelHardwareButtonListener>());
  });

  group('HardwareButton.decode', () {
    test('should correctly decode a valid HardwareButton object', () {
      const originalButton = HardwareButton.volumeUp;
      final decodedButton = HardwareButton.decode(originalButton.toString());
      expect(decodedButton, originalButton);
    });

    test('should throw an exception when given an invalid object', () {
      expect(() => HardwareButton.decode('invalid_button'), throwsException);
    });
  });

  group('EventChannel', () {
    const MethodChannel channel = MethodChannel('hardware_button_listener');
    const EventChannel eventChannel = EventChannel('hardware_button_listener_events');
    HardwareButtonListener? listener;

    setUp(() {
      listener = HardwareButtonListener();
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        return '42';
      });
    });

    tearDown(() {
      listener?.dispose();
      channel.setMockMethodCallHandler(null);
    });

    testWidgets('receives and decodes a single HardwareButton event', (WidgetTester tester) async {
      await tester.runAsync(() async {
        HardwareButton? receivedButton;
        listener?.listen((button) {
          receivedButton = button;
        });

        // Simulate an event from the platform side
        const button = HardwareButton.volumeDown;
        final ByteData byteData = const StandardMethodCodec().encodeSuccessEnvelope(button.toString());
        await ServicesBinding.instance.defaultBinaryMessenger.handlePlatformMessage(
          eventChannel.name,
          byteData,
          (ByteData? reply) {},
        );

        expect(receivedButton, button);
      });
    });

    testWidgets('receives and decodes multiple HardwareButton events', (WidgetTester tester) async {
      await tester.runAsync(() async {
        final List<HardwareButton> receivedButtons = [];
        listener?.listen((button) {
          receivedButtons.add(button);
        });

        // Simulate multiple events
        const button1 = HardwareButton.volumeUp;
        const button2 = HardwareButton.power;
        final ByteData byteData1 = const StandardMethodCodec().encodeSuccessEnvelope(button1.toString());
        final ByteData byteData2 = const StandardMethodCodec().encodeSuccessEnvelope(button2.toString());

        await ServicesBinding.instance.defaultBinaryMessenger.handlePlatformMessage(
          eventChannel.name,
          byteData1,
          (ByteData? reply) {},
        );
        await ServicesBinding.instance.defaultBinaryMessenger.handlePlatformMessage(
          eventChannel.name,
          byteData2,
          (ByteData? reply) {},
        );

        expect(receivedButtons, [button1, button2]);
      });
    });

    testWidgets('handles errors from the EventChannel', (WidgetTester tester) async {
      await tester.runAsync(() async {
        dynamic? receivedError;
        listener?.listen(
          (button) {},
          onError: (error) {
            receivedError = error;
          },
        );

        // Simulate an error
        final ByteData byteData = const StandardMethodCodec().encodeErrorEnvelope(
          code: 'TEST_ERROR',
          message: 'This is a test error.',
        );
        await ServicesBinding.instance.defaultBinaryMessenger.handlePlatformMessage(
          eventChannel.name,
          byteData,
          (ByteData? reply) {},
        );

        expect(receivedError, isA<PlatformException>());
        expect((receivedError as PlatformException).code, 'TEST_ERROR');
      });
    });
  });

  group('Stream behavior', () {
    const EventChannel eventChannel = EventChannel('hardware_button_listener_events');
    HardwareButtonListener? listenerInstance;

    setUp(() {
      // No need to mock the MethodChannel here as we are testing stream behavior
      listenerInstance = HardwareButtonListener();
    });

    tearDown(() {
      listenerInstance?.dispose();
    });

    testWidgets('multiple listeners receive events and cancellation works', (WidgetTester tester) async {
      await tester.runAsync(() async {
        HardwareButton? receivedButton1;
        HardwareButton? receivedButton2;

        final sub1 = listenerInstance?.listen((event) {
          receivedButton1 = event;
        });
        final sub2 = listenerInstance?.listen((event) {
          receivedButton2 = event;
        });

        // Emit first event
        const buttonEvent1 = HardwareButton.volumeUp;
        ByteData byteData = const StandardMethodCodec().encodeSuccessEnvelope(buttonEvent1.toString());
        await ServicesBinding.instance.defaultBinaryMessenger.handlePlatformMessage(
          eventChannel.name,
          byteData,
          (ByteData? reply) {},
        );
        expect(receivedButton1, buttonEvent1);
        expect(receivedButton2, buttonEvent1);

        // Reset received buttons
        receivedButton1 = null;
        receivedButton2 = null;

        // Cancel first subscription
        await sub1?.cancel();

        // Emit second event
        const buttonEvent2 = HardwareButton.volumeDown;
        byteData = const StandardMethodCodec().encodeSuccessEnvelope(buttonEvent2.toString());
        await ServicesBinding.instance.defaultBinaryMessenger.handlePlatformMessage(
          eventChannel.name,
          byteData,
          (ByteData? reply) {},
        );
        expect(receivedButton1, null); // sub1 is cancelled
        expect(receivedButton2, buttonEvent2);

        // Reset received buttons
        receivedButton1 = null;
        receivedButton2 = null;

        // Cancel second subscription
        await sub2?.cancel();

        // Emit third event
        const buttonEvent3 = HardwareButton.power;
        byteData = const StandardMethodCodec().encodeSuccessEnvelope(buttonEvent3.toString());
        await ServicesBinding.instance.defaultBinaryMessenger.handlePlatformMessage(
          eventChannel.name,
          byteData,
          (ByteData? reply) {},
        );
        expect(receivedButton1, null); // sub1 is cancelled
        expect(receivedButton2, null); // sub2 is cancelled
      });
    });
  });
}
