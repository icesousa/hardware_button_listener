import 'package:flutter/services.dart';

enum HardwareButtonPressType {
  keyDown,
  keyUp;

  /// Parse the enum from its string representation (e.g. "keyDown").
  factory HardwareButtonPressType.fromString(String? value) {
    if (value == null) {
      throw ArgumentError.notNull('value');
    }
    return HardwareButtonPressType.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => throw ArgumentError('Unknown HardwareButtonPressType: $value'),
    );
  }

  /// Serialize to its string name (e.g. "keyDown").
  String toValue() => toString().split('.').last;
}

class HardwareButton {
  final String? buttonName;
  final int? buttonKey;
  final HardwareButtonPressType? pressType;

  HardwareButton({
    this.buttonName,
    this.buttonKey,
    this.pressType,
  });

  /// Now encodes the pressType as a String
  List<dynamic> encode() {
    return [
      buttonName,
      buttonKey,
      pressType?.toValue(),
    ];
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
        pressType: decoded[2] != null ? HardwareButtonPressType.fromString(decoded[2] as String) : null,
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
