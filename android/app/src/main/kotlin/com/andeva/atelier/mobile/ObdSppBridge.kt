package com.andeva.atelier.mobile

import android.Manifest
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothSocket
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.IOException
import java.util.UUID
import java.util.concurrent.Executors

/**
 * Socket RFCOMM con el perfil serie (SPP) del ELM327 (docs/04-mobile-integration.md §4). Bluetooth clásico, no BLE.
 * Solo revisa los permisos; pedirlos es de la UI. Lo blocante va en otro hilo y todo resultado vuelve al principal,
 * que es el único donde Flutter acepta respuestas.
 */
class ObdSppBridge(private val context: Context, messenger: BinaryMessenger) :
    MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    private val methods = MethodChannel(messenger, METHOD_CHANNEL)
    private val events = EventChannel(messenger, EVENT_CHANNEL)
    private val main = Handler(Looper.getMainLooper())
    private val executor = Executors.newCachedThreadPool()

    @Volatile private var socket: BluetoothSocket? = null
    @Volatile private var sink: EventChannel.EventSink? = null

    init {
        methods.setMethodCallHandler(this)
        events.setStreamHandler(this)
    }

    /** Al morir el motor no queda nadie que use el canal: se suelta el socket. */
    fun dispose() {
        methods.setMethodCallHandler(null)
        events.setStreamHandler(null)
        close()
        executor.shutdown()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "bondedDevices" -> run(result) { bondedDevices() }
            "connect" -> run(result) { connect(call.argument<String>("address").orEmpty()) }
            "send" -> run(result) { send(call.argument<String>("command").orEmpty()) }
            "disconnect" -> run(result) { close() }
            else -> result.notImplemented()
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        sink = events
    }

    override fun onCancel(arguments: Any?) {
        sink = null
    }

    private fun run(result: MethodChannel.Result, block: () -> Any?) {
        executor.execute {
            try {
                val value = block()
                main.post { result.success(value) }
            } catch (e: BridgeException) {
                main.post { result.error(e.code, e.message, null) }
            } catch (_: SecurityException) {
                main.post { result.error(PERMISSION_DENIED, "Bluetooth permission denied", null) }
            } catch (e: IOException) {
                main.post { result.error(CONNECTION_LOST, e.message, null) }
            }
        }
    }

    private fun bluetoothAdapter(): BluetoothAdapter {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S &&
            context.checkSelfPermission(Manifest.permission.BLUETOOTH_CONNECT) != PackageManager.PERMISSION_GRANTED
        ) {
            throw BridgeException(PERMISSION_DENIED, "Bluetooth permission denied")
        }
        val adapter = context.getSystemService(BluetoothManager::class.java)?.adapter
        if (adapter == null || !adapter.isEnabled) throw BridgeException(BLUETOOTH_DISABLED, "Bluetooth is disabled")
        return adapter
    }

    /** Sin escaneo, así no hace falta `BLUETOOTH_SCAN`. */
    @Suppress("MissingPermission") // revisado en bluetoothAdapter()
    private fun bondedDevices(): List<Map<String, String>> =
        bluetoothAdapter().bondedDevices.orEmpty().map { device ->
            mapOf(
                "name" to device.name.orEmpty(),
                "address" to device.address,
                "type" to if (device.type == BluetoothDevice.DEVICE_TYPE_LE) "ble" else "classic"
            )
        }

    @Suppress("MissingPermission") // revisado en bluetoothAdapter()
    private fun connect(address: String) {
        val adapter = bluetoothAdapter()
        val device = try {
            adapter.getRemoteDevice(address)
        } catch (_: IllegalArgumentException) {
            throw BridgeException(INVALID_ADDRESS, "Invalid Bluetooth address")
        }
        close()
        val opened = try {
            device.createRfcommSocketToServiceRecord(SPP_UUID).also { it.connect() }
        } catch (e: IOException) {
            throw BridgeException(UNREACHABLE, e.message)
        }
        socket = opened
        Thread { read(opened) }.apply { isDaemon = true }.start()
    }

    /** `read` no se puede interrumpir: lo desbloquea `socket.close()`. Cerrar a propósito no es una caída. */
    private fun read(current: BluetoothSocket) {
        val buffer = ByteArray(BUFFER_SIZE)
        try {
            val input = current.inputStream
            while (true) {
                val count = input.read(buffer)
                if (count < 0) throw IOException("Socket closed")
                val chunk = String(buffer, 0, count, Charsets.US_ASCII)
                main.post { sink?.success(chunk) }
            }
        } catch (e: IOException) {
            if (socket === current) {
                main.post { sink?.error(CONNECTION_LOST, e.message, null) }
            }
        }
    }

    private fun send(command: String) {
        val output = socket?.outputStream ?: throw IOException("Socket closed")
        output.write(command.toByteArray(Charsets.US_ASCII))
        output.flush()
    }

    private fun close() {
        val current = socket
        socket = null
        try {
            current?.close()
        } catch (_: IOException) {
            // Ya se da por cerrado.
        }
    }

    private class BridgeException(val code: String, message: String?) : Exception(message)

    private companion object {
        const val METHOD_CHANNEL = "com.andeva.atelier.mobile/obd_spp"
        const val EVENT_CHANNEL = "com.andeva.atelier.mobile/obd_spp/incoming"
        val SPP_UUID: UUID = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB")
        const val BUFFER_SIZE = 512

        const val PERMISSION_DENIED = "PERMISSION_DENIED"
        const val BLUETOOTH_DISABLED = "BLUETOOTH_DISABLED"
        const val UNREACHABLE = "UNREACHABLE"
        const val INVALID_ADDRESS = "INVALID_ADDRESS"
        const val CONNECTION_LOST = "CONNECTION_LOST"
    }
}
