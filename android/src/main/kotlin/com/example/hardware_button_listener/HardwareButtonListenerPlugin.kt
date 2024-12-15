package com.example.hardware_button_listener

import android.app.Activity
import android.os.Build
import android.util.Log
import android.view.KeyEvent
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** HardwareButtonListenerPlugin */
class HardwareButtonListenerPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
  private lateinit var channel: MethodChannel
  private var eventSink: HardwareButtonEventSink<HardwareButton>? = null
  private  var  activity: Activity? = null


  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {


    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "hardware_button_listener")
    channel.setMethodCallHandler(this)
    val binaryMessenger = flutterPluginBinding.binaryMessenger
    StreamEventsStreamHandler.register(
      binaryMessenger,
      object : StreamEventsStreamHandler() {
        override fun onListen(arguments: Any?, sink: HardwareButtonEventSink<HardwareButton>) {
          

          eventSink = sink
        }
        override fun onCancel(p0: Any?) {
          eventSink = null
        }

      }
    )



  }

  val keyCodeNames = mapOf(
    KeyEvent.KEYCODE_VOLUME_UP to "VOLUME_UP",
    KeyEvent.KEYCODE_VOLUME_DOWN to "VOLUME_DOWN",
    KeyEvent.KEYCODE_POWER to "POWER",
    KeyEvent.KEYCODE_CAMERA to "CAMERA",
    KeyEvent.KEYCODE_HOME to "HOME",
    KeyEvent.KEYCODE_BACK to "BACK",
    KeyEvent.KEYCODE_MENU to "MENU",
    KeyEvent.KEYCODE_ENTER to "ENTER",
    KeyEvent.KEYCODE_SPACE to "SPACE",
    KeyEvent.KEYCODE_ESCAPE to "ESCAPE",
    KeyEvent.KEYCODE_VOLUME_MUTE to "VOLUME_MUTE",
    KeyEvent.KEYCODE_MUTE to "MUTE",
    KeyEvent.KEYCODE_CALL to "CALL",
    KeyEvent.KEYCODE_ENDCALL to "END_CALL",
    KeyEvent.KEYCODE_HEADSETHOOK to "HEADSET_HOOK",
    KeyEvent.KEYCODE_MEDIA_PLAY_PAUSE to "MEDIA_PLAY_PAUSE",
    KeyEvent.KEYCODE_MEDIA_STOP to "MEDIA_STOP",
    KeyEvent.KEYCODE_MEDIA_NEXT to "MEDIA_NEXT",
    KeyEvent.KEYCODE_MEDIA_PREVIOUS to "MEDIA_PREVIOUS",
    KeyEvent.KEYCODE_MEDIA_FAST_FORWARD to "MEDIA_FAST_FORWARD",
    KeyEvent.KEYCODE_MEDIA_REWIND to "MEDIA_REWIND"
    // Add more as needed if you encounter them
  )

  private fun getButtonName(keyCode: Int): String {
    return keyCodeNames[keyCode] ?: "UNKNOWN_$keyCode"
  }
  fun handleKeyDown(keyCode: Int): Boolean {

    val buttonName = getButtonName(keyCode)


    val buttonEvent = HardwareButton(
      buttonName = buttonName,
      buttonKey = keyCode.toLong()
    )

    eventSink?.success(buttonEvent.toList()) ?: Log.d("TAG", "EventSink is null!")

    // Return false to allow the system to process the event or true to consume it
    return false
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    if (call.method == "getPlatformVersion") {
      result.success("Android ${Build.VERSION.RELEASE}")
    } else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)

  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity

    // Intercepta eventos de teclado
    val originalCallback = activity?.window?.callback
    activity?.window?.callback = object : android.view.Window.Callback by originalCallback!! {
      override fun dispatchKeyEvent(event: KeyEvent?): Boolean {
        if (event?.action == KeyEvent.ACTION_DOWN) {
          val keyCode = event.keyCode
          // Redireciona para o método handleKeyDown
          if (handleKeyDown(keyCode)) {
            return true // Consome o evento
          }
        }
        return originalCallback!!.dispatchKeyEvent(event) // Processa o evento normalmente
      }
    }
  }



  override fun onDetachedFromActivityForConfigChanges() {
   activity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivity() {
    activity = null
      }


}
