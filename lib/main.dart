import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  // Uygulamanın başlangıç noktası
  runApp(const MyApp());
}

// Uygulamanın kök widget'ı (Temel ayarlar burada yapılır)
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Sağ üstteki debug bandını gizler
      title: 'Akıllı Kilit',
      // Uygulamanın genel tema ayarları (Koyu mod ve yazı tipi)
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const HomePage(),
    );
  }
}

// Ana Sayfa (StatefulWidget: Durum değiştirebilen ekran)
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Demo sunumu için bağlantı durumu varsayılan olarak aktif
  bool isConnected = true;
  // Kilit durumunu takip eden değişken (true: Kilitli, false: Açık)
  bool _isLocked = true;

  // Bluetooth veri gönderimini simüle eden fonksiyon
  // Gerçek sinyal göndermek yerine arayüzü günceller ve kullanıcıya geri bildirim verir
  void _sendData(String data) async {
    // İşlem gerçekleşiyor hissi vermek için kısa bir gecikme ekledik
    await Future.delayed(const Duration(milliseconds: 200));

    setState(() {
      // Gelen veriye göre kilit durumunu (görseli) güncelle
      // "0" gelirse kilitlenir, "1" gelirse açılır
      _isLocked = (data == "0");
    });

    // İşlem sonucunu ekranın altında mesaj olarak göster
    _showSnack(
        data == "1" ? "Kilit AÇILIYOR..." : "Kilit KİTLENİYOR...",
        data == "1"
            ? Colors.green
            : Colors.red // Mesajın rengini duruma göre ayarla
        );
  }

  // Kullanıcıya alt tarafta bilgi mesajı (SnackBar) gösteren yardımcı fonksiyon
  void _showSnack(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold)),
      duration: const Duration(seconds: 1), // Mesajın ekranda kalma süresi
      backgroundColor: color,
      behavior:
          SnackBarBehavior.floating, // Mesajın yüzen bir baloncuk gibi durması
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(10),
    ));
  }

  @override
  Widget build(BuildContext context) {
    // Arka plan için özel gradyan (renk geçişi) tasarımı
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
        ),
      ),
      child: Scaffold(
        backgroundColor:
            Colors.transparent, // Arka planı şeffaf yap ki gradyan görünsün
        appBar: AppBar(
          title: const Text("AKILLI KİLİT PANELİ",
              style:
                  TextStyle(letterSpacing: 1.2, fontWeight: FontWeight.w600)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Column(
          children: [
            // 1. Ekranın üst kısmı: Kilit durumu ve animasyonlu ikon
            _buildStatusHeader(),

            // 2. Ekranın alt kısmı: Kontrol butonlarının bulunduğu panel
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 20),
                decoration: const BoxDecoration(
                  color: Colors.black26, // Panelin arka plan rengi
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30)),
                ),
                // Butonları içeren fonksiyonu çağırıyoruz
                child: _buildControls(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Kilit durumunu gösteren üst görsel bileşen (Widget)
  Widget _buildStatusHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40.0),
      child: Column(
        children: [
          // Duruma göre renk ve gölge değiştiren animasyonlu kutu
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                // Kilitli ise kırmızı, açık ise yeşil tonlarında arka plan
                color: _isLocked
                    ? Colors.red.withValues(alpha: 0.15)
                    : Colors.green.withValues(alpha: 0.15),
                border: Border.all(
                    color: _isLocked ? Colors.redAccent : Colors.greenAccent,
                    width: 4),
                // Duruma göre renk değiştiren neon efektli gölge
                boxShadow: [
                  BoxShadow(
                    color: _isLocked
                        ? Colors.red.withValues(alpha: 0.5)
                        : Colors.green.withValues(alpha: 0.5),
                    blurRadius: 30,
                    spreadRadius: 5,
                  )
                ]),
            // Kilit durumuna göre değişen ikon
            child: Icon(
              _isLocked ? Icons.lock : Icons.lock_open_rounded,
              size: 80,
              color: _isLocked ? Colors.redAccent : Colors.greenAccent,
            ),
          ),
          const SizedBox(height: 20),
          // Kilit durumunu yazı ile belirt
          Text(
            _isLocked ? "KİLİTLİ" : "AÇIK",
            style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: _isLocked ? Colors.redAccent : Colors.greenAccent),
          ),
          const SizedBox(height: 5),
          // Bağlantı durumunu gösteren alt metin
          const Text(
            "Bağlı Cihaz: HC-06 (Demo)",
            style: TextStyle(color: Colors.white60, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // Kilit Açma ve Kapama butonlarını içeren panel
  Widget _buildControls() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Kilit Açma Butonu (Yeşil)
          _buildGlassButton(
              title: "KİLİDİ AÇ",
              icon: Icons.lock_open,
              color: Colors.greenAccent,
              onTap: () => _sendData("1") // "1" komutu gönder
              ),

          const SizedBox(height: 25),

          // Kilit Kapama Butonu (Kırmızı)
          _buildGlassButton(
              title: "KİLİDİ KAPAT",
              icon: Icons.lock,
              color: Colors.redAccent,
              onTap: () => _sendData("0") // "0" komutu gönder
              ),

          const SizedBox(height: 50),

          // Sistem durumu metni
          const Text("Sistem Çevrimiçi",
              style: TextStyle(
                  color: Colors.green, fontSize: 14, letterSpacing: 1))
        ],
      ),
    );
  }

  // Özel Tasarım Cam Efektli (Glassmorphism) Buton Widget'ı
  // Kod tekrarını önlemek için buton yapısı burada tanımlandı
  Widget _buildGlassButton(
      {required String title,
      required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap, // Butona basıldığında çalışacak fonksiyon
      child: Container(
        width: 240,
        height: 80,
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15), // Yarı saydam arka plan
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: color.withValues(alpha: 0.5),
                width: 1.5), // İnce çerçeve
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.1), // Hafif gölge
                blurRadius: 20,
                spreadRadius: 2,
              )
            ]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color), // Buton ikonu
            const SizedBox(width: 20),
            Text(title,
                // Buton üzerindeki yazı stili
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5)),
          ],
        ),
      ),
    );
  }
}
