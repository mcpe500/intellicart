/**
 * Input Sanitization Utility Module
 *
 * This module provides functions for sanitizing and validating input data
 * to prevent common security vulnerabilities like XSS and injection attacks.
 *
 * @module inputSanitization
 * @description Utility for input sanitization and validation
 * @author Intellicart Team
 * @version 1.0.0
 */

// Import DOMPurify for HTML sanitization (if available)
import DOMPurify from "isomorphic-dompurify";

/**
 * Sanitize a string input to prevent XSS attacks
 *
 * @param input - The input string to sanitize
 * @returns Sanitized string with potentially dangerous content removed
 */
export function sanitizeString(input: string): string {
  if (typeof input !== "string") {
    return "";
  }

  // Remove potentially dangerous characters/sequences
  let sanitized = input
    .replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, "") // Remove script tags
    .replace(/javascript:/gi, "") // Remove javascript: protocol
    .replace(/vbscript:/gi, "") // Remove vbscript: protocol
    .replace(/on\w+\s*=/gi, "") // Remove event handlers (onclick, onload, etc.)
    .replace(/<iframe\b[^<]*(?:(?!<\/iframe>)<[^<]*)*<\/iframe>/gi, "") // Remove iframe tags
    .replace(/<object\b[^<]*(?:(?!<\/object>)<[^<]*)*<\/object>/gi, "") // Remove object tags
    .replace(/<embed\b[^<]*(?:(?!<\/embed>)<[^<]*)*<\/embed>/gi, ""); // Remove embed tags

  // Use DOMPurify for additional sanitization
  try {
    sanitized = DOMPurify.sanitize(sanitized);
  } catch (error) {
    // If DOMPurify fails, fallback to basic sanitization
    console.warn(
      "DOMPurify sanitization failed, using basic sanitization",
      error,
    );
  }

  return sanitized.trim();
}

/**
 * Validate email format
 *
 * @param email - The email string to validate
 * @returns True if valid email format, false otherwise
 */
export function validateEmail(email: string): boolean {
  if (typeof email !== "string") {
    return false;
  }

  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
}

/**
 * Validate password strength
 *
 * @param password - The password string to validate
 * @returns True if strong password, false otherwise
 */
export function validatePassword(password: string): boolean {
  if (typeof password !== "string") {
    return false;
  }

  // At least 8 characters, one uppercase, one lowercase, one number
  const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{8,}$/;
  return passwordRegex.test(password);
}

/**
 * Sanitize user input object recursively
 *
 * @param obj - The input object to sanitize
 * @returns Sanitized object with potentially dangerous content removed
 */
export function sanitizeObject<T>(obj: T): T {
  if (obj === null || obj === undefined) {
    return obj;
  }

  if (typeof obj === "string") {
    return sanitizeString(obj) as unknown as T;
  }

  if (Array.isArray(obj)) {
    return obj.map((item) => sanitizeObject(item)) as unknown as T;
  }

  if (typeof obj === "object") {
    const sanitized: any = {};
    for (const [key, value] of Object.entries(obj)) {
      sanitized[key] = sanitizeObject(value);
    }
    return sanitized as T;
  }

  return obj;
}

/**
 * Validate a number is within safe integer bounds
 *
 * @param num - The number to validate
 * @returns True if valid safe integer, false otherwise
 */
export function validateNumber(num: number): boolean {
  if (typeof num !== "number" || isNaN(num) || !isFinite(num)) {
    return false;
  }

  return Number.isSafeInteger(num);
}

/**
 * Validate URL format
 *
 * @param url - The URL string to validate
 * @returns True if valid URL format, false otherwise
 */
export function validateURL(url: string): boolean {
  if (typeof url !== "string") {
    return false;
  }

  try {
    new URL(url);
    return true;
  } catch {
    return false;
  }
}
