const admin = require('firebase-admin');
const serviceAccount = require('./service-account-key.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const email = 'shanthosh.krishnan@outlook.com';

admin.auth().getUserByEmail(email)
  .then(user => {
    console.log(`Found user: ${user.uid}`);
    return admin.auth().setCustomUserClaims(user.uid, { admin: true });
  })
  .then(() => {
    console.log(`✅ Custom claim 'admin: true' set for ${email}`);
    process.exit(0);
  })
  .catch(error => {
    console.error('❌ Error:', error.message);
    process.exit(1);
  });