// Naye tareeqe se functions import karna
const {onDocumentCreated, onDocumentUpdated} = require("firebase-functions/v2/firestore");
const {initializeApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const {getMessaging} = require("firebase-admin/messaging");
const logger = require("firebase-functions/logger");

// Firebase Admin SDK ko initialize karna
initializeApp();

/**
 * FUNCTION 1: Jab nai booking request aaye to LANDLORD ko notification bhejna
 * (Naye v2 Syntax ke saath)
 */
exports.sendBookingNotification = onDocumentCreated("bookings/{bookingId}", async (event) => {
  logger.info("New booking detected, starting notification function.");

  const snapshot = event.data;
  if (!snapshot) {
    logger.error("No data associated with the event.");
    return;
  }
  const bookingData = snapshot.data();

  const landlordId = bookingData.landlordId;
  const tenantName = bookingData.tenantName;
  const propertyTitle = bookingData.propertyTitle;

  if (!landlordId) {
    logger.error("Error: Landlord ID missing.");
    return;
  }

  // Landlord ka fcmToken haasil karna
  const userDoc = await getFirestore().collection("users").doc(landlordId).get();
  if (!userDoc.exists) {
    logger.error(`User document not found for landlord: ${landlordId}`);
    return;
  }

  const fcmToken = userDoc.data().fcmToken;
  if (!fcmToken) {
    logger.error("Error: Landlord's FCM token is missing.");
    return;
  }

  // Notification ka message banayein
  const payload = {
    notification: {
      title: "New Booking Request! 🏡",
      body: `${tenantName} wants to book: ${propertyTitle}.`,
      sound: "default",
    },
  };

  logger.info(`Sending new booking notification to token: ${fcmToken}`);
  try {
    return await getMessaging().sendToDevice(fcmToken, payload);
  } catch (error) {
    logger.error("Error sending notification:", error);
  }
});

/**
 * FUNCTION 2: Jab booking ka status update ho to TENANT ko notification bhejna
 * (Naye v2 Syntax ke saath)
 */
exports.sendBookingStatusUpdateNotification = onDocumentUpdated("bookings/{bookingId}", async (event) => {
  logger.info("Booking update detected, starting notification function.");

  const beforeData = event.data.before.data();
  const afterData = event.data.after.data();

  // Check karein ke sirf status hi change hua hai
  if (beforeData.status === afterData.status) {
    logger.info("Status not changed, no notification sent.");
    return;
  }

  const tenantId = afterData.tenantId;
  const propertyTitle = afterData.propertyTitle;
  const newStatus = afterData.status.toUpperCase(); // e.g., "ACCEPTED"

  if (!tenantId) {
    logger.error("Error: Tenant ID missing.");
    return;
  }

  // Tenant ka fcmToken haasil karna
  const userDoc = await getFirestore().collection("users").doc(tenantId).get();
  if (!userDoc.exists) {
    logger.error(`User document not found for tenant: ${tenantId}`);
    return;
  }

  const fcmToken = userDoc.data().fcmToken;
  if (!fcmToken) {
    logger.error("Error: Tenant's FCM token is missing.");
    return;
  }

  // Notification ka message banayein
  const payload = {
    notification: {
      title: `Booking ${newStatus}! 🎉`,
      body: `Your request for "${propertyTitle}" has been ${newStatus}.`,
    },
  };

  logger.info(`Sending status update notification to token: ${fcmToken}`);
  try {
    return await getMessaging().sendToDevice(fcmToken, payload);
  } catch (error) {
    logger.error("Error sending notification:", error);
  }
});