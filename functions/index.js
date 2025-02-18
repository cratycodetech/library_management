const functions = require("firebase-functions");
const {RtcTokenBuilder, RtcRole} = require("agora-access-token");

const AGORA_APP_ID = "68cc27d382a44628a9454809677e96e6";
const AGORA_APP_CERTIFICATE = "bd41f893f7d546bdbee2c6cb06e2ed16";

exports.generateAgoraToken = functions.https.onCall((data, context) => {
  const channelName = data.channelName;
  const uid = data.uid || 0;
  const role = RtcRole.PUBLISHER;
  const expireTime = 36000; // 1 hour validity

  if (!channelName) {
    throw new functions.https.HttpsError("invalid", "Channel required");
  }

  const token = RtcTokenBuilder.buildTokenWithUid(
      AGORA_APP_ID,
      AGORA_APP_CERTIFICATE,
      channelName,
      uid,
      role,
      expireTime,
  );

  return {token};
});
