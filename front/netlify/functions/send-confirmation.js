const functions = require('@netlify/functions');
const admin = require('firebase-admin');
const nodemailer = require('nodemailer');

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

const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.GMAIL_USER,
    pass: process.env.GMAIL_PASS,
  },
});

exports.handler = async function () {
  const now = Date.now();
  const fifteenMinAgo = now - 15 * 60 * 1000;

  const snapshot = await db.collection('support_queries')
    .where('confirmationSent', '==', false)
    .get();

  if (snapshot.empty) {
    console.log('No new queries needing confirmation email.');
    return {
      statusCode: 200,
      body: JSON.stringify({ message: 'No confirmation needed.' }),
    };
  }

  for (const doc of snapshot.docs) {
    const data = doc.data();
    console.log(`➡️ Checking doc: ${doc.id}`, data);

    if (!data.userEmail) {
      console.warn(`⚠️ Skipping ${doc.id}: missing userEmail`);
      continue;
    }

    if (!data.createdAt) {
      console.warn(`⏳ Skipping ${doc.id}: createdAt not set yet`);
      continue;
    }

    const createdAtMillis = data.createdAt.toMillis();
    if (createdAtMillis > now) {
      console.warn(`⏩ Skipping ${doc.id}: createdAt is in the future`);
      continue;
    }

    const mailOptions = {
      from: process.env.GMAIL_USER,
      to: data.userEmail,
      subject: 'Support Query Received',
      text: `Hi, we’ve received your query titled "${data.title}". Please allow up to 2 days for a full response.\n\n- Support Team`,
    };

    try {
      console.log(`📧 Sending email to ${data.userEmail}...`);
      await transporter.sendMail(mailOptions);
      console.log(`✅ Email sent to ${data.userEmail}`);

      await doc.ref.update({ confirmationSent: true });
      console.log(`✅ Updated confirmationSent for ${doc.id}`);
    } catch (error) {
      console.error(`❌ Error processing ${doc.id}:`, error);
    }
  }

  return {
    statusCode: 200,
    body: JSON.stringify({ message: 'Confirmation email process finished.' }),
  };
};




/*
const functions = require('@netlify/functions');
const admin = require('firebase-admin');
const nodemailer = require('nodemailer');

const privateKey = process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n');


// Firebase setup
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

// Gmail setup
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.GMAIL_USER,
    pass: process.env.GMAIL_PASS,
  },
});

exports.handler = async function () {
  const now = Date.now();
  const fifteenMinAgo = now - 15 * 60 * 1000;

  const snapshot = await db.collection('support_queries')
    //.where('createdAt', '>=', new Date(fifteenMinAgo))
    .where('confirmationSent', '==', false)
    .get();

  for (const doc of snapshot.docs) {
    const data = doc.data();
    console.log(data);

    if (!data.createdAt || data.confirmationSent) continue;

    const createdAtMillis = data.createdAt.toMillis();
    if (createdAtMillis < fifteenMinAgo) continue;

    const mailOptions = {
      from: process.env.GMAIL_USER,
      to: data.userEmail,
      subject: 'Support Query Received',
      text: `Hi, we’ve received your query titled "${data.title}". Please allow up to 2 days for a full response.\n\n- Support Team`,
    };

    try {
      console.log(`Sending email to ${data.userEmail}...`);
      await transporter.sendMail(mailOptions);
      await doc.ref.update({ confirmationSent: true });
      console.log(`Email sent to ${data.userEmail}`);
    } catch (error) {
      console.error('Email error:', error);
    }
  }

  return {
    statusCode: 200,
    body: JSON.stringify({ message: 'Confirmation emails checked.' }),
  };
};
*/
