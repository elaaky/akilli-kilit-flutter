#include <Servo.h>
#include <Keypad.h>
#include <SoftwareSerial.h>

// --- AYARLAR ---
String sifre = "1234";  // Şifren 1-2-3-4
int acikDerece = 0;    
int kapaliDerece = 90;   

#define SERVO_PIN 12
#define BUZZER_PIN 13
SoftwareSerial BTSerial(10, 11); 
Servo kilit;

const byte SATIR = 4;
const byte SUTUN = 3;

// Senin "Ters" klavyene göre ayarladığım harita:
// (1 basınca 1, 2 basınca 2 çıkacak şekilde)
char tuslar[SATIR][SUTUN] = {
  {'9','6','3'},
  {'8','5','2'},
  {'7','4','1'},
  {'#','0','*'} 
};

// Not: Eğer 6 numarayı 2'ye taşıdıysan burayı {9,8,7,2} yap.
// Eğer hala 6'da ise {9,8,7,6} kalsın.
byte satirPin[SATIR] = {9, 8, 7, 6}; 
byte sutunPin[SUTUN] = {5, 4, 3};

Keypad klavye = Keypad(makeKeymap(tuslar), satirPin, sutunPin, SATIR, SUTUN);
String girilen = "";

void setup() {
  Serial.begin(9600);
  BTSerial.begin(9600);
  kilit.attach(SERVO_PIN);
  kilit.write(kapaliDerece); 
  pinMode(BUZZER_PIN, OUTPUT);
  
  bip(100); bip(100);
  Serial.println("SISTEM HAZIR! (Not: Onay tusu artik 9)");
}

void loop() {
  if (BTSerial.available()) {
    char c = BTSerial.read();
    if (c == '1') kilitAc();
    if (c == '0') kilitKapat();
  }

  char tus = klavye.getKey();
  if (tus) {
    bip(50);
    Serial.print("Basilan: "); Serial.println(tus);

    // DİKKAT: ARTIK ONAY TUŞU '#' DEĞİL '1' (Haritadaki konumu gereği)
    // Senin klavyende fiziksel olarak '1' tuşu, kodda '1' olarak görünüyor.
    // Biz 'Giriş' tuşu olarak sağ alt köşeye en yakın çalışan tuşu seçelim.
    // Senin haritana göre '1' tuşu (sağ üst) veya '7' (sol alt) çalışıyor.
    
    // YENİ KURAL: 4 haneli şifreyi girince OTOMATİK kontrol etsin.
    // (Böylece # tuşuna basmana gerek kalmaz!)
    
    girilen += tus;
    
    if (girilen.length() == 4) { // 4 rakam girilince otomatik bak
      Serial.println("4 hane girildi, kontrol ediliyor...");
      delay(500); // Biraz bekle
      
      if (girilen == sifre) {
        Serial.println("SIFRE DOGRU");
        kilitAc();
      } else {
        Serial.println("HATALI");
        hatali();
      }
      girilen = ""; // Sıfırla
    }
  }
}

void kilitAc() {
  kilit.write(acikDerece);
  bip(100); delay(50); bip(100); delay(50); bip(200);
}
void kilitKapat() {
  kilit.write(kapaliDerece);
  digitalWrite(BUZZER_PIN, HIGH); delay(500); digitalWrite(BUZZER_PIN, LOW);
}
void hatali() {
  for(int i=0; i<3; i++) { bip(100); delay(100); }
}
void bip(int sure) {
  digitalWrite(BUZZER_PIN, HIGH); delay(sure); digitalWrite(BUZZER_PIN, LOW); delay(50);
}