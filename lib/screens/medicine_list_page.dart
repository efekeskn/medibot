import 'package:flutter/material.dart';
import '../models/medicine.dart';
import '../services/medicine_storage_service.dart';

class MedicineListPage extends StatefulWidget {
  const MedicineListPage({super.key});

  @override
  State<MedicineListPage> createState() => _MedicineListPageState();
}

class _MedicineListPageState extends State<MedicineListPage> {
  List<Medicine> medicineList = [];
  final MedicineStorageService _storageService = MedicineStorageService();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dosageController = TextEditingController();
  List<TimeOfDay> selectedTimes = [];
  List<String> selectedDays = [];
  int? selectedKapNo;

  int? _editingIndex; // ✨ Düzenlenmekte olan ilacın indeksi

  final List<String> allDays = [
    "Pazartesi", "Salı", "Çarşamba", "Perşembe", "Cuma", "Cumartesi", "Pazar"
  ];

  @override
  void initState() {
    super.initState();
    _loadMedicines();
  }

  Future<void> _loadMedicines() async {
    final loaded = await _storageService.getMedicines();
    setState(() => medicineList = loaded);
  }

  void deleteMedicine(int index) async {
    await _storageService.removeMedicineAt(index);
    _loadMedicines();
  }

  void pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        selectedTimes.add(picked);
      });
    }
  }

  void toggleDay(String day) {
    setState(() {
      if (selectedDays.contains(day)) {
        selectedDays.remove(day);
      } else {
        selectedDays.add(day);
      }
    });
  }

  void saveMedicine() async {
    final name = nameController.text.trim();
    final dosage = dosageController.text.trim();

    if (name.isEmpty || dosage.isEmpty || selectedTimes.isEmpty || selectedDays.isEmpty || selectedKapNo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen tüm alanları doldurun")),
      );
      return;
    }

    // Kap kontrolü (sadece yeni eklemede kontrol edilir)
    if (_editingIndex == null) {
      bool isKapUsed = medicineList.any((med) => med.kapNo == selectedKapNo);
      if (isKapUsed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Bu kap numarası zaten kullanılıyor. Lütfen farklı bir kap numarası seçin.")),
        );
        return;
      }
    }

    final newMedicine = Medicine(
      name: name,
      dosage: dosage,
      times: selectedTimes,
      repeatDays: selectedDays,
      kapNo: selectedKapNo!,
    );

    if (_editingIndex != null) {
      await _storageService.updateMedicineAt(_editingIndex!, newMedicine);
      _editingIndex = null;
    } else {
      await _storageService.addMedicine(newMedicine);
    }

    _loadMedicines();
    nameController.clear();
    dosageController.clear();
    setState(() {
      selectedTimes.clear();
      selectedDays.clear();
      selectedKapNo = null;
    });
  }

  void editMedicine(int index) {
    final med = medicineList[index];
    setState(() {
      nameController.text = med.name;
      dosageController.text = med.dosage;
      selectedTimes = List<TimeOfDay>.from(med.times);
      selectedDays = List<String>.from(med.repeatDays);
      selectedKapNo = med.kapNo;
      _editingIndex = index;
    });
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("İlaç Listesi ve Takvimi")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'İlaç Adı',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: dosageController,
              decoration: const InputDecoration(
                labelText: 'Dozaj (örn: 500mg, 1 kapsül)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text("Saatler:", style: TextStyle(fontSize: 16)),
            Column(
              children: selectedTimes.map((time) {
                return Row(
                  children: [
                    Text(
                      time.format(context),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          selectedTimes.remove(time);
                        });
                      },
                    ),
                  ],
                );
              }).toList(),
            ),
            ElevatedButton(
              onPressed: pickTime,
              child: const Text("Saat Seç"),
            ),
            const SizedBox(height: 16),
            const Text("Tekrar Günleri:", style: TextStyle(fontSize: 16)),
            Wrap(
              spacing: 8,
              children: allDays.map((day) {
                final isSelected = selectedDays.contains(day);
                return FilterChip(
                  label: Text(day),
                  selected: isSelected,
                  onSelected: (_) => toggleDay(day),
                  selectedColor: Colors.teal,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text("Kap Seçin:", style: TextStyle(fontSize: 16)),
            DropdownButton<int>(
              value: selectedKapNo,
              hint: const Text("Kap Numarası Seç"),
              isExpanded: true,
              items: List.generate(3, (i) => i + 1)
                  .map((kap) => DropdownMenuItem(
                        value: kap,
                        child: Text('Kap $kap'),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedKapNo = value;
                });
              },
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: Text(_editingIndex != null ? "Güncelle" : "Kaydet"),
                onPressed: saveMedicine,
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              ),
            ),
            const SizedBox(height: 32),
            medicineList.isEmpty
                ? const Center(child: Text("Henüz ilaç eklenmemiş."))
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: medicineList.length,
                    itemBuilder: (ctx, i) {
                      final med = medicineList[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.medical_services_outlined, color: Colors.teal),
                          title: Text('${med.name} - ${med.dosage}'),
                          subtitle: Text(
                            'Saatler: ${med.times.map(_formatTime).join(', ')}\n'
                            'Günler: ${med.repeatDays.join(', ')}\n'
                            'Kap: ${med.kapNo}',
                          ),
                          isThreeLine: true,
                          trailing: Wrap(
                            spacing: 12,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => editMedicine(i),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => deleteMedicine(i),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
