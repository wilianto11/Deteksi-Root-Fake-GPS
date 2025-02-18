import 'package:detect_fake_location/detect_fake_location.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

import 'firebase_options.dart';
import 'map_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Deteksi Root & Lokasi Palsu',
      theme: ThemeData(
        primaryColor: Colors.blue.shade900,
        scaffoldBackgroundColor: Colors.white,
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue.shade800,
          titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String locationStatus = "Mencari lokasi...";
  String rootStatus = "Mendeteksi root...";
  String mockStatus = "Mendeteksi lokasi palsu...";

  @override
  void initState() {
    super.initState();
    _checkDeviceStatus();
  }

  Future<void> requestPermissions() async {
    await ph.Permission.location.request();
  }

  Future<bool> isDeviceRooted() async {
    final deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    return androidInfo.isPhysicalDevice &&
        (androidInfo.model.contains("root") || androidInfo.version.sdkInt < 29);
  }

  Future<LocationData?> getCurrentLocation() async {
    Location location = Location();
    if (!await location.serviceEnabled()) {
      if (!await location.requestService()) return null;
    }
    if (await location.requestPermission() != PermissionStatus.granted) {
      return null;
    }
    return await location.getLocation();
  }

  Future<void> _checkDeviceStatus() async {
    await requestPermissions();
    var location = await getCurrentLocation();
    bool isRooted = await isDeviceRooted();
    bool isFakeLocation = await DetectFakeLocation().detectFakeLocation();

    setState(() {
      locationStatus =
          location != null
              ? "Lokasi: Lat ${location.latitude}, Long ${location.longitude}"
              : "Tidak dapat mengambil lokasi";
      rootStatus =
          isRooted ? "⚠️ Perangkat di-root" : "✅ Perangkat tidak di-root";
      mockStatus =
          isFakeLocation
              ? "❌ Lokasi palsu terdeteksi"
              : "✅ Tidak ada lokasi palsu";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Deteksi Root & Lokasi Palsu'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildInfoCard("📍 Lokasi", locationStatus, Colors.blueAccent),
            _buildInfoCard("🔍 Root Status", rootStatus, Colors.orangeAccent),
            _buildInfoCard("🛑 Fake GPS", mockStatus, Colors.redAccent),
            SizedBox(height: 20),
            _buildButton("🔄 Cek Ulang", Colors.blue, _checkDeviceStatus),
            SizedBox(height: 10),
            _buildButton("🗺 Lihat Peta", Colors.green, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MapScreen()),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String content, Color color) {
    return Card(
      color: color.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(Icons.info_outline, color: color, size: 30),
        title: Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(content, style: TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _buildButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(text, style: TextStyle(fontSize: 18)),
    );
  }
}
