import { Context } from 'hono';
import { dbManager } from '../database/Config';
import { DatabaseInterface } from '../database/DatabaseInterface';
import { logger } from '../utils/logger';
import { NotFoundError, ValidationError, InternalServerError } from '../types/errors';

export class BaseController<T> {
  protected tableName: string;
  protected db: DatabaseInterface<T>;

  constructor(tableName: string) {
    this.tableName = tableName;
    this.db = dbManager.getDatabase<T>();
  }

  // Common error handling logic
  protected handleError(error: any, c: Context, message: string) {
    logger.error(message, { error: error.message, stack: error.stack });
    return c.json({ error: 'Internal server error' }, 500);
  }

  // Generic method to get all items
  async getAll(c: Context) {
    try {
      const items = await this.db.findAll(this.tableName);
      return c.json(items);
    } catch (error) {
      return this.handleError(error, c, `Error retrieving all ${this.tableName}`);
    }
  }

  // Generic method to get an item by ID
  async getById(c: Context) {
    try {
      const { id } = c.req.param('id');
      
      const item = await this.db.findById(this.tableName, id);

      if (!item) {
        throw new NotFoundError(`${this.tableName.slice(0, -1)} not found`, { id, tableName: this.tableName });
      }

      return c.json(item);
    } catch (error) {
      if (error instanceof ValidationError) {
        return c.json({ error: error.message }, 400);
      } else if (error instanceof NotFoundError) {
        return c.json({ error: error.message }, 404);
      }
      return this.handleError(error, c, `Error retrieving ${this.tableName.slice(0, -1)} by ID`);
    }
  }

  // Generic method to create a new item
  async create(c: Context, createData: Partial<T>) {
    try {
      const newItem = {
        ...createData,
        createdAt: new Date().toISOString(),
      };
      
      const createdItem = await this.db.create(this.tableName, newItem);
      return c.json(createdItem, 201);
    } catch (error) {
      if (error instanceof ValidationError) {
        return c.json({ error: error.message }, 400);
      }
      return this.handleError(error, c, `Error creating ${this.tableName.slice(0, -1)}`);
    }
  }

  // Generic method to update an item by ID
  async update(c: Context, updateData: Partial<T>) {
    try {
      const { id } = c.req.param('id');
      
      const item = await this.db.findById(this.tableName, id);

      if (!item) {
        throw new NotFoundError(`${this.tableName.slice(0, -1)} not found`, { id, tableName: this.tableName });
      }
      
      const updatedItem = await this.db.update(this.tableName, id, updateData);
      
      if (!updatedItem) {
        throw new InternalServerError('Failed to update item');
      }
      
      return c.json(updatedItem);
    } catch (error) {
      if (error instanceof ValidationError) {
        return c.json({ error: error.message }, 400);
      } else if (error instanceof NotFoundError) {
        return c.json({ error: error.message }, 404);
      }
      return this.handleError(error, c, `Error updating ${this.tableName.slice(0, -1)}`);
    }
  }

  // Generic method to delete an item by ID
  async delete(c: Context) {
    try {
      const { id } = c.req.param('id');
      
      const item = await this.db.findById(this.tableName, id);

      if (!item) {
        throw new NotFoundError(`${this.tableName.slice(0, -1)} not found`, { id, tableName: this.tableName });
      }
      
      const deleted = await this.db.delete(this.tableName, id);
      
      if (deleted) {
        return c.json({ message: `${this.tableName.slice(0, -1)} deleted successfully`, item });
      } else {
        throw new InternalServerError(`Failed to delete ${this.tableName.slice(0, -1)}`);
      }
    } catch (error) {
      if (error instanceof ValidationError) {
        return c.json({ error: error.message }, 400);
      } else if (error instanceof NotFoundError) {
        return c.json({ error: error.message }, 404);
      }
      return this.handleError(error, c, `Error deleting ${this.tableName.slice(0, -1)}`);
    }
  }
}