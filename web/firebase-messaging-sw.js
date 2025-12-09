importScripts('https://www.gstatic.com/firebasejs/10.13.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.13.0/firebase-messaging-compat.js');

firebase.initializeApp({
    apiKey: "AIzaSyCVRutSuezynDOQ0LRsY8FOGmPpLQZ_7aY",
    authDomain: "staffora-project-2025.firebaseapp.com",
    projectId: "staffora-project-2025",
    storageBucket: "staffora-project-2025.firebasestorage.app",
    messagingSenderId: "847688702354",
    appId: "1:847688702354:web:6f9cbafa55f01efcc1494b"
});

const messaging = firebase.messaging();
