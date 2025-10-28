import { dbManager } from "../database/Config";
import { DatabaseInterface } from "../database/DatabaseInterface";

export class BaseService<T> {
  protected tableName: string;
  protected db: DatabaseInterface<T>;

  constructor(tableName: string) {
    this.tableName = tableName;
    this.db = dbManager.getDatabase<T>();
  }

  async getAll() {
    return await this.db.findAll(this.tableName);
  }

  async getById(id: number) {
    return await this.db.findById(this.tableName, id);
  }

  async create(data: Partial<T>) {
    const newItem = {
      ...data,
      createdAt: new Date().toISOString(),
    };
    return await this.db.create(this.tableName, newItem as T);
  }

  async update(id: number, data: Partial<T>) {
    return await this.db.update(this.tableName, id, data);
  }

  async delete(id: number) {
    return await this.db.delete(this.tableName, id);
  }
}
