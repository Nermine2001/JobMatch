const functions = require("firebase-functions");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");

admin.initializeApp();
const db = admin.firestore();

const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: "nermine.chennaoui@isimg.tn",
    pass: "nermine30072001",
  },
});

// Fonction déclenchée à l'ajout d'une requête support
exports.onNewSupportQuery = functions.firestore
    .document("support_queries/{docId}")
    .onCreate(async (snap, context) => {
      const docId = context.params.docId;
      const data = snap.data();
      const userEmail = data.userEmail;

      setTimeout(async () => {
        const mailOptions = {
          from: "nermine.chennaoui@isimg.tn",
          to: userEmail,
          subject: "Confirmation",
          text: `Hi, we’ve received your query "${data.title}". thanks for your patience for 2 days for our response.\n\nL’équipe support.`,
        };

        await transporter.sendMail(mailOptions);
      }, 15 * 60 * 1000);

      // Délai : 2 jours (en ms)
      //const delayMs = 2 * 24 * 60 * 60 * 1000;

      // for test
      const delayMs = 18 * 60 * 1000;

      console.log(`Support query received: ${docId}. Resolving in 15 minutes...`);

      setTimeout(async () => {
        try {
          await db.collection("support_queries").doc(docId).update({
            status: "resolved",
            responses: admin.firestore.FieldValue.arrayUnion({
              responseText: "Your issue has been reviewed. Thanks for your patience.",
              respondedAt: admin.firestore.FieldValue.serverTimestamp(),
            }),
          });

          console.log(`Query ${docId} auto-resolved.`);
        } catch (error) {
          console.error(`Failed to auto-resolve query ${docId}:`, error);
        }
      }, delayMs);
    });
