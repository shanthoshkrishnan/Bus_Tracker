const {setGlobalOptions} = require("firebase-functions");
const syncFunctions = require("./sync-drivers");

// Export all functions
exports.syncDriversCollection = syncFunctions.syncDriversCollection;
exports.updateDriverAssignment = syncFunctions.updateDriverAssignment;
exports.syncAllDrivers = syncFunctions.syncAllDrivers;

// Set global options
setGlobalOptions({maxInstances: 10});
