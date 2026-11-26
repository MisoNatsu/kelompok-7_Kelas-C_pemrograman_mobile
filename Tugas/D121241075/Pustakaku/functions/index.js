/**
 * Cloud Function: setiap dokumen baru di koleksi `announcements`
 * dikirim sebagai push notification (FCM) ke topic `pengumuman`.
 *
 * Deploy (butuh paket Blaze / pay-as-you-go, kuota gratisnya besar):
 *   cd functions && npm install && cd ..
 *   firebase deploy --only functions
 *
 * Alternatif tanpa Cloud Functions: kirim manual dari
 * Firebase Console > Messaging > New campaign > Topic: pengumuman.
 */
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getMessaging } = require("firebase-admin/messaging");

initializeApp();

exports.onAnnouncementCreated = onDocumentCreated(
  { document: "announcements/{id}", region: "asia-southeast2" },
  async (event) => {
    const data = event.data?.data();
    if (!data) return;

    const message = {
      topic: "pengumuman",
      notification: {
        title: data.title ?? "Pengumuman baru",
        body: data.body ?? "",
      },
      data: {
        route: "announcements",
        announcementId: event.params.id,
      },
      android: {
        priority: "high",
        notification: { channelId: "pengumuman_channel" },
      },
      apns: { payload: { aps: { sound: "default" } } },
    };

    const id = await getMessaging().send(message);
    console.log(`Pengumuman "${data.title}" terkirim ke topic pengumuman (${id})`);
  }
);
