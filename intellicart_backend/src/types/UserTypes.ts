/** 
 * User Types Definition
 */

export interface User {
  /** Unique identifier for the user */
  id: string;
  
  /** User's full name */
  name: string;
  
  /** User's email address */
  email: string;
  
  /** User's role: buyer or seller */
  role: string;
  
  /** User's phone number (optional) */
  phoneNumber?: string;
  
  /** Creation timestamp */
  createdAt: string;
}

/** 
 * Represents the data needed to create a new user
 */
export interface CreateUserInput {
  /** User's full name (required) */
  name: string;
  
  /** User's email address (required) */
  email: string;
  
  /** User's password (required) */
  password: string;
  
  /** User's role (optional, defaults to 'buyer') */
  role?: string;
}

/** 
 * Represents the data needed to update an existing user
 */
export interface UpdateUserInput {
  /** User's full name (optional, for updates) */
  name?: string;
  
  /** User's email address (optional, for updates) */
  email?: string;
  
  /** User's role (optional, for updates) */
  role?: string;
  
  /** User's phone number (optional, for updates) */
  phoneNumber?: string;
}

/** 
 * Response type for successful user deletion
 */
export interface DeleteUserResponse {
  /** Success message */
  message: string;
  
  /** The deleted user object */
  user: User;
}