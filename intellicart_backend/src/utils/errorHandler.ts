import { Context } from 'hono';
import { Logger } from './logger';

export class AppError extends Error {
  constructor(
    public statusCode: number, // We'll use number and cast as needed
    public message: string,
    public isOperational = true
  ) {
    super(message);
    Object.setPrototypeOf(this, AppError.prototype);
  }
}

export const handleError = (error: Error | AppError, c: Context) => {
  if (error instanceof AppError) {
    Logger.warn('Operational error:', { message: error.message, statusCode: error.statusCode });
    return c.json({ error: error.message }, error.statusCode as any);
  }

  Logger.error('Unexpected error:', { error: error.message, stack: error.stack });
  return c.json({ error: 'Internal server error' }, 500);
};

export const asyncHandler = (fn: Function) => {
  return async (c: Context, next?: Function) => {
    try {
      return await fn(c, next);
    } catch (error) {
      return handleError(error as Error, c);
    }
  };
};
