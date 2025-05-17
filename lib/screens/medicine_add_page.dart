import 'package:flutter/material.dart';
import '../models/medicine.dart';
import '../services/medicine_storage_service.dart';

class MedicineAddPage extends StatefulWidget {
  const MedicineAddPage({super.key});

  @override
  State<MedicineAddPage> createState() => _MedicineAddPageState();
}

class _MedicineAddPageState extends State<MedicineAddPage> {
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  TimeOfDay? _selectedTime;
  final List<String> _selectedDays = [];
  final MedicineStorageService _storageService = MedicineStorageService();

  int? _selectedKapNo; // Kap No seçimi için değişken

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("İlaç Ekle")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView( // Kayan ekran için
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'İlaç Adı'),
              ),
              TextField(
                controller: _dosageController,
                decoration: const InputDecoration(labelText: 'Dozaj'),
              ),
              ListTile(
                title: Text(_selectedTime == null
                    ? "Saat Seçin"
                    : "${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}"),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  TimeOfDay? time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (time != null) {
                    setState(() {
                      _selectedTime = time;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              Text("Gün Seçin:"),
              CheckboxListTile(
                title: const Text("Pazartesi"),
                value: _selectedDays.contains('Pazartesi'),
                onChanged: (bool? value) {
                  setState(() {
                    if (value!) {
                      _selectedDays.add('Pazartesi');
                    } else {
                      _selectedDays.remove('Pazartesi');
                    }
                  });
                },
              ),
              const SizedBox(height: 12),
              Text("Kap Seçin:"),
              DropdownButton<int>(
                hint: const Text("Kap Numarası Seç"),
                value: _selectedKapNo,
                isExpanded: true,
                items: List.generate(6, (index) => index + 1)
                    .map((kapNo) => DropdownMenuItem(
                          value: kapNo,
                          child: Text('Kap $kapNo'),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedKapNo = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_nameController.text.isNotEmpty &&
                      _dosageController.text.isNotEmpty &&
                      _selectedTime != null &&
                      _selectedDays.isNotEmpty &&
                      _selectedKapNo != null) {
                    final medicine = Medicine(
                      name: _nameController.text,
                      dosage: _dosageController.text,
                      times: [_selectedTime!],
                      repeatDays: _selectedDays,
                      kapNo: _selectedKapNo!, // Kap numarasını verdik
                    );

                    await _storageService.addMedicine(medicine);

                    if (!mounted) return; // <-- EKLENDİ!!

                    // Navigator.pop(context) işlemi, mounted kontrolü sağlandıktan sonra
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        Navigator.pop(context);
                      }
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Lütfen tüm alanları doldurun!')),
                    );
                  }
                },
                child: const Text('Kaydet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
