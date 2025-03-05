// Gerekli paketlerin import edilmesi
import 'package:firebase_auth/firebase_auth.dart'; // Firebase kimlik doğrulama işlemleri için
import 'package:firebase_messaging/firebase_messaging.dart'; // Firebase bulut mesajlaşması için
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Yerel bildirimleri yönetmek için
import 'package:get/get.dart';
import 'package:googleapis_auth/auth.dart'; // Google API erişim token işlemleri için
import 'package:http/http.dart' as http; // HTTP istekleri yapmak için
import 'dart:convert'; // JSON işlemleri için

// Proje içerisindeki erişim token'ını sağlayan sınıfı import ediyoruz
import 'package:tutoring/data/api/access_firebase_token.dart';
import 'package:tutoring/views/home/chat_screen.dart';

/// Arka planda (background) gelen mesajları işleyen fonksiyon
/// Bu fonksiyon, uygulama kapalıyken veya arka planda iken alınan FCM mesajlarını işlemek için kullanılır.
Future<void> handleBackgroundMessage(RemoteMessage message) async {
  // Gelen mesajı konsola yazdırarak log'luyoruz
  print('Arka planda gelen mesaj: $message');
  // Buraya arka planda mesaj alındığında yapılması gereken ek işlemler eklenebilir.
}

/// Uygulamadaki bildirim işlemlerini yöneten servis sınıfı.
/// Bu sınıf, FirebaseMessaging ve yerel bildirimleri (local notifications) yapılandırmak ve yönetmek için kullanılır.
class NotificationService {
  // Private constructor kullanılarak singleton (tek örnek) yapı oluşturulur.
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  // Firebase Messaging örneğini tanımlıyoruz
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Android platformu için bildirim kanalı tanımlaması
  // Bu kanal, bildirimin önceliğini, ses ayarlarını vb. yapılandırmak için kullanılır.
  final AndroidNotificationChannel channel = const AndroidNotificationChannel(
    'notification', // Kanal ID'si
    'notification', // Kanal adı
    importance: Importance.max, // En yüksek öncelik
    playSound: true, // Bildirim sesi çalınsın
    showBadge: true, // Uygulama simgesinde bildirim rozetini göster
  );

  // Flutter yerel bildirimleri için kullanılan plugin örneği
  final FlutterLocalNotificationsPlugin localNotification =
      FlutterLocalNotificationsPlugin();

  /// Bildirim sistemini başlatan ana fonksiyon.
  /// Bu fonksiyon, gerekli izinleri isteyip, token işlemlerini yapar ve bildirim dinleyicilerini ayarlar.
  Future<void> initNotification() async {
    // Kullanıcıdan bildirim izinlerini talep ediyoruz.
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true, // Uyarı mesajlarını göster
      announcement: false, // Duyuru mesajları kapalı
      badge: true, // Uygulama simgesindeki rozetleri güncelle
      carPlay: true, // CarPlay uyumluluğu
      criticalAlert: true, // Kritik uyarı mesajları
      provisional: false, // Geçici izin isteme
      sound: true, // Sesli bildirimleri etkinleştir
    );

    // Eğer kullanıcı bildirim izinlerini reddederse, bunu log'luyoruz.
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      print('Bildirim izni reddedildi');
    }

    // Eğer kullanıcı oturum açmışsa, FCM token'ını alıyoruz.
    if (FirebaseAuth.instance.currentUser != null) {
      final fcmToken = await _messaging.getToken();
      // Burada alınan token, veritabanında saklanabilir.
      print('Kullanıcıya ait FCM Token: $fcmToken');
    }

    // Arka plan mesajlarını işleyebilmek için arka plan mesaj handler'ını ayarlıyoruz.
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

    // Push bildirimleri ve yerel bildirimlerin (local notifications) yapılandırmasını başlatıyoruz.
    initPushNotification();
    initLocalNotification();
  }

  /// Push bildirimlerinin (mesajların) yapılandırılmasını sağlayan fonksiyon.
  Future<void> initPushNotification() async {
    // Android için bildirim başlangıç ayarlarını yapıyoruz.
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Genel bildirim başlangıç ayarlarını oluşturuyoruz.
    const InitializationSettings settings =
        InitializationSettings(android: androidSettings);
    print('Bildirim başlangıç ayarları: $settings');

    // FlutterLocalNotificationsPlugin'i verilen ayarlarla başlatıyoruz.
    await localNotification.initialize(settings);
  }

  /// Uygulama ön planda iken ve arka planda iken gelen bildirimlerin nasıl gösterileceğini ayarlar.
  Future<void> initLocalNotification() async {
    // Uygulama ön planda iken bildirimlerin uyarı, rozet ve ses seçeneklerini ayarlıyoruz.
    await _messaging.setForegroundNotificationPresentationOptions(
        alert: true, // Uyarı göster
        badge: true, // Rozeti güncelle
        sound: true // Ses çal
        );

    // Uygulama tamamen kapalıyken açıldığında, uygulamaya gelen ilk bildirimi işliyoruz.
    _messaging.getInitialMessage().then(handleMessage);

    // Uygulama arka planda iken bildiriye tıklandığında mesajı işlemek için dinleyici ekliyoruz.
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    print('Bildirim dinleyicileri ayarlandı.');
  }

  /// Gelen bildirim mesajlarını işleyen fonksiyon.
  /// Bu fonksiyon, bildirim alındığında veya uygulama arka planda iken bildirime tıklandığında çalışır.
  void handleMessage(RemoteMessage? message) {
    print('Bildirim mesajı alındı: $message');
    if (message != null && message.data.isNotEmpty) {
      // Data bölümünden chat bilgilerini alıyoruz.
      final chatId = message.data['chatId'];
      final receiverId = message.data['receiverId'];

      // Eğer chatId ve receiverId null değilse, ilgili chat ekranına yönlendiriyoruz.
      if (chatId != null && receiverId != null) {
        // Get paketini kullanarak yönlendirme yapıyoruz.
        Get.to(() => ChatScreen(chatId: chatId, receiverId: receiverId));
      }
    }
  }

  /// Uygulamanın belirli bir konuya (topic) abone olmasını sağlar.
  /// Bu sayede, ilgili konuya gönderilen bildirimleri alır.
  void subscribeToTopic() {
    _messaging.subscribeToTopic('notification');
  }

  /// FCM API çağrıları için kullanılan erişim token'ını alır.
  /// Bu token, FCM üzerinden bildirim gönderme işlemlerinde Authorization header olarak kullanılır.
  Future<String?> getToken() async {
    // AccessTokenFirebase sınıfı, Firebase erişim token'ını alma işlemini gerçekleştirir.
    AccessTokenFirebase accessTokenGetter = AccessTokenFirebase();
    final String token = await accessTokenGetter.getAccessToken();
    return token;
  }

  /// Belirtilen cihaza (token) bildirim gönderme işlemini gerçekleştirir.
  ///
  /// [token]: Bildirimin gönderileceği cihazın FCM token'ı.
  /// [title]: Bildirimin başlığı.
  /// [message]: Bildirimin içeriği.
  Future<void> sendTokenNotification(String token, String title, String message,
      String chatId, String receiverId) async {
    try {
      // Bildirim mesajı JSON yapısını oluşturuyoruz, data kısmına chat bilgilerini ekliyoruz.
      final body = {
        'message': {
          'token': token, // Hedef cihazın token'ı
          'notification': {
            'body': message, // Bildirimin içeriği
            'title': title, // Bildirimin başlığı
          },
          'data': {
            'chatId': chatId, // Chat odası ID'si
            'receiverId': receiverId, // Mesajın gönderileceği kullanıcı ID'si
          }
        },
      };

      // FCM API URL'si
      String url =
          'https://fcm.googleapis.com/v1/projects/private-tutoring-app/messages:send';

      // Bildirim gönderme yetkisi için erişim token'ını alıyoruz.
      String? accessKey = await getToken();

      // HTTP POST isteği gönderiyoruz.
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessKey',
        },
        body: jsonEncode(body),
      );

      print('Bildirim gönderme isteği durumu: ${response.statusCode}');
    } catch (e) {
      print("Bildirim gönderilirken hata oluştu: $e");
    }
  }
}
