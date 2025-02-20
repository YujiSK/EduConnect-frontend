importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js');

const firebaseConfig = {
  apiKey: "AlzaSyAs0ixcBVul0IKTRhqBbvkQTv0yE2OPdvB0",
  authDomain: "schoolapp-b5dfb.firebaseapp.com",
  projectId: "schoolapp-b5dfb",
  storageBucket: "schoolapp-b5dfb.appspot.com",
  messagingSenderId: "369132957308",
  appId: "1:369132957308:web:abc7a6907ff62ca0d263f9",
  measurementId: "G-GYVQ1387YF"
};

firebase.initializeApp(firebaseConfig);

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log('📩 背景メッセージ受信: ', payload);

  const notificationTitle = payload.notification?.title || "通知タイトル";
  const notificationOptions = {
    body: payload.notification?.body || "通知の内容",
    icon: "/firebase-logo.png", // ← 適切なアイコンに変更
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
