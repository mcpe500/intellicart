/**
 * JSON Database Implementation
 *
 * This class implements the DatabaseInterface using JSON file storage.
 * It provides basic CRUD operations using JSON file as the storage medium.
 *
 * @class JSONDatabase
 * @implements {DatabaseInterface<any>}
 * @description JSON file-based database implementation
 * @author Intellicart Team
 * @version 1.0.0
 */

import { DatabaseInterface } from "../../DatabaseInterface";
import * as fs from "fs/promises";
import * as path from "path";

export class JSONDatabase implements DatabaseInterface<any> {
  private dataPath: string;
  private data: Record<string, any[]>;

  /**
   * Constructor for JSONDatabase
   *
   * @param {string} dataPath - Path to the JSON data file
   */
  constructor(dataPath: string) {
    this.dataPath = dataPath;
    this.data = {};
  }

  /**
   * Initialize the database by reading the JSON file
   *
   * @function init
   * @returns {Promise<void>} A promise that resolves when initialization is complete
   */
  async init(): Promise<void> {
    try {
      // Ensure directory exists
      const dir = path.dirname(this.dataPath);
      await fs.mkdir(dir, { recursive: true });

      // Check if file exists
      try {
        await fs.access(this.dataPath);
        // File exists, read its content
        const fileContent = await fs.readFile(this.dataPath, "utf-8");
        this.data = fileContent ? JSON.parse(fileContent) : {};
      } catch (error) {
        // File doesn't exist, create it with empty data
        this.data = {};
        await this.saveData();
      }
    } catch (error) {
      console.error(`Error initializing JSON database: ${error}`);
      throw error;
    }
  }

  /**
   * Save the current data to the JSON file
   *
   * @private
   * @function saveData
   * @returns {Promise<void>} A promise that resolves when the data is saved
   */
  private async saveData(): Promise<void> {
    try {
      await fs.writeFile(this.dataPath, JSON.stringify(this.data, null, 2));
    } catch (error) {
      console.error(`Error saving JSON data: ${error}`);
      throw error;
    }
  }

  /**
   * Clear all data from a specific table (collection).
   * @param tableName The name of the table to clear.
   */
  async clearTable(tableName: string): Promise<void> {
    if (this.data[tableName]) {
      this.data[tableName] = [];
      console.log(`[INFO] Cleared table: ${tableName}`); // Add log
      await this.saveData();
    }
  }

  // Add a method to clear ALL data if needed, useful for seeding
  async clearAllData(): Promise<void> {
    console.log("[INFO] Clearing all data from JSON database..."); // Add log
    this.data = {}; // Reset the entire data object
    await this.saveData();
  }

  /**
   * Find all records of the specified type
   *
   * @function findAll
   * @param {string} tableName - The name of the table/collection to query
   * @returns {Promise<any[]>} A promise that resolves to an array of records
   */
  async findAll(tableName: string): Promise<any[]> {
    return this.data[tableName] || [];
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
    const table = this.data[tableName] || [];
    const records = table.filter((item) => item.id == id); // Find ALL matching records

    if (records.length > 1) {
      console.warn(
        `[WARN] Duplicate ID found for id ${id} in table ${tableName}. Returning the first one.`,
      );
    }

    return records.length > 0 ? records[0] : null; // Return the first match or null
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
    if (!this.data[tableName]) {
      this.data[tableName] = [];
    }

    let newId: number | string;
    if (data.id) {
      // If ID is provided, check for duplicates
      const existing = await this.findById(tableName, data.id);
      if (existing) {
        console.error(
          `[ERROR] Attempted to create record with duplicate ID ${data.id} in table ${tableName}.`,
        );
        throw new Error(
          `Record with ID ${data.id} already exists in ${tableName}.`,
        );
      }
      newId = data.id;
    } else {
      // Generate a new ID if not provided
      newId = this.generateId(tableName);
    }

    const record = { ...data, id: newId };
    this.data[tableName].push(record);
    await this.saveData();
    return record;
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
    const table = this.data[tableName] || [];
    const index = table.findIndex((item) => item.id == id); // Using == to match both string and number IDs

    if (index === -1) {
      return null;
    }

    // Update the record
    table[index] = { ...table[index], ...data };
    await this.saveData();
    return table[index];
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
    const table = this.data[tableName] || [];
    const initialLength = table.length;

    const filteredTable = table.filter((item) => item.id != id); // Using != to match both string and number IDs

    if (filteredTable.length === initialLength) {
      return false; // No record was deleted
    }

    this.data[tableName] = filteredTable;
    await this.saveData();
    return true;
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
    const table = this.data[tableName] || [];
    return table.filter((item) => {
      return Object.keys(criteria).every(
        (key) =>
          item[key] === criteria[key] ||
          (typeof criteria[key] === "string" &&
            typeof item[key] === "string" &&
            item[key].toLowerCase().includes(criteria[key].toLowerCase())),
      );
    });
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
    const records = await this.findBy(tableName, criteria);
    return records.length > 0 ? records[0] : null;
  }

  /**
   * Close the database connection (not needed for JSON implementation)
   *
   * @function close
   * @returns {Promise<void>} A promise that resolves when the connection is closed
   */
  async close(): Promise<void> {
    // For JSON implementation, we just ensure data is saved
    await this.saveData();
  }

  /**
   * Generate a unique ID for new records
   *
   * @private
   * @function generateId
   * @returns {number} A unique ID
   */
  private generateId(tableName: string): number {
    const table = this.data[tableName] || [];
    const maxId = Math.max(0, ...table.map((item) => parseInt(item.id) || 0));
    return maxId + 1;
  }
}
