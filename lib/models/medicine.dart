import 'package:flutter/material.dart';

class Medicine {
  String name;               // İlaç ismi
  String dosage;             // Dozaj bilgisi
  List<TimeOfDay> times;      // Alınacak saatler (birden fazla)
  List<String> repeatDays;    // Tekrar eden günler
  int kapNo;                  // İlacın konulduğu kap numarası

  Medicine({
    required this.name,
    required this.dosage,
    required this.times,
    required this.repeatDays,
    required this.kapNo,
  });

  // JSON'a çevir (veri kaydetmek için kullanılır)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dosage': dosage,
      'times': times.map((t) => {'hour': t.hour, 'minute': t.minute}).toList(),
      'repeatDays': repeatDays,
      'kapNo': kapNo,   // 🔥 EKLENDİ
    };
  }

  // JSON'dan nesne oluştur (veri yüklemek için kullanılır)
  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      name: json['name'],
      dosage: json['dosage'],
      times: (json['times'] as List)
          .map((t) => TimeOfDay(hour: t['hour'], minute: t['minute']))
          .toList(),
      repeatDays: List<String>.from(json['repeatDays']),
      kapNo: json['kapNo'],   // 🔥 EKLENDİ
    );
  }

  @override
  String toString() {
    // Saatleri formatlıyoruz ve aralarına virgül koyuyoruz
    final String formattedTimes = times
        .map((t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}')
        .join(', ');
    return '$name ($dosage) - $formattedTimes (Kap: $kapNo)';
  }
}
