import { Context } from 'hono';

// Simple logger utility
export class Logger {
  static log(level: string, message: string, meta?: any) {
    const timestamp = new Date().toISOString();
    const logMessage = `[${timestamp}] ${level}: ${message}`;
    
    if (meta) {
      console.log(logMessage, meta);
    } else {
      console.log(logMessage);
    }
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
    if (process.env.NODE_ENV !== 'production') {
      this.log('DEBUG', message, meta);
    }
  }
}

// Middleware for request logging
export const requestLogger = async (c: Context, next: Function) => {
  const startTime = Date.now();
  const method = c.req.method;
  const url = c.req.url;
  
  Logger.info(`Incoming request: ${method} ${url}`);
  
  await next();
  
  const duration = Date.now() - startTime;
  Logger.info(`Request completed: ${method} ${url} - Status: ${c.res.status} - Duration: ${duration}ms`);
};