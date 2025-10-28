import { BaseService } from "./BaseService";
import { logger } from "../utils/logger";
import { User, CreateUserRequest, UpdateUserRequest } from "../models/UserDTO";
import { ConflictError, NotFoundError, ValidationError } from "../types/errors";

export class UserService extends BaseService<User> {
  constructor() {
    super("users");
  }

  async createUser(userData: CreateUserRequest): Promise<User> {
    // Validate required fields
    if (!userData.email || !userData.name || !userData.password) {
      throw new ValidationError("Email, name, and password are required");
    }

    const existingUser = await this.db.findOne("users", {
      email: userData.email,
    });
    if (existingUser) {
      logger.warn("Attempt to create user with existing email", {
        email: userData.email,
      });
      throw new ConflictError("User with this email already exists");
    }

    logger.info("Creating new user", { email: userData.email });
    return await this.create(userData as User);
  }

  async updateUser(id: number, userData: UpdateUserRequest): Promise<User> {
    const existingUser = await this.getById(id);
    if (!existingUser) {
      logger.warn("Attempt to update non-existent user", { id });
      throw new NotFoundError("User not found", { userId: id });
    }

    // Check if email is being updated and already exists for another user
    if (userData.email && userData.email !== existingUser.email) {
      const duplicateUser = await this.db.findOne("users", {
        email: userData.email,
      });
      if (duplicateUser) {
        logger.warn("Attempt to update user with existing email", {
          email: userData.email,
          userId: id,
        });
        throw new ConflictError("User with this email already exists");
      }
    }

    logger.info("Updating user", { id, updatedFields: Object.keys(userData) });
    const updatedUser = await this.update(id, userData);

    if (!updatedUser) {
      throw new NotFoundError("User not found after update", { userId: id });
    }

    return updatedUser;
  }

  async getUserByEmail(email: string): Promise<User | null> {
    if (!email) {
      throw new ValidationError("Email is required");
    }

    return await this.db.findOne("users", { email });
  }
}
