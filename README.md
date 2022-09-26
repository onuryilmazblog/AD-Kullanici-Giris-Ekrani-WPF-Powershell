# AD-Kullanici-Giris-Ekrani-WPF-Powershell

Version 1.0.0


> WPF (Windows Presentation Foundation) ile arayüz tasarımı hazırlanmış olup powershell ile dinamik kodlama yapılmıştır.

[Onur Yılmaz Blog Adresimden](https://onuryilmaz.blog/ad-kullanici-giris-ekrani-wpf-powershell) detaylarını inceleyebilirsiniz.

["Logo.png"](Images\Logo.png) dosyasını değiştirerek kendi logunuzu ekleyebilirsiniz.


*Çalıştırma Komut Satırı:*
>Powershell.exe -ExecutionPolicy Bypass -File ".\Login_View.ps1" -Domain:"Your Domain" -ADGroup:"AD Group" -Title:"Kimlik Doğrulaması" -Company:"Onur Yılmaz" -RetryCount:3

-Domain:“Your Domain”
Domain adresinizi girmeniz gerekmektedir.

-ADGroup:“AD Group”
Kontrol edilmesi gereken AD grubunun belirtilmesi gerekmektedir.

-Title:“Kimlik Doğrulaması”
Kullanıcı doğrulama ekranı başlık bilgisini giriniz. Ekranın üstünde görünmektedir.

-Company:“Onur Yılmaz”
Şirket veya kullanıcı bilginizi giriniz. Ekranın ortasında görünmektedir.

-RetryCount:3
Kullanıcı bilgi girişinin maximum kaç denemede gerçekleştirileceği bilgisini giriniz.


Bu script hiçbir garanti olmaksızın "OLDUĞU GİBİ" sağlanmaktadır. Kendi sorumluluğunuzda kullanınınız.
