/**
 * Custom Error Classes Module
 *
 * This module defines custom error classes for better error handling
 * and categorization in the application.
 *
 * @module CustomErrors
 * @description Custom error classes for the Intellicart API
 * @author Intellicart Team
 * @version 1.0.0
 */

export class AppError extends Error {
  public statusCode: number;
  public isOperational: boolean;
  public context?: Record<string, any>;

  constructor(
    message: string,
    statusCode: number,
    context?: Record<string, any>,
  ) {
    super(message);
    this.statusCode = statusCode;
    this.isOperational = true;
    this.context = context;

    // Set the prototype explicitly to maintain proper inheritance
    Object.setPrototypeOf(this, AppError.prototype);
  }
}

export class ValidationError extends AppError {
  constructor(message: string, context?: Record<string, any>) {
    super(message, 400, context);
    this.name = "ValidationError";

    Object.setPrototypeOf(this, ValidationError.prototype);
  }
}

export class AuthenticationError extends AppError {
  constructor(
    message: string = "Authentication failed",
    context?: Record<string, any>,
  ) {
    super(message, 401, context);
    this.name = "AuthenticationError";

    Object.setPrototypeOf(this, AuthenticationError.prototype);
  }
}

export class AuthorizationError extends AppError {
  constructor(
    message: string = "Authorization failed",
    context?: Record<string, any>,
  ) {
    super(message, 403, context);
    this.name = "AuthorizationError";

    Object.setPrototypeOf(this, AuthorizationError.prototype);
  }
}

export class NotFoundError extends AppError {
  constructor(
    message: string = "Resource not found",
    context?: Record<string, any>,
  ) {
    super(message, 404, context);
    this.name = "NotFoundError";

    Object.setPrototypeOf(this, NotFoundError.prototype);
  }
}

export class ConflictError extends AppError {
  constructor(
    message: string = "Resource conflict",
    context?: Record<string, any>,
  ) {
    super(message, 409, context);
    this.name = "ConflictError";

    Object.setPrototypeOf(this, ConflictError.prototype);
  }
}

export class InternalServerError extends AppError {
  constructor(
    message: string = "Internal server error",
    context?: Record<string, any>,
  ) {
    super(message, 500, context);
    this.name = "InternalServerError";

    Object.setPrototypeOf(this, InternalServerError.prototype);
  }
}
