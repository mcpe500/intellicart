/**
 * Database Manager
 *
 * This class provides a centralized way to manage database operations with support for multiple
 * database implementations (JSON, SQLite, Firebase, MySQL). It uses a factory pattern to
 * instantiate the appropriate database implementation based on configuration.
 *
 * @class DatabaseManager
 * @description Centralized database manager supporting multiple implementations
 * @author Intellicart Team
 * @version 1.0.0
 */

import { DatabaseInterface } from "./DatabaseInterface";

// Enum for supported database types
export enum DatabaseType {
  JSON = "json",
  SQLITE = "sqlite",
  FIREBASE = "firebase",
  MYSQL = "mysql",
}

// Configuration interface for database connections
export interface DatabaseConfig {
  type: DatabaseType;
  path?: string; // For JSON and SQLite files
  host?: string; // For MySQL
  port?: number; // For MySQL
  username?: string; // For MySQL
  password?: string; // For MySQL
  database?: string; // For MySQL
  firebaseConfig?: any; // For Firebase configuration
}

export class DatabaseManager {
  private database: DatabaseInterface<any> | null = null;
  private config: DatabaseConfig;

  /**
   * Constructor for DatabaseManager
   *
   * @param {DatabaseConfig} config - Configuration for the database connection
   */
  constructor(config: DatabaseConfig) {
    this.config = config;
  }

  /**
   * Initialize the database manager by creating the appropriate database implementation
   *
   * @function initialize
   * @returns {Promise<void>} A promise that resolves when initialization is complete
   */
  async initialize(): Promise<void> {
    switch (this.config.type) {
      case DatabaseType.JSON:
        const { JSONDatabase } = await import(
          "./implementations/json/JSONDatabase"
        );
        this.database = new JSONDatabase(this.config.path || "./data.json");
        break;

      case DatabaseType.SQLITE:
        const { SQLiteDatabase } = await import(
          "./implementations/sqlite/SQLiteDatabase"
        );
        this.database = new SQLiteDatabase(
          this.config.path || "./database.sqlite",
        );
        break;

      case DatabaseType.FIREBASE:
        const { FireDatabase } = await import(
          "./implementations/firebase/FireDatabase"
        );
        this.database = new FireDatabase(this.config.firebaseConfig);
        break;

      case DatabaseType.MYSQL:
        const { MySQLDatabase } = await import(
          "./implementations/mysql/MySQLDatabase"
        );
        this.database = new MySQLDatabase({
          host: this.config.host || "localhost",
          port: this.config.port || 3306,
          username: this.config.username || "root",
          password: this.config.password || "",
          database: this.config.database || "intellicart",
        });
        break;

      default:
        throw new Error(`Unsupported database type: ${this.config.type}`);
    }

    await this.database.init();
  }

  /**
   * Get the initialized database instance
   *
   * @function getDatabase
   * @returns {DatabaseInterface<any> | null} The database instance or null if not initialized
   */
  getDatabase<T>(): DatabaseInterface<T> {
    if (!this.database) {
      throw new Error("Database not initialized. Call initialize() first.");
    }
    return this.database as DatabaseInterface<T>;
  }

  /**
   * Switch to a different database implementation at runtime
   *
   * @function switchDatabase
   * @param {DatabaseConfig} newConfig - New configuration for the database connection
   * @returns {Promise<void>} A promise that resolves when the switch is complete
   */
  async switchDatabase(newConfig: DatabaseConfig): Promise<void> {
    // Close the current database if it's initialized
    if (this.database) {
      await this.database.close();
    }

    // Update config and reinitialize
    this.config = newConfig;
    await this.initialize();
  }

  /**
   * Close the current database connection
   *
   * @function close
   * @returns {Promise<void>} A promise that resolves when the database is closed
   */
  async close(): Promise<void> {
    if (this.database) {
      await this.database.close();
      this.database = null;
    }
  }
}
