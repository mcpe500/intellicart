/**
 * User Data Transfer Object (DTO) Module
 * 
 * This module defines the data transfer objects for user-related operations.
 * These interfaces provide type safety and clear structure for user data
 * across the application.
 * 
 * @module UserDTO
 * @description DTOs for user data structures
 * @author Intellicart Team
 * @version 1.0.0
 */

// Interface for a User entity
export interface User {
  id: number;
  name: string;
  email: string;
  password?: string; // Password is optional since it may not be sent in responses
  role?: string; // 'buyer' or 'seller'
  age?: number;
  createdAt?: string;
}

// Interface for creating a new user (request)
export interface CreateUserRequest {
  name: string;
  email: string;
  password: string;
  age?: number;
  role?: string;
}

// Interface for updating a user (request)
export interface UpdateUserRequest {
  name?: string;
  email?: string;
  age?: number;
  role?: string;
}

// Interface for user authentication response
export interface AuthenticatedUserResponse {
  user: User;
  token: string;
}

// Interface for login request
export interface LoginRequest {
  email: string;
  password: string;
}

// Interface for registration request
export interface RegisterRequest extends CreateUserRequest {
  role?: string;
}