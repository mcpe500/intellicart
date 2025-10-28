/**
 * Database Configuration
 *
 * This file provides a centralized way to configure the database manager
 * based on environment variables.
 *
 * @file Database configuration
 * @author Intellicart Team
 * @version 1.0.0
 */

import {
  DatabaseManager,
  DatabaseType,
  DatabaseConfig,
} from "./DatabaseManager";

// Create a global database manager instance
let dbManager: DatabaseManager;

// Initialize the database manager based on environment configuration
const initializeDatabaseManager = (): DatabaseManager => {
  // Get database type from environment variable, default to JSON
  const dbType = process.env.DB_TYPE || "json";

  let config: DatabaseConfig;

  switch (dbType.toLowerCase()) {
    case "json":
      config = {
        type: DatabaseType.JSON,
        path: process.env.DB_PATH || "./data/db.json",
      };
      break;

    case "sqlite":
      config = {
        type: DatabaseType.SQLITE,
        path: process.env.DB_PATH || "./data/database.sqlite",
      };
      break;

    case "firebase":
      config = {
        type: DatabaseType.FIREBASE,
        firebaseConfig: {
          apiKey: process.env.FIREBASE_API_KEY,
          authDomain: process.env.FIREBASE_AUTH_DOMAIN,
          projectId: process.env.FIREBASE_PROJECT_ID,
          storageBucket: process.env.FIREBASE_STORAGE_BUCKET,
          messagingSenderId: process.env.FIREBASE_MESSAGING_SENDER_ID,
          appId: process.env.FIREBASE_APP_ID,
          databaseURL: process.env.FIREBASE_DATABASE_URL,
        },
      };
      break;

    case "mysql":
      config = {
        type: DatabaseType.MYSQL,
        host: process.env.DB_HOST || "localhost",
        port: parseInt(process.env.DB_PORT || "3306"),
        username: process.env.DB_USER || "root",
        password: process.env.DB_PASSWORD || "",
        database: process.env.DB_NAME || "intellicart",
      };
      break;

    default:
      // Default to JSON
      config = {
        type: DatabaseType.JSON,
        path: process.env.DB_PATH || "./data/db.json",
      };
  }

  return new DatabaseManager(config);
};

// Initialize the database manager
dbManager = initializeDatabaseManager();

export { dbManager };
