import 'package:flutter/material.dart';
// Eğer bluetooth ile komut göndereceksen bu servisi import edebilirsin
// import '../services/bluetooth_service.dart';

class ManualControlPage extends StatefulWidget {
  const ManualControlPage({super.key});

  @override
  State<ManualControlPage> createState() => _ManualControlPageState();
}

class _ManualControlPageState extends State<ManualControlPage> {
  String feedbackMessage = '';

  void markAsTaken() {
    setState(() {
      feedbackMessage = '✅ İlacınız alındı olarak işaretlendi.';
    });

    // Bluetooth üzerinden Arduino’ya komut gönder (örnek)
    // BluetoothService.sendCommand("STOP");
  }

  void snoozeAlarm() {
    setState(() {
      feedbackMessage = '⏰ Alarm 5 dakika ertelendi.';
    });

    // Arduino’ya ertele komutu gönder (örnek)
    // BluetoothService.sendCommand("SNOOZE");
  }

  void resetFeedback() {
    setState(() {
      feedbackMessage = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Manuel Kontrol")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: markAsTaken,
              icon: Icon(Icons.check_circle),
              label: Text("İlacımı Aldım"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: Size.fromHeight(50),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: snoozeAlarm,
              icon: Icon(Icons.snooze),
              label: Text("Alarmı Ertele (5dk)"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: Size.fromHeight(50),
              ),
            ),
            SizedBox(height: 32),
            if (feedbackMessage.isNotEmpty)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.teal.shade50,
                child: ListTile(
                  title: Text(feedbackMessage),
                  trailing: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: resetFeedback,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
