const functions = require("firebase-functions");
const admin = require("firebase-admin");

// Initialize Firebase Admin SDK if not already initialized
if (!admin.apps.length) {
    admin.initializeApp();
}

const db = admin.firestore();

/**
 * Cloud Function: Triggered on user updates to sync drivers collection
 *
 * When a user document is created or updated:
 * 1. If role === 'driver' -> Create or update corresponding driver record
 * 2. If role changed from 'driver' to something else -> Mark driver as inactive
 * 3. Syncs assigned route and assigned bus information
 */
exports.syncDriversCollection = functions.firestore
    .document("users/{userId}")
    .onWrite(async (change, context) => {
        try {
            const userId = context.params.userId;
            const newData = change.after.exists ? change.after.data() : null;
            const oldData = change.before.exists ? change.before.data() : null;

            // Case 1: New user created with driver role
            const newRole = newData ? (newData.role || "").toLowerCase() : "";
            if (!oldData && newData && newRole === "driver") {
                console.log(`[NEW DRIVER] Creating driver record for user: ${userId}`);

                const driverRef = db.collection("drivers");

                // Check if driver record already exists
                const existingDriver = await driverRef
                    .where("driverId", "==", userId)
                    .get();

                if (existingDriver.empty) {
                    // Create new driver record
                    await driverRef.add({
                        driverId: userId,
                        driverName: `${newData.firstName || ""} ${newData.lastName || ""}`.trim(),
                        driverEmail: newData.email || "",
                        driverPhone: newData.phone || "",
                        assignedBusNumber: "",
                        assignedRoute: "",
                        status: "active",
                        createdAt: admin.firestore.FieldValue.serverTimestamp(),
                        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
                    });
                    console.log(`✓ Driver record created for: ${newData.email}`);
                }
            }

            // Case 2: User updated (existing user)
            if (oldData && newData) {
                const oldUserRole = oldData ? (oldData.role || "").toLowerCase() : "";
                const newUserRole = newData ? (newData.role || "").toLowerCase() : "";

                // Case 2a: User role changed to 'driver'
                if (oldUserRole !== "driver" && newUserRole === "driver") {
                    console.log(`[ROLE CHANGE] User ${userId} is now a driver`);

                    const driverRef = db.collection("drivers");
                    const existingDriver = await driverRef
                        .where("driverId", "==", userId)
                        .get();

                    if (existingDriver.empty) {
                        // Create new driver record
                        await driverRef.add({
                            driverId: userId,
                            driverName: `${newData.firstName || ""} ${newData.lastName || ""}`.trim(),
                            driverEmail: newData.email || "",
                            driverPhone: newData.phone || "",
                            assignedBusNumber: "",
                            assignedRoute: "",
                            status: "active",
                            createdAt: admin.firestore.FieldValue.serverTimestamp(),
                            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
                        });
                        console.log(`✓ Driver created: ${newData.email}`);
                    }
                }

                // Case 2b: User role changed from 'driver' to something else
                if (oldUserRole === "driver" && newUserRole !== "driver") {
                    console.log(`[ROLE CHANGE] User ${userId} is no longer driver`);

                    const driverRef = db.collection("drivers");
                    const driverDocs = await driverRef
                        .where("driverId", "==", userId)
                        .get();

                    driverDocs.forEach(async (doc) => {
                        await doc.ref.update({
                            status: "inactive",
                            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
                        });
                    });
                    console.log(`✓ Driver set inactive: ${oldData.email}`);
                }

                // Case 2c: Driver details updated (name, email, phone)
                if (newUserRole === "driver") {
                    const driverRef = db.collection("drivers");
                    const driverDocs = await driverRef
                        .where("driverId", "==", userId)
                        .get();

                    // Check if any details changed
                    const oldName = `${oldData.firstName || ""} ${oldData.lastName || ""}`.trim();
                    const newName = `${newData.firstName || ""} ${newData.lastName || ""}`.trim();
                    const nameChanged = oldName !== newName;

                    const emailChanged = oldData.email !== newData.email;
                    const oldPhone = oldData.phone || "";
                    const newPhone = newData.phone || "";
                    const phoneChanged = oldPhone !== newPhone;

                    if (nameChanged || emailChanged || phoneChanged) {
                        driverDocs.forEach(async (doc) => {
                            const updateData = {
                                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
                            };

                            if (nameChanged) {
                                updateData.driverName = newName;
                            }

                            if (emailChanged) {
                                updateData.driverEmail = newData.email || "";
                            }

                            if (phoneChanged) {
                                updateData.driverPhone = newData.phone || "";
                            }

                            await doc.ref.update(updateData);
                        });
                        console.log(`✓ Driver details synced: ${newData.email}`);
                    }
                }
            }

            return null;
        } catch (error) {
            console.error("Error syncing drivers:", error);
            throw error;
        }
    });

/**
 * Callable function to manually update driver assignments
 */
exports.updateDriverAssignment = functions.https.onCall(async (data, context) => {
    try {
        // Verify user is authenticated
        if (!context.auth) {
            throw new functions.https.HttpsError(
                "unauthenticated",
                "User must be authenticated",
            );
        }

        const {driverId, assignedBusNumber, assignedRoute} = data;

        if (!driverId) {
            throw new functions.https.HttpsError(
                "invalid-argument",
                "driverId is required",
            );
        }

        const driverRef = db.collection("drivers");
        const driverDocs = await driverRef
            .where("driverId", "==", driverId)
            .get();

        if (driverDocs.empty) {
            throw new functions.https.HttpsError(
                "not-found",
                "Driver not found",
            );
        }

        // Update all driver records
        const updatePromises = driverDocs.docs.map((doc) => {
            return doc.ref.update({
                assignedBusNumber: assignedBusNumber || "",
                assignedRoute: assignedRoute || "",
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            });
        });

        await Promise.all(updatePromises);

        console.log(
            `✓ Driver updated - Bus: ${assignedBusNumber}, Route: ${assignedRoute}`,
        );

        return {
            success: true,
            message: "Driver assignment updated",
        };
    } catch (error) {
        console.error("Error updating driver:", error);
        throw error;
    }
});

/**
 * Callable function to sync all drivers from users collection
 */
exports.syncAllDrivers = functions.https.onCall(async (data, context) => {
    try {
        // Verify user is authenticated
        if (!context.auth) {
            throw new functions.https.HttpsError(
                "unauthenticated",
                "User must be authenticated",
            );
        }

        // Verify admin status from custom claims
        const userRecord = await admin.auth().getUser(context.auth.uid);
        const customClaims = userRecord.customClaims || {};
        if (!customClaims.admin) {
            throw new functions.https.HttpsError(
                "permission-denied",
                "Only admins can sync drivers",
            );
        }

        console.log("[SYNC ALL] Starting full driver sync...");

        // Get all users with driver role
        const usersSnapshot = await db.collection("users")
            .where("role", "==", "driver")
            .get();

        let createdCount = 0;
        let updatedCount = 0;

        for (const userDoc of usersSnapshot.docs) {
            const userData = userDoc.data();
            const userId = userDoc.id;

            const existingDriver = await db.collection("drivers")
                .where("driverId", "==", userId)
                .get();

            if (existingDriver.empty) {
                // Create new driver record
                await db.collection("drivers").add({
                    driverId: userId,
                    driverName: `${userData.firstName || ""} ${userData.lastName || ""}`.trim(),
                    driverEmail: userData.email || "",
                    driverPhone: userData.phone || "",
                    assignedBusNumber: "",
                    assignedRoute: "",
                    status: "active",
                    createdAt: admin.firestore.FieldValue.serverTimestamp(),
                    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
                });
                createdCount++;
                console.log(`  ✓ Created: ${userData.email}`);
            } else {
                // Update existing driver record
                existingDriver.docs.forEach(async (doc) => {
                    await doc.ref.update({
                        driverName: `${userData.firstName || ""} ${userData.lastName || ""}`.trim(),
                        driverEmail: userData.email || "",
                        driverPhone: userData.phone || "",
                        status: "active",
                        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
                    });
                });
                updatedCount++;
            }
        }

        console.log(`[COMPLETE] Created: ${createdCount}, Updated: ${updatedCount}`);

        return {
            success: true,
            message: "Driver sync completed",
            created: createdCount,
            updated: updatedCount,
            total: usersSnapshot.docs.length,
        };
    } catch (error) {
        console.error("Error syncing drivers:", error);
        throw error;
    }
});
