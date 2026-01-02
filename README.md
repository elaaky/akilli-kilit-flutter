# 🔐 Mobil Kontrollü ve Şifreli Akıllı Kilit Sistemi

Bu proje, ev ve ofis güvenliği için geliştirilmiş; hem fiziksel tuş takımıyla hem de mobil uygulama üzerinden Bluetooth ile kontrol edilebilen hibrit bir akıllı kilit prototipidir.

## 🚀 Proje Hakkında
Geleneksel anahtar taşıma derdine son vererek, güvenliği teknolojiyle birleştirmeyi amaçladık. Kullanıcı, kapıyı isterse önceden belirlediği 4 haneli şifre ile, isterse geliştirdiğimiz Android uygulaması üzerinden tek tuşla açabilir.

## 🌟 Özellikler
- **Çift Yönlü Kontrol:** Hem Keypad (Şifre) hem Mobil (Bluetooth) erişim.
- **Güvenlik:** Yanlış şifre girildiğinde sesli alarm (Buzzer) uyarısı.
- **Kullanıcı Dostu Arayüz:** Flutter ile geliştirilmiş modern mobil uygulama.
- **Otomatik Kilitleme:** Servo motor mekanizması ile fiziksel kilitleme.
- **Geri Bildirim:** İşlem durumuna göre sesli uyarılar.

## 🛠️ Kullanılan Teknolojiler ve Donanımlar

### Yazılım
- **Flutter (Dart):** Mobil Uygulama (Android)
- **Arduino IDE (C++):** Gömülü Yazılım

### Donanım
- Arduino Uno R3
- HC-06 Bluetooth Modülü
- SG90 Servo Motor
- 3x4 Membran Keypad
- Buzzer (Aktif)
- Jumper Kablolar ve Breadboard

## 🔌 Devre Şeması
Projenin devre bağlantıları ve pin diyagramı `devre_sema` klasöründe mevcuttur.
- **Servo:** Pin 12
- **Buzzer:** Pin 13
- **Bluetooth:** RX->11, TX->10
- **Keypad:** 9,8,7,6,5,4,3

## 💻 Kurulum ve Çalıştırma

1. **Arduino:** `arduino_kodu` klasöründeki `.ino` dosyasını Arduino Uno'ya yükleyin.
2. **Mobil Uygulama:** Projeyi VS Code ile açıp `flutter run` komutuyla telefonunuza yükleyin.
3. **Bağlantı:** Telefon Bluetooth ayarlarından `HC-06` ile eşleşin (Şifre: 1234).
4. **Kullanım:** Uygulamadan "KİLİDİ AÇ" butonuna basın veya Keypad'den şifreyi girin.

## 👥 Ekip
- **Elanur Akkaya** - Geliştirici

---
*Bu proje Robotik Programlama /Bartın Üniversitesi kapsamında geliştirilmiştir.*
