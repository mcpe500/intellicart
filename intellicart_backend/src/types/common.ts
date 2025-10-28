/**
 * Common Type Definitions Module
 *
 * This module defines common types used throughout the Intellicart API application.
 * These types provide type safety and clear structure for various components
 * across the application.
 *
 * @module CommonTypes
 * @description Common type definitions for the Intellicart API
 * @author Intellicart Team
 * @version 1.0.0
 */

// Pagination interface
export interface Pagination {
  page: number;
  limit: number;
  total: number;
  totalPages: number;
}

// API Response interface
export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  message?: string;
  error?: string;
  pagination?: Pagination;
}

// Database configuration type
export interface DatabaseConfig {
  type: "json" | "sqlite" | "mysql" | "firebase";
  path?: string;
  host?: string;
  port?: number;
  username?: string;
  password?: string;
  database?: string;
  firebaseConfig?: any;
}

// User context type (for authentication middleware)
export interface UserContext {
  userId: number;
  email: string;
  role?: string;
}

// Request context extension for Hono
export interface ContextVariables {
  user: UserContext;
}

// Generic response type
export interface SuccessResponse<T> {
  success: true;
  data: T;
  message?: string;
}

export interface ErrorResponse {
  success: false;
  error: string;
  message?: string;
}

// API status type
export type APIResponse<T = any> = SuccessResponse<T> | ErrorResponse;

// Sort order type
export type SortOrder = "asc" | "desc";

// Sort options interface
export interface SortOptions {
  field: string;
  order: SortOrder;
}

// Filter options interface
export interface FilterOptions {
  [key: string]: any;
}

// Query options interface
export interface QueryOptions {
  filters?: FilterOptions;
  sort?: SortOptions;
  pagination?: Pagination;
}

// JWT payload type
export interface JWTPayload {
  userId: number;
  email: string;
  iat?: number;
  exp?: number;
}

// Token record type
export interface TokenRecord {
  id: number;
  token: string;
  userId: number;
  email: string;
  exp: number;
  createdAt: string;
}

// HTTP methods type
export type HttpMethod =
  | "GET"
  | "POST"
  | "PUT"
  | "DELETE"
  | "PATCH"
  | "HEAD"
  | "OPTIONS";

// Rate limit configuration type
export interface RateLimitConfig {
  windowMs: number;
  max: number;
  message?: string;
}

// Environment configuration type
export interface EnvironmentConfig {
  port: number;
  dbType: string;
  dbPath?: string;
  jwtSecret: string;
  nodeEnv: "development" | "production" | "test";
}
