import { z } from 'zod';
import { Context } from 'hono';
import { Logger } from './logger';

export const validateRequest = async <T>(
  c: Context,
  schema: z.ZodSchema<T>
): Promise<{ success: true; data: T } | { success: false; error: any }> => {
  try {
    const body = await c.req.json();
    const validatedData = schema.parse(body);
    return { success: true, data: validatedData };
  } catch (error) {
    if (error instanceof z.ZodError) {
      Logger.warn('Validation error:', { errors: error.errors });
      return { success: false, error: error.errors };
    }
    Logger.error('Unexpected validation error:', { error: (error as Error).message });
    return { success: false, error: 'Invalid request data' };
  }
};
