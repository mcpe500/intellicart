/**
 * Database Interface
 * 
 * This interface defines the common operations that all database implementations must support.
 * It provides a contract for database operations that can be implemented by different database systems
 * such as JSON file storage, SQLite, Firebase, or MySQL.
 * 
 * @interface DatabaseInterface
 * @description Common interface for database operations
 * @author Intellicart Team
 * @version 1.0.0
 */

export interface DatabaseInterface<T> {
  /**
   * Initialize the database connection/storage
   * 
   * @function init
   * @returns {Promise<void>} A promise that resolves when initialization is complete
   */
  init(): Promise<void>;

  /**
   * Find all records of the specified type
   * 
   * @function findAll
   * @param {string} tableName - The name of the table/collection to query
   * @returns {Promise<T[]>} A promise that resolves to an array of records
   */
  findAll(tableName: string): Promise<T[]>;

  /**
   * Find a record by its ID
   * 
   * @function findById
   * @param {string} tableName - The name of the table/collection to query
   * @param {number | string} id - The ID of the record to find
   * @returns {Promise<T | null>} A promise that resolves to the record or null if not found
   */
  findById(tableName: string, id: number | string): Promise<T | null>;

  /**
   * Create a new record
   * 
   * @function create
   * @param {string} tableName - The name of the table/collection to insert into
   * @param {T} data - The data to insert
   * @returns {Promise<T>} A promise that resolves to the created record
   */
  create(tableName: string, data: T): Promise<T>;

  /**
   * Update an existing record by ID
   * 
   * @function update
   * @param {string} tableName - The name of the table/collection to update
   * @param {number | string} id - The ID of the record to update
   * @param {T} data - The updated data
   * @returns {Promise<T | null>} A promise that resolves to the updated record or null if not found
   */
  update(tableName: string, id: number | string, data: Partial<T>): Promise<T | null>;

  /**
   * Delete a record by ID
   * 
   * @function delete
   * @param {string} tableName - The name of the table/collection to delete from
   * @param {number | string} id - The ID of the record to delete
   * @returns {Promise<boolean>} A promise that resolves to true if the deletion was successful
   */
  delete(tableName: string, id: number | string): Promise<boolean>;

  /**
   * Find records matching specific criteria
   * 
   * @function findBy
   * @param {string} tableName - The name of the table/collection to query
   * @param {Record<string, any>} criteria - The criteria to match against
   * @returns {Promise<T[]>} A promise that resolves to an array of matching records
   */
  findBy(tableName: string, criteria: Record<string, any>): Promise<T[]>;

  /**
   * Find a single record matching specific criteria
   * 
   * @function findOne
   * @param {string} tableName - The name of the table/collection to query
   * @param {Record<string, any>} criteria - The criteria to match against
   * @returns {Promise<T | null>} A promise that resolves to the first matching record or null
   */
  findOne(tableName: string, criteria: Record<string, any>): Promise<T | null>;

  /**
   * Close the database connection/storage
   * 
   * @function close
   * @returns {Promise<void>} A promise that resolves when the connection is closed
   */
  close(): Promise<void>;
}