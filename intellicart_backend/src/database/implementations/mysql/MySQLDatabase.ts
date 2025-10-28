/**
 * MySQL Database Implementation
 *
 * This class implements the DatabaseInterface using MySQL as the database engine.
 * It provides basic CRUD operations using MySQL database.
 *
 * @class MySQLDatabase
 * @implements {DatabaseInterface<any>}
 * @description MySQL database implementation
 * @author Intellicart Team
 * @version 1.0.0
 */

import { DatabaseInterface } from "../../DatabaseInterface";
import mysql from "mysql2/promise";

export interface MySQLConfig {
  host: string;
  port: number;
  username: string;
  password: string;
  database: string;
}

export class MySQLDatabase implements DatabaseInterface<any> {
  private connection: mysql.Connection | null = null;
  private config: MySQLConfig;

  /**
   * Constructor for MySQLDatabase
   *
   * @param {MySQLConfig} config - MySQL configuration object
   */
  constructor(config: MySQLConfig) {
    this.config = config;
  }

  /**
   * Initialize the database by establishing a connection and creating tables if they don't exist
   *
   * @function init
   * @returns {Promise<void>} A promise that resolves when initialization is complete
   */
  async init(): Promise<void> {
    // Create a connection to MySQL server
    this.connection = await mysql.createConnection({
      host: this.config.host,
      port: this.config.port,
      user: this.config.username,
      password: this.config.password,
      database: this.config.database,
    });

    // Create tables if they don't exist
    await this.connection.execute(`
      CREATE TABLE IF NOT EXISTS users (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        email VARCHAR(255) UNIQUE NOT NULL,
        password VARCHAR(255) NOT NULL,
        role VARCHAR(50) DEFAULT 'buyer',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    await this.connection.execute(`
      CREATE TABLE IF NOT EXISTS products (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        description TEXT NOT NULL,
        price VARCHAR(50) NOT NULL,
        original_price VARCHAR(50),
        image_url TEXT,
        seller_id INT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    await this.connection.execute(`
      CREATE TABLE IF NOT EXISTS orders (
        id INT AUTO_INCREMENT PRIMARY KEY,
        customer_name VARCHAR(255) NOT NULL,
        total DECIMAL(10,2) NOT NULL,
        status VARCHAR(50) DEFAULT 'pending',
        order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        seller_id INT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
  }

  /**
   * Find all records of the specified type
   *
   * @function findAll
   * @param {string} tableName - The name of the table/collection to query
   * @returns {Promise<any[]>} A promise that resolves to an array of records
   */
  async findAll(tableName: string): Promise<any[]> {
    if (!this.connection) {
      throw new Error("Database not connected");
    }

    const [rows] = (await this.connection.execute(
      `SELECT * FROM ${tableName}`,
    )) as [any[], any];

    return rows;
  }

  /**
   * Find a record by its ID
   *
   * @function findById
   * @param {string} tableName - The name of the table/collection to query
   * @param {number | string} id - The ID of the record to find
   * @returns {Promise<any | null>} A promise that resolves to the record or null if not found
   */
  async findById(tableName: string, id: number | string): Promise<any | null> {
    if (!this.connection) {
      throw new Error("Database not connected");
    }

    const [rows] = (await this.connection.execute(
      `SELECT * FROM ${tableName} WHERE id = ?`,
      [id],
    )) as [any[], any];

    return rows.length > 0 ? rows[0] : null;
  }

  /**
   * Create a new record
   *
   * @function create
   * @param {string} tableName - The name of the table/collection to insert into
   * @param {any} data - The data to insert
   * @returns {Promise<any>} A promise that resolves to the created record
   */
  async create(tableName: string, data: any): Promise<any> {
    if (!this.connection) {
      throw new Error("Database not connected");
    }

    // Build the query dynamically
    const columns = Object.keys(data);
    const placeholders = columns.map(() => "?").join(", ");
    const values = Object.values(data);

    const query = `INSERT INTO ${tableName} (${columns.join(", ")}) VALUES (${placeholders})`;
    const [result] = (await this.connection.execute(query, values)) as [
      mysql.OkPacket,
      any,
    ];

    // Return the created record
    const newId = result.insertId;
    return this.findById(tableName, newId);
  }

  /**
   * Update an existing record by ID
   *
   * @function update
   * @param {string} tableName - The name of the table/collection to update
   * @param {number | string} id - The ID of the record to update
   * @param {any} data - The updated data
   * @returns {Promise<any | null>} A promise that resolves to the updated record or null if not found
   */
  async update(
    tableName: string,
    id: number | string,
    data: Partial<any>,
  ): Promise<any | null> {
    if (!this.connection) {
      throw new Error("Database not connected");
    }

    // Build the SET clause dynamically
    const columns = Object.keys(data);
    const setClause = columns.map((col) => `${col} = ?`).join(", ");
    const values = [...Object.values(data), id];

    const query = `UPDATE ${tableName} SET ${setClause} WHERE id = ?`;
    await this.connection.execute(query, values);

    // Return the updated record
    return this.findById(tableName, id);
  }

  /**
   * Delete a record by ID
   *
   * @function delete
   * @param {string} tableName - The name of the table/collection to delete from
   * @param {number | string} id - The ID of the record to delete
   * @returns {Promise<boolean>} A promise that resolves to true if the deletion was successful
   */
  async delete(tableName: string, id: number | string): Promise<boolean> {
    if (!this.connection) {
      throw new Error("Database not connected");
    }

    const [result] = (await this.connection.execute(
      `DELETE FROM ${tableName} WHERE id = ?`,
      [id],
    )) as [mysql.OkPacket, any];

    return result.affectedRows > 0;
  }

  /**
   * Find records matching specific criteria
   *
   * @function findBy
   * @param {string} tableName - The name of the table/collection to query
   * @param {Record<string, any>} criteria - The criteria to match against
   * @returns {Promise<any[]>} A promise that resolves to an array of matching records
   */
  async findBy(
    tableName: string,
    criteria: Record<string, any>,
  ): Promise<any[]> {
    if (!this.connection) {
      throw new Error("Database not connected");
    }

    const conditions = Object.keys(criteria);
    const whereClause = conditions.map((key) => `${key} = ?`).join(" AND ");
    const values = Object.values(criteria);

    const query = `SELECT * FROM ${tableName} WHERE ${whereClause}`;
    const [rows] = (await this.connection.execute(query, values)) as [
      any[],
      any,
    ];

    return rows;
  }

  /**
   * Find a single record matching specific criteria
   *
   * @function findOne
   * @param {string} tableName - The name of the table/collection to query
   * @param {Record<string, any>} criteria - The criteria to match against
   * @returns {Promise<any | null>} A promise that resolves to the first matching record or null
   */
  async findOne(
    tableName: string,
    criteria: Record<string, any>,
  ): Promise<any | null> {
    const results = await this.findBy(tableName, criteria);
    return results.length > 0 ? results[0] : null;
  }

  /**
   * Close the database connection
   *
   * @function close
   * @returns {Promise<void>} A promise that resolves when the connection is closed
   */
  async close(): Promise<void> {
    if (this.connection) {
      await this.connection.end();
      this.connection = null;
    }
  }
}
