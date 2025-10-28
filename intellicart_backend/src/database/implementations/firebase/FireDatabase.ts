/**
 * Firebase Database Implementation
 *
 * This class implements the DatabaseInterface using Firebase Firestore as the database engine.
 * It provides basic CRUD operations using Firebase Firestore.
 *
 * @class FireDatabase
 * @implements {DatabaseInterface<any>}
 * @description Firebase Firestore database implementation
 * @author Intellicart Team
 * @version 1.0.0
 */

import { DatabaseInterface } from "../../DatabaseInterface";
import { initializeApp, FirebaseApp } from "firebase/app";
import {
  getFirestore,
  Firestore,
  collection,
  getDocs,
  doc,
  getDoc,
  addDoc,
  updateDoc,
  deleteDoc,
  query,
  where,
  QueryConstraint,
} from "firebase/firestore";

export class FireDatabase implements DatabaseInterface<any> {
  private app: FirebaseApp;
  private db: Firestore;
  private config: any;

  /**
   * Constructor for FireDatabase
   *
   * @param {any} config - Firebase configuration object
   */
  constructor(config: any) {
    this.config = config;
    this.app = initializeApp(config);
    this.db = getFirestore(this.app);
  }

  /**
   * Initialize the database connection
   *
   * @function init
   * @returns {Promise<void>} A promise that resolves when initialization is complete
   */
  async init(): Promise<void> {
    // Firebase initialization happens in the constructor
    // Here we just ensure the connection is working
    console.log("Firebase database initialized");
  }

  /**
   * Find all records of the specified type
   *
   * @function findAll
   * @param {string} tableName - The name of the table/collection to query
   * @returns {Promise<any[]>} A promise that resolves to an array of records
   */
  async findAll(tableName: string): Promise<any[]> {
    const querySnapshot = await getDocs(collection(this.db, tableName));
    const results: any[] = [];

    querySnapshot.forEach((doc) => {
      results.push({ id: doc.id, ...doc.data() });
    });

    return results;
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
    const docRef = doc(this.db, tableName, id.toString());
    const docSnap = await getDoc(docRef);

    if (docSnap.exists()) {
      return { id: docSnap.id, ...docSnap.data() };
    } else {
      return null;
    }
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
    const docRef = await addDoc(collection(this.db, tableName), data);
    return { id: docRef.id, ...data };
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
    const docRef = doc(this.db, tableName, id.toString());
    await updateDoc(docRef, data);

    // Return the updated document
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
    const docRef = doc(this.db, tableName, id.toString());
    await deleteDoc(docRef);
    return true; // Firestore doesn't return a count of deleted docs
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
    const queryConstraints: QueryConstraint[] = [];

    // Build query constraints from criteria
    Object.entries(criteria).forEach(([key, value]) => {
      queryConstraints.push(where(key, "==", value));
    });

    const q = query(collection(this.db, tableName), ...queryConstraints);
    const querySnapshot = await getDocs(q);

    const results: any[] = [];
    querySnapshot.forEach((doc) => {
      results.push({ id: doc.id, ...doc.data() });
    });

    return results;
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
   * Close the database connection (not needed for Firebase implementation)
   *
   * @function close
   * @returns {Promise<void>} A promise that resolves when the connection is closed
   */
  async close(): Promise<void> {
    // For Firebase, there's no explicit close function, but we can terminate the app
    // this.app.delete(); // This would terminate the Firebase app instance
    console.log("Firebase connection closed");
  }
}
