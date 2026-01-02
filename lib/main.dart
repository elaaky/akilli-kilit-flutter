import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Akıllı Kilit',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1E1E2C),
        primaryColor: const Color(0xFF6C63FF),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  BluetoothConnection? connection;
  bool isConnected = false;
  List<BluetoothDevice> _devicesList = [];
  BluetoothDevice? _connectedDevice;

  // DÜZELTME 1: Bu değişken artık kullanılıyor (Yükleniyor simgesi için)
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    await _requestPermissions();
    _getPairedDevices();
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();
  }

  Future<void> _getPairedDevices() async {
    setState(() => _isLoading = true);
    try {
      List<BluetoothDevice> devices =
          await FlutterBluetoothSerial.instance.getBondedDevices();
      setState(() {
        _devicesList = devices;
        _isLoading = false;
      });
    } catch (e) {
      // DÜZELTME 2: print yerine debugPrint
      debugPrint("Hata: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _connect(BluetoothDevice device) async {
    setState(() => _isLoading = true);

    if (connection != null) {
      await connection!.close();
      connection = null;
    }

    try {
      connection = await BluetoothConnection.toAddress(device.address);

      setState(() {
        isConnected = true;
        _connectedDevice = device;
        _isLoading = false;
      });

      _showSnack("BAĞLANDI: ${device.name}");

      connection!.input!.listen(null).onDone(() {
        if (mounted) {
          setState(() {
            isConnected = false;
            _connectedDevice = null;
          });
          _showSnack("Bağlantı Koptu");
        }
      });
    } catch (e) {
      setState(() {
        isConnected = false;
        _isLoading = false;
      });
      _showSnack("HATA: $e");
      // DÜZELTME 2: print yerine debugPrint
      debugPrint("Bağlantı Hatası: $e");
    }
  }

  void _disconnect() {
    connection?.close();
    setState(() {
      isConnected = false;
      _connectedDevice = null;
    });
    _showSnack("Bağlantı Kesildi");
  }

  void _sendData(String data) async {
    if (connection != null && isConnected) {
      try {
        connection!.output.add(Uint8List.fromList(utf8.encode(data)));
        await connection!.output.allSent;
        _showSnack(data == "1" ? "Kilit AÇILIYOR" : "Kilit KAPANIYOR");
      } catch (e) {
        _showSnack("Gönderme Hatası!");
      }
    } else {
      _showSnack("Cihaz bağlı değil!");
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.blueGrey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "GÜVENLİK PANELİ",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              // .withOpacity yerine .withValues (Flutter'ın yeni standardı)
              color: isConnected
                  ? Colors.green.withValues(alpha: 0.2)
                  : Colors.red.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isConnected ? Colors.green : Colors.red,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isConnected
                      ? Icons.bluetooth_connected
                      : Icons.bluetooth_disabled,
                  color: isConnected ? Colors.green : Colors.red,
                  size: 30,
                ),
                const SizedBox(width: 10),
                Text(
                  isConnected
                      ? "Bağlı: ${_connectedDevice?.name}"
                      : "Bağlantı Yok",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Eğer işlem yapılıyorsa yuvarlak dönen simge göster
          if (_isLoading) const LinearProgressIndicator(),

          Expanded(
            child: isConnected ? _buildControlPanel() : _buildDeviceList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceList() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            "Kayıtlı Cihazlar (Bluetooth Ayarlarından Eşleştirin)",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _devicesList.length,
            itemBuilder: (context, index) {
              final device = _devicesList[index];
              return Card(
                color: const Color(0xFF2D2D44),
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: ListTile(
                  title: Text(
                    device.name ?? "Bilinmeyen Cihaz",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(device.address),
                  trailing: const Icon(Icons.link, color: Colors.white70),
                  onTap: () => _connect(device),
                ),
              );
            },
          ),
        ),
        ElevatedButton.icon(
          onPressed: _getPairedDevices,
          icon: const Icon(Icons.refresh),
          label: const Text("Listeyi Yenile"),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6C63FF),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildControlPanel() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildBigButton("KİLİDİ AÇ", "1", Colors.green, Icons.lock_open),
          const SizedBox(height: 30),
          _buildBigButton("KİLİDİ KAPAT", "0", Colors.red, Icons.lock),
          const SizedBox(height: 50),
          TextButton.icon(
            onPressed: _disconnect,
            icon: const Icon(Icons.exit_to_app, color: Colors.grey),
            label: const Text(
              "Bağlantıyı Kes",
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBigButton(
      String title, String command, Color color, IconData icon) {
    return GestureDetector(
      onTap: () => _sendData(command),
      child: Container(
        width: 200,
        height: 150,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: color, width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
