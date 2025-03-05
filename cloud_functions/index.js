const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendNotification = functions.https.onCall(async (data, context) => {
  // 1) Tüm "data" objesini ham haliyle konsola yazdır
  console.log("sendNotification called with data =>", data);

  // 2) data içindeki token, title, body alanlarını ayrıştır ve tek tek yazdır
  const {token, title, body} = data;
  console.log("token =>", token);
  console.log("title =>", title);
  console.log("body =>", body);

  // 3) İstersen parametrelerin boş ya da undefined olup olmadığını kontrol et
  if (!token || !title || !body) {
    console.error("Bir veya daha fazla parametre boş!", {
      token,
      title,
      body,
    });
    throw new functions.https.HttpsError(
        "invalid-argument",
        "Token, title ve body zorunludur.",
    );
  }

  // 4) Her şey dolu ise bildirim oluştur
  const message = {
    token,
    notification: {
      title,
      body,
    },
  };

  try {
    // 5) Mesajı Firebase Cloud Messaging ile gönder
    await admin.messaging().send(message);
    console.log("Bildirim başarıyla gönderildi!");
    return {success: true};
  } catch (error) {
    console.error("Bildirim gönderilemedi:", error);
    throw new functions.https.HttpsError(
        "internal",
        "Bildirim gönderilemedi.",
        error,
    );
  }
});
