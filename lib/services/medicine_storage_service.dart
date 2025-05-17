import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/medicine.dart';

class MedicineStorageService {
  static const String _storageKey = 'stored_medicines';

  /// Kaydedilmiş ilaç listesini SharedPreferences'tan getirir.
  /// Eğer veri yoksa boş bir liste döner.
  Future<List<Medicine>> getMedicines() async {
    final prefs = await SharedPreferences.getInstance();
    final String? medicinesJson = prefs.getString(_storageKey);
    if (medicinesJson == null) {
      return [];
    }
    final List<dynamic> jsonList = jsonDecode(medicinesJson);
    List<Medicine> medicines =
        jsonList.map((jsonItem) => Medicine.fromJson(jsonItem)).toList();
    return medicines;
  }

  /// Yeni bir ilaç ekler ve güncellenmiş ilaç listesini kaydeder.
  Future<void> addMedicine(Medicine medicine) async {
    final medicines = await getMedicines();
    medicines.add(medicine);
    await _saveMedicines(medicines);
  }
  Future<void> updateMedicineAt(int index, Medicine updated) async {
  final medicines = await getMedicines();
  if (index < 0 || index >= medicines.length) {
    throw Exception("Geçersiz indeks: $index");
  }
  medicines[index] = updated;
  await _saveMedicines(medicines);
}


  /// Belirtilen indeksteki ilacı listeden siler ve güncellenmiş listeyi kaydeder.
  Future<void> removeMedicineAt(int index) async {
    final medicines = await getMedicines();
    if (index < 0 || index >= medicines.length) {
      throw Exception('Geçersiz indeks: $index');
    }
    medicines.removeAt(index);
    await _saveMedicines(medicines);
  }

  /// Güncel ilaç listesini JSON formatında kaydeder.
  Future<void> _saveMedicines(List<Medicine> medicines) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString =
        jsonEncode(medicines.map((m) => m.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }
}
