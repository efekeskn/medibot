import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothService {
  static BluetoothConnection? _connection;

  static bool get isConnected => _connection != null && _connection!.isConnected;

  static Future<void> connectToDevice(BluetoothDevice device, Function(String) onReceive) async {
    if (isConnected) return;

    try {
      _connection = await BluetoothConnection.toAddress(device.address).timeout(Duration(seconds: 30));
      _connection!.input!.listen((Uint8List data) {
        final received = utf8.decode(data);
        onReceive(received);
      }).onDone(() {
        _connection = null;
        reconnectToDevice(device, onReceive);
      });
    } catch (e) {
      print("Bağlantı hatası: $e");
      reconnectToDevice(device, onReceive);
    }
  }

  static Future<void> reconnectToDevice(BluetoothDevice device, Function(String) onReceive) async {
    await Future.delayed(Duration(seconds: 5));
    await connectToDevice(device, onReceive);
  }

  static void send(String message) {
    if (isConnected) {
      _connection!.output.add(utf8.encode("$message\n"));
      _connection!.output.allSent;
    }
  }

  static void disconnect() {
    _connection?.dispose();
    _connection = null;
  }
}

class BluetoothDeviceConnectPage extends StatefulWidget {
  const BluetoothDeviceConnectPage({super.key});

  @override
  _BluetoothDeviceConnectPageState createState() => _BluetoothDeviceConnectPageState();
}

class _BluetoothDeviceConnectPageState extends State<BluetoothDeviceConnectPage> {
  BluetoothDevice? _selectedDevice;
  String _statusMessage = "Cihaz seçilmedi";
  final TextEditingController _dataController = TextEditingController();
  final StringBuffer _dataBuffer = StringBuffer();
  String _receivedData = "";
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _updateTimer = Timer.periodic(Duration(milliseconds: 500), (_) {
      if (mounted && _dataBuffer.isNotEmpty) {
        setState(() {
          _receivedData += _dataBuffer.toString();
          _dataBuffer.clear();
        });
      }
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    _dataController.dispose();
    // Not: disconnect() burada çağrılmıyor
    super.dispose();
  }

  Future<void> _connectToSelectedDevice() async {
    if (_selectedDevice == null) return;

    try {
      await BluetoothService.connectToDevice(_selectedDevice!, (data) {
        _dataBuffer.write(data);
      });
      setState(() {
        _statusMessage = "Bağlandı: ${_selectedDevice!.name}";
      });
    } catch (e) {
      setState(() {
        _statusMessage = "Bağlantı hatası: $e";
      });
    }
  }

  Future<void> _selectDevice() async {
    List<BluetoothDevice> bondedDevices =
        await FlutterBluetoothSerial.instance.getBondedDevices();

    final BluetoothDevice? chosenDevice = await showDialog<BluetoothDevice>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Bluetooth Cihaz Seç"),
        content: SizedBox(
          height: 300,
          width: double.maxFinite,
          child: ListView(
            children: bondedDevices.map((device) {
              return ListTile(
                title: Text(device.name ?? "Bilinmeyen"),
                subtitle: Text(device.address),
                onTap: () => Navigator.pop(context, device),
              );
            }).toList(),
          ),
        ),
      ),
    );

    if (chosenDevice != null) {
      setState(() {
        _selectedDevice = chosenDevice;
        _statusMessage = "Seçildi: ${chosenDevice.name}";
      });
      await _connectToSelectedDevice();
    }
  }

  void _sendData() {
    String message = _dataController.text.trim();
    if (message.isNotEmpty && BluetoothService.isConnected) {
      BluetoothService.send(message);
      setState(() {
        _statusMessage = "Veri gönderildi: $message";
        _dataController.clear();
      });
    }
  }

  void _disconnect() {
    BluetoothService.disconnect();
    setState(() {
      _statusMessage = "Bağlantı kesildi.";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bluetooth Bağlantı Ekranı"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: _selectDevice,
              child: const Text("Bluetooth Cihaz Seç"),
            ),
            const SizedBox(height: 16),
            Text(_statusMessage, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            if (BluetoothService.isConnected) ...[
              TextField(
                controller: _dataController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Gönderilecek Veri",
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _sendData,
                child: const Text("Veriyi Gönder"),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _disconnect,
                child: const Text("Bağlantıyı Kes"),
              ),
              const SizedBox(height: 20),
              const Text("Gelen Veriler:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                height: 200,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(_receivedData),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}