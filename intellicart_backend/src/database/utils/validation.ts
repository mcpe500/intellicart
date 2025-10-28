/**
 * Database Validation Utility Module
 *
 * This module provides functions for validating and sanitizing database inputs
 * to prevent SQL injection and other database-related security vulnerabilities.
 *
 * @module databaseValidation
 * @description Utility for database input validation and sanitization
 * @author Intellicart Team
 * @version 1.0.0
 */

/**
 * Validates that a table name is safe to use in database queries
 *
 * @param tableName - The table name to validate
 * @returns True if the table name is valid, false otherwise
 */
export function validateTableName(tableName: string): boolean {
  if (typeof tableName !== "string") {
    return false;
  }

  // Only allow alphanumeric characters and underscores, and no SQL keywords
  const validNameRegex = /^[a-zA-Z_][a-zA-Z0-9_]*$/;
  const sqlKeywords = [
    "SELECT",
    "INSERT",
    "UPDATE",
    "DELETE",
    "DROP",
    "CREATE",
    "ALTER",
    "TABLE",
    "DATABASE",
    "INDEX",
    "WHERE",
    "FROM",
    "JOIN",
    "UNION",
  ];

  const upperName = tableName.toUpperCase();

  // Check if it matches the allowed pattern and doesn't contain SQL keywords
  return validNameRegex.test(tableName) && !sqlKeywords.includes(upperName);
}

/**
 * Validates that an ID is a safe integer
 *
 * @param id - The ID to validate (can be number or string)
 * @returns True if the ID is valid, false otherwise
 */
export function validateId(id: number | string): boolean {
  if (typeof id === "string") {
    // If it's a string, it should be a numeric string
    const numericId = Number(id);
    return Number.isSafeInteger(numericId) && numericId > 0;
  }

  // If it's a number, it should be a safe integer
  return Number.isSafeInteger(id) && id > 0;
}

/**
 * Validates that query parameters are safe to use
 *
 * @param params - The parameters to validate
 * @returns True if all parameters are valid, false otherwise
 */
export function validateQueryParams(params: Record<string, any>): boolean {
  if (!params || typeof params !== "object") {
    return false;
  }

  for (const [key, value] of Object.entries(params)) {
    // Validate key
    if (typeof key !== "string" || !/^[a-zA-Z_][a-zA-Z0-9_]*$/.test(key)) {
      return false;
    }

    // Validate value based on type
    if (value === null || value === undefined) {
      continue; // null/undefined values are allowed
    }

    if (typeof value === "string") {
      // Check for SQL injection patterns
      const sqlInjectionPatterns = [
        /('|;|--|\/\*|\*\/|xp_|sp_|exec|execute|select|insert|update|delete|drop|create|alter|grant|revoke|backup|restore|shutdown)/i,
      ];

      if (sqlInjectionPatterns.some((pattern) => pattern.test(value))) {
        return false;
      }
    } else if (typeof value === "object") {
      // Recursively validate object properties
      if (!validateQueryParams(value)) {
        return false;
      }
    }
    // Other types (number, boolean) are generally safe
  }

  return true;
}

/**
 * Sanitizes data for database storage
 *
 * @param data - The data to sanitize
 * @returns Sanitized data
 */
export function sanitizeForDatabase<T>(data: T): T {
  if (data === null || data === undefined) {
    return data;
  }

  if (typeof data === "string") {
    // Remove potentially dangerous SQL sequences
    return data
      .replace(/'/g, "''") // Escape single quotes
      .replace(/;/g, "") // Remove semicolons
      .replace(/--/g, "") // Remove SQL comments
      .replace(/\/\*/g, "") // Remove /* comments
      .replace(/\*\//g, "") // Remove */ comments
      .replace(
        /\b(ALTER|CREATE|DELETE|DROP|EXEC(UTE)?|INSERT|SELECT|UNION( ALL)?|UPDATE|TRUNCATE|USE)\b/gi,
        "",
      ) // Remove SQL keywords
      .trim() as unknown as T;
  }

  if (Array.isArray(data)) {
    return data.map((item) => sanitizeForDatabase(item)) as unknown as T;
  }

  if (typeof data === "object") {
    const sanitized: any = {};
    for (const [key, value] of Object.entries(data)) {
      // Sanitize keys too, though this is more restrictive
      const sanitizedKey = key
        .replace(/[^a-zA-Z0-9_]/g, "") // Only allow safe characters
        .replace(/^\d/, "_"); // Don't allow keys starting with numbers
      sanitized[sanitizedKey] = sanitizeForDatabase(value);
    }
    return sanitized as T;
  }

  // Numbers, booleans, and other types are generally safe
  return data;
}

/**
 * Validates an entire data object before database operations
 *
 * @param data - The data object to validate
 * @param allowedFields - Optional array of allowed field names
 * @returns True if the data is valid, false otherwise
 */
export function validateDataForDB<T extends Record<string, any>>(
  data: T,
  allowedFields?: string[],
): boolean {
  if (!data || typeof data !== "object") {
    return false;
  }

  for (const [key, value] of Object.entries(data)) {
    // Check if field is allowed if restricted fields are specified
    if (allowedFields && !allowedFields.includes(key)) {
      return false;
    }

    // Validate key format
    if (typeof key !== "string" || !/^[a-zA-Z_][a-zA-Z0-9_]*$/.test(key)) {
      return false;
    }

    // Validate value
    if (typeof value === "string") {
      // Check for SQL injection patterns in string values
      const sqlInjectionPatterns = [
        /('|;|--|\/\*|\*\/|xp_|sp_|exec|execute|select|insert|update|delete|drop|create|alter|grant|revoke|backup|restore|shutdown)/i,
      ];

      if (sqlInjectionPatterns.some((pattern) => pattern.test(value))) {
        return false;
      }
    } else if (
      value !== null &&
      typeof value === "object" &&
      !Array.isArray(value)
    ) {
      // Recursively validate nested objects
      if (!validateDataForDB(value, allowedFields)) {
        return false;
      }
    }
  }

  return true;
}
