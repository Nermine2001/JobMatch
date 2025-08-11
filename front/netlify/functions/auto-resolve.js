const functions = require('@netlify/functions');
const admin = require('firebase-admin');

const privateKey = process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n');


if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert({
      projectId: process.env.FIREBASE_PROJECT_ID,
      clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
      privateKey: privateKey,
    }),
  });
}
const db = admin.firestore();

exports.handler = async function () {
  const now = Date.now();
  const twoDaysAgo = now - 24 * 60 * 60 * 1000;

  const snapshot = await db.collection('support_queries')
    .where('status', '==', 'pending')
    .get();

  for (const doc of snapshot.docs) {
    const data = doc.data();
    if (data.createdAt && data.createdAt.toMillis() < twoDaysAgo) {
      const timestamp = admin.firestore.Timestamp.now();
      await doc.ref.update({
        status: 'resolved',
        responses: admin.firestore.FieldValue.arrayUnion({
          responseText: 'Your issue has been auto-resolved.',
          respondedAt: timestamp,
        }),
      });
    }
  }

  return {
    statusCode: 200,
    body: JSON.stringify({ message: 'Auto-resolution complete.' }),
  };
};
