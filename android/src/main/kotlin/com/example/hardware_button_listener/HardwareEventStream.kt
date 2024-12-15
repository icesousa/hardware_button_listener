package com.example.hardware_button_listener

import android.nfc.FormatException
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.common.StandardMethodCodec
import java.io.ByteArrayOutputStream
import java.nio.ByteBuffer

class FlutterError(
    val code: String,
    override val message: String? = null,
    val details: Any? = null
) : Throwable()

data class HardwareButton(
    val buttonName: String? = null,
    val buttonKey: Long? = null
) {
    companion object {
        fun fromList(list: List<Any?>): HardwareButton {
            val buttonName = list[0] as? String
            val buttonKey = list[1] as? Long
            return HardwareButton(buttonName, buttonKey)
        }
    }

    fun toList(): List<Any?> {
        return listOf(
            buttonName,
            buttonKey
        )
    }
}

private class HardwareButtonStreamCodec : StandardMessageCodec() {
    override fun readValueOfType(type: Byte, buffer: ByteBuffer): Any? {
        return when (type) {
            129.toByte() -> {
                val list = readValue(buffer) as? List<*>
                if (list != null && list.size >= 2) {
                    HardwareButton(
                        buttonName = list[0] as? String,
                        buttonKey = (list[1] as? Number)?.toLong()
                    )
                } else {
                    throw FormatException("Invalid HardwareButton format")
                }
            }
            else -> super.readValueOfType(type, buffer)
        }
    }


    override fun writeValue(stream: ByteArrayOutputStream, value: Any?) {
        when (value) {
            is HardwareButton -> {
                stream.write(129) // Custom type marker
                writeValue(stream, listOf(value.buttonName, value.buttonKey))
            }
            else -> super.writeValue(stream, value)
        }
    }
}

val HardwareButtonStreamMethodCodec = StandardMethodCodec(HardwareButtonStreamCodec())

private class HardwareStreamHandler<T>(
    val wrapper: HardwareButtonEventChannelWrapper<T>
) : EventChannel.StreamHandler {

    var hardwareButtonSink: HardwareButtonEventSink<T>? = null

    override fun onListen(arguments: Any?, sink: EventChannel.EventSink) {
        hardwareButtonSink = HardwareButtonEventSink(sink)
        wrapper.onListen(arguments, hardwareButtonSink!!)
    }

    override fun onCancel(arguments: Any?) {
        hardwareButtonSink = null
        wrapper.onCancel(arguments)
    }
}

interface HardwareButtonEventChannelWrapper<T> {
    fun onListen(arguments: Any?, sink: HardwareButtonEventSink<T>)
    fun onCancel(arguments: Any?)
}

class HardwareButtonEventSink<T>(private val sink: EventChannel.EventSink) {
    fun success(value: List<Any?>) {
        sink.success(value)
    }

    fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
        sink.error(errorCode, errorMessage, errorDetails)
    }

    fun endOfStream() {
        sink.endOfStream()
    }
}

abstract class StreamEventsStreamHandler : HardwareButtonEventChannelWrapper<HardwareButton> {
    companion object {
        fun register(
            messenger: BinaryMessenger,
            streamHandler: StreamEventsStreamHandler,
            instanceName: String = ""
        ) {
            var channelName = "hardware_button_listener_event"
            if (instanceName.isNotEmpty()) {
                channelName += ".$instanceName"
            }
            val internalStreamHandler = HardwareStreamHandler(streamHandler)
            EventChannel(messenger, channelName, HardwareButtonStreamMethodCodec)
                .setStreamHandler(internalStreamHandler)
        }
    }
}
