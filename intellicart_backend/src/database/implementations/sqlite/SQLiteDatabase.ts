/**
 * SQLite Database Implementation
 *
 * This class implements the DatabaseInterface using SQLite as the database engine.
 * It provides basic CRUD operations using SQLite database.
 *
 * @class SQLiteDatabase
 * @implements {DatabaseInterface<any>}
 * @description SQLite database implementation
 * @author Intellicart Team
 * @version 1.0.0
 */

import { DatabaseInterface } from "../../DatabaseInterface";
import Database from "better-sqlite3";

export class SQLiteDatabase implements DatabaseInterface<any> {
  private db: Database.Database;
  private dbPath: string;

  /**
   * Constructor for SQLiteDatabase
   *
   * @param {string} dbPath - Path to the SQLite database file
   */
  constructor(dbPath: string) {
    this.dbPath = dbPath;
    this.db = new Database(dbPath);
  }

  /**
   * Initialize the database by creating tables if they don't exist
   *
   * @function init
   * @returns {Promise<void>} A promise that resolves when initialization is complete
   */
  async init(): Promise<void> {
    // Create tables if they don't exist
    // We'll create a generic structure that can be adapted for different entity types
    this.db.exec(`
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        role TEXT DEFAULT 'buyer',
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    `);

    this.db.exec(`
      CREATE TABLE IF NOT EXISTS products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        price TEXT NOT NULL,
        original_price TEXT,
        image_url TEXT,
        seller_id INTEGER,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    `);

    this.db.exec(`
      CREATE TABLE IF NOT EXISTS orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_name TEXT NOT NULL,
        total REAL NOT NULL,
        status TEXT DEFAULT 'pending',
        order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
        seller_id INTEGER,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
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
    const stmt = this.db.prepare(`SELECT * FROM ${tableName}`);
    return stmt.all() as any[];
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
    const stmt = this.db.prepare(`SELECT * FROM ${tableName} WHERE id = ?`);
    const result = stmt.get(id) as any;
    return result || null;
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
    // Get table columns to construct the query dynamically
    const columns = Object.keys(data).join(", ");
    const placeholders = Object.keys(data)
      .map(() => "?")
      .join(", ");

    const query = `INSERT INTO ${tableName} (${columns}) VALUES (${placeholders})`;
    const stmt = this.db.prepare(query);

    // Execute the query with values
    const values = Object.values(data);
    const result = stmt.run(values);

    // Get the inserted record
    const id = result.lastInsertRowid as number;
    return this.findById(tableName, id);
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
    // Create SET clause dynamically
    const setClause = Object.keys(data)
      .map((key) => `${key} = ?`)
      .join(", ");
    const values = [...Object.values(data), id];

    const query = `UPDATE ${tableName} SET ${setClause} WHERE id = ?`;
    const stmt = this.db.prepare(query);

    // Execute the update
    stmt.run(values);

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
    const stmt = this.db.prepare(`DELETE FROM ${tableName} WHERE id = ?`);
    const result = stmt.run(id);
    return result.changes > 0;
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
    const conditions = Object.keys(criteria)
      .map((key) => `${key} = ?`)
      .join(" AND ");
    const values = Object.values(criteria);

    const query = `SELECT * FROM ${tableName} WHERE ${conditions}`;
    const stmt = this.db.prepare(query);

    return stmt.all(...values) as any[];
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
    const conditions = Object.keys(criteria)
      .map((key) => `${key} = ?`)
      .join(" AND ");
    const values = Object.values(criteria);

    const query = `SELECT * FROM ${tableName} WHERE ${conditions} LIMIT 1`;
    const stmt = this.db.prepare(query);

    const result = stmt.get(...values) as any;
    return result || null;
  }

  /**
   * Close the database connection
   *
   * @function close
   * @returns {Promise<void>} A promise that resolves when the connection is closed
   */
  async close(): Promise<void> {
    if (this.db) {
      this.db.close();
    }
  }
}
