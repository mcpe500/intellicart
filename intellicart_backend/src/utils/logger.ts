import { Context } from 'hono';
import fs from 'fs';
import path from 'path';

// Enhanced logger utility with verbosity levels, file support and dev mode
export class Logger {
  private static logFile: string | null = process.env.LOG_FILE || null;
  private static verbosity: string = process.env.LOG_VERBOSITY || process.env.LOG_TYPE || 'INFO';

  static log(level: string, message: string, meta?: any) {
    if (!this.shouldLog(level)) {
      return;
    }
    
    const timestamp = new Date().toISOString();
    const logMessage = `[${timestamp}] ${level}: ${message}`;
    
    if (meta) {
      console.log(logMessage, meta);
    } else {
      console.log(logMessage);
    }
    
    if (this.logFile) {
      const fullLog = `${logMessage} ${meta ? JSON.stringify(meta) : ''}\n`;
      fs.appendFileSync(this.logFile, fullLog);
    }
  }

  private static shouldLog(level: string): boolean {
    const logLevels = ['ERROR', 'WARN', 'INFO', 'DEBUG'];
    const verbosityLevel = this.verbosity.toUpperCase();
    
    // Define the order of log levels
    const levelOrder = {
      'ERROR': 0,
      'WARN': 1,
      'INFO': 2,
      'DEBUG': 3
    };
    
    // If verbosity is set to a level, log that level and all above it
    const verbosityIndex = levelOrder[verbosityLevel] ?? levelOrder['INFO']; // Default to INFO
    const messageIndex = levelOrder[level] ?? levelOrder['INFO'];
    
    return messageIndex <= verbosityIndex; // Lower index = higher priority
  }

  static info(message: string, meta?: any) {
    this.log('INFO', message, meta);
  }

  static warn(message: string, meta?: any) {
    this.log('WARN', message, meta);
  }

  static error(message: string, meta?: any) {
    this.log('ERROR', message, meta);
  }

  static debug(message: string, meta?: any) {
    this.log('DEBUG', message, meta);
  }
}

export const requestLogger = async (c: Context, next: Function) => {
  const startTime = Date.now();
  const method = c.req.method;
  const url = c.req.url;
  const verbosity = process.env.LOG_VERBOSITY || 'INFO';
  const ip = c.req.header('x-forwarded-for')?.split(',')[0].trim() || c.req.header('x-real-ip') || 'unknown';
  
  if (verbosity === 'DEBUG') {
    Logger.debug(`Incoming request: ${method} ${url}`, {
      method,
      url,
      ip,
      hasBody: ['POST', 'PUT', 'PATCH'].includes(method)
    });
  } else if (verbosity === 'INFO') {
    Logger.info(`Incoming request: ${method} ${url}`, { method, url, ip });
  }
  
  await next();
  
  const duration = Date.now() - startTime;
  
  if (c.error) {
    Logger.error(`Request failed: ${method} ${url}`, {
      status: c.res.status,
      duration: `${duration}ms`,
      error: c.error.message,
      stack: c.error.stack?.split('\n')[0],
      ip
    });
  } else if (verbosity === 'DEBUG') {
    Logger.debug(`Request completed: ${method} ${url}`, {
      status: c.res.status,
      duration: `${duration}ms`,
      ip
    });
  } else if (verbosity === 'INFO') {
    Logger.info(`Request completed: ${method} ${url} - Status: ${c.res.status} - Duration: ${duration}ms`);
  }
};