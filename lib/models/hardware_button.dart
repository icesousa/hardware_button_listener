import 'package:flutter/services.dart';

class HardwareButton {
  final String? buttonName;
  final int? buttonKey;
  final String? pressType;

  HardwareButton({
    this.buttonName,
    this.buttonKey,
    this.pressType,
  });

  List<dynamic> encode() {
    return [buttonName, buttonKey, pressType];
  }

  static HardwareButton decode(HardwareButton data) {
    return HardwareButton(
      buttonName: data.buttonName,
      buttonKey: data.buttonKey,
      pressType: data.pressType,
    );
  }

  @override
  String toString() {
    return 'HardwareButton(buttonName: $buttonName, buttonKey: $buttonKey, pressType: $pressType)';
  }
}

class HardwareButtonMethodCodec extends StandardMethodCodec {
  const HardwareButtonMethodCodec();

  @override
  dynamic decodeEnvelope(ByteData envelope) {
    final decoded = super.decodeEnvelope(envelope);

    if (decoded is List<dynamic> && decoded.length == 3) {
      return HardwareButton(
        buttonName: decoded[0] as String?,
        buttonKey: decoded[1] as int?,
        pressType: decoded[2] as String?,
      );
    }

    return decoded;
  }

  @override
  ByteData encodeSuccessEnvelope(Object? result) {
    if (result is HardwareButton) {
      result = result.encode();
    }
    return super.encodeSuccessEnvelope(result);
  }
}

Stream<HardwareButton> streamEvents({String instanceName = ''}) {
  if (instanceName.isNotEmpty) {
    instanceName = '.$instanceName';
  }
  const EventChannel streamEventsChannel = EventChannel(
    'hardware_button_listener_event',
    HardwareButtonMethodCodec(),
  );
  return streamEventsChannel.receiveBroadcastStream().map((dynamic event) {
    if (event is HardwareButton) {
      return event;
    }
    throw Exception('Invalid event type: $event');
  });
}
