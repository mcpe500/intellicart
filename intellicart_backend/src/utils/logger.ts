/**
 * Logging Utility Module
 *
 * This module provides a structured logging system for the Intellicart API.
 * It includes different log levels (info, warn, error) and formats logs
 * with timestamps and context information.
 *
 * @module logger
 * @description Utility for structured logging
 * @author Intellicart Team
 * @version 1.0.0
 */

import fs from "fs";
import path from "path";

// Define log levels
export enum LogLevel {
  INFO = "INFO",
  WARN = "WARN",
  ERROR = "ERROR",
}

// Create logs directory if it doesn't exist
const logsDir = path.join(process.cwd(), "logs");
if (!fs.existsSync(logsDir)) {
  fs.mkdirSync(logsDir, { recursive: true });
}

// Log file path
const logFilePath = path.join(logsDir, "app.log");

/**
 * Format log message with timestamp and level
 *
 * @param level - Log level (INFO, WARN, ERROR)
 * @param message - Log message
 * @param context - Optional context information
 * @returns Formatted log string
 */
function formatLog(
  level: LogLevel,
  message: string,
  context?: Record<string, any>,
): string {
  const timestamp = new Date().toISOString();
  const formattedContext = context
    ? ` | Context: ${JSON.stringify(context)}`
    : "";
  return `[${timestamp}] [${level}] ${message}${formattedContext}\n`;
}

/**
 * Write log to console and file
 *
 * @param level - Log level
 * @param message - Log message
 * @param context - Optional context information
 */
function writeLog(
  level: LogLevel,
  message: string,
  context?: Record<string, any>,
): void {
  const logMessage = formatLog(level, message, context);

  // Write to console
  console.log(logMessage.trim());

  // Write to file
  fs.appendFileSync(logFilePath, logMessage);
}

/**
 * Log info message
 *
 * @param message - Info message
 * @param context - Optional context information
 */
export function logInfo(message: string, context?: Record<string, any>): void {
  writeLog(LogLevel.INFO, message, context);
}

/**
 * Log warning message
 *
 * @param message - Warning message
 * @param context - Optional context information
 */
export function logWarn(message: string, context?: Record<string, any>): void {
  writeLog(LogLevel.WARN, message, context);
}

/**
 * Log error message
 *
 * @param message - Error message
 * @param context - Optional context information
 */
export function logError(message: string, context?: Record<string, any>): void {
  writeLog(LogLevel.ERROR, message, context);
}

// Export logger object for convenience
export const logger = {
  info: logInfo,
  warn: logWarn,
  error: logError,
};
