import 'package:flutter/material.dart';
import 'screens/home_page.dart';
import 'screens/medicine_list_page.dart';
import 'screens/medicine_add_page.dart';  
import 'screens/manual_control_page.dart';
import 'screens/bluetooth_device_connect_page.dart'; 


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'İlaç Takip ve Dağıtım Sistemi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Başlangıç ekranı
      home: HomePage(),
      routes: {
        '/home': (context) => HomePage(),
        '/medicine-list': (context) => MedicineListPage(),
        '/medicine-add': (context) => MedicineAddPage(),
        '/manual-control': (context) => ManualControlPage(),
        '/bluetooth-connect': (context) => BluetoothDeviceConnectPage(), 
      },
    );
  }
}
