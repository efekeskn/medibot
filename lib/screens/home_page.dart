import 'package:flutter/material.dart';
import 'medicine_list_page.dart';
import 'manual_control_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("İlaç Takip Sistemi"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MedicineListPage(),
                ),
              );
            },
            child: const Text("İlaç Listesi ve Takvimi"),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManualControlPage(),
                ),
              );
            },
            child: const Text("Manuel Kontrol"),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/bluetooth-connect');
            },
            child: const Text("Bluetooth Ekranı"),
          ),
        ],
      ),
    );
  }
}
