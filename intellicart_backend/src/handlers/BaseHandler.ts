
import { Context } from 'hono';
import { logger } from '../utils/logger';
import { AppError, InternalServerError } from '../types/errors';

export class BaseHandler {
  static async handle(handlerFunction: (c: Context) => Promise<any>, c: Context) {
    try {
      return await handlerFunction(c);
    } catch (error: any) {
      // Log the error with context
      if (error instanceof AppError) {
        logger.error('Application error in handler:', { 
          name: error.name,
          message: error.message, 
          stack: error.stack,
          statusCode: error.statusCode,
          context: error.context,
          url: c.req ? c.req.url : 'N/A',
          method: c.req ? c.req.method : 'N/A' 
        });
        
        // Return appropriate error response based on the custom error
        return c.json({ error: error.message, ...(error.context && { context: error.context }) }, error.statusCode as any);
      } else {
        // For non-application errors, log as internal server error
        logger.error('Unexpected error in handler:', { 
          error: error.message, 
          stack: error.stack,
          url: c.req ? c.req.url : 'N/A',
          method: c.req ? c.req.method : 'N/A' 
        });
        
        // Return generic internal server error to avoid exposing internal details
        return c.json({ error: 'Internal server error' }, 500);
      }
    }
  }
}
