import { describe, it, expect, beforeEach, vi } from "bun:test";
import { UserController } from "../../../src/controllers/UserController";
import { Context } from "hono";
import { dbManager } from "../../../src/database/Config";

// Mock the database methods
const mockDatabaseMethods = {
  findAll: vi.fn(),
  findById: vi.fn(),
  create: vi.fn(),
  update: vi.fn(),
  delete: vi.fn(),
  findOne: vi.fn(),
};

const userController = new UserController();

// Keep a reference to the original getDatabase function to mock it
const originalGetDatabase = dbManager.getDatabase;

describe("UserController", () => {
  let mockContext: Context;

  beforeEach(() => {
    // Reset all mocks
    vi.clearAllMocks();

    // Setup mock context
    mockContext = {
      req: {
        param: vi.fn(),
        valid: vi.fn(),
        json: vi.fn(), // Add the missing json method
      },
      json: vi.fn(),
    } as unknown as Context;

    // Mock the database
    vi.spyOn(dbManager, "getDatabase").mockReturnValue(
      mockDatabaseMethods as any,
    );
  });

  describe("getAllUsers", () => {
    it("should return all users successfully", async () => {
      // Arrange
      const mockUsers = [
        {
          id: 1,
          name: "John Doe",
          email: "john@example.com",
          createdAt: "2023-01-01T00:00:00.000Z",
        },
        {
          id: 2,
          name: "Jane Smith",
          email: "jane@example.com",
          createdAt: "2023-01-02T00:00:00.000Z",
        },
      ];

      mockDatabaseMethods.findAll.mockResolvedValue(mockUsers);

      // Act
      await userController.getAll(mockContext);

      // Assert
      expect(mockDatabaseMethods.findAll).toHaveBeenCalledWith("users");
      expect(mockContext.json).toHaveBeenCalledWith(mockUsers);
    });

    it("should return 500 if there is an error retrieving users", async () => {
      // Arrange
      mockDatabaseMethods.findAll.mockRejectedValue(
        new Error("Database error"),
      );

      // Act
      await userController.getAll(mockContext);

      // Assert
      expect(mockContext.json).toHaveBeenCalledWith(
        { error: "Internal server error" },
        500,
      );
    });
  });

  describe("getUserById", () => {
    it("should return user by ID successfully", async () => {
      // Arrange
      const mockUser = {
        id: 1,
        name: "John Doe",
        email: "john@example.com",
        age: 30,
        createdAt: "2023-01-01T00:00:00.000Z",
      };

      (mockContext.req.param as any).mockReturnValue("1");
      mockDatabaseMethods.findById.mockResolvedValue(mockUser);

      // Act
      await userController.getById(mockContext);

      // Assert
      expect(mockContext.req.param).toHaveBeenCalledWith("id");
      expect(mockDatabaseMethods.findById).toHaveBeenCalledWith("users", 1);
      expect(mockContext.json).toHaveBeenCalledWith(mockUser);
    });

    it("should return 404 if user is not found", async () => {
      // Arrange
      (mockContext.req.param as any).mockReturnValue("999");
      mockDatabaseMethods.findById.mockResolvedValue(null);

      // Act
      await userController.getById(mockContext);

      // Assert
      expect(mockContext.json).toHaveBeenCalledWith(
        { error: "user not found" },
        404,
      );
    });

    it("should return 500 if there is an error retrieving user", async () => {
      // Arrange
      (mockContext.req.param as any).mockReturnValue("1");
      mockDatabaseMethods.findById.mockRejectedValue(
        new Error("Database error"),
      );

      // Act
      await userController.getById(mockContext);

      // Assert
      expect(mockContext.json).toHaveBeenCalledWith(
        { error: "Internal server error" },
        500,
      );
    });
  });

  describe("createUser", () => {
    it("should create a new user successfully", async () => {
      // Arrange
      const mockReqBody = {
        name: "John Doe",
        email: "john@example.com",
        age: 30,
      };

      const mockCreatedUser = {
        id: 1,
        name: "John Doe",
        email: "john@example.com",
        age: 30,
        createdAt: "2023-01-01T00:00:00.000Z",
      };

      (mockContext.req.json as any).mockResolvedValue(mockReqBody);
      mockDatabaseMethods.findOne.mockResolvedValue(null); // No existing user with same email
      mockDatabaseMethods.create.mockResolvedValue(mockCreatedUser);

      // Act
      await userController.createUser(mockContext);

      // Assert
      expect(mockDatabaseMethods.findOne).toHaveBeenCalledWith("users", {
        email: "john@example.com",
      });
      expect(mockDatabaseMethods.create).toHaveBeenCalledWith("users", {
        name: "John Doe",
        email: "john@example.com",
        age: 30,
        createdAt: expect.any(String),
      });
      expect(mockContext.json).toHaveBeenCalledWith(mockCreatedUser, 201);
    });

    it("should return 409 if user with same email already exists", async () => {
      // Arrange
      const mockReqBody = {
        name: "John Doe",
        email: "john@example.com",
        age: 30,
      };

      (mockContext.req.json as any).mockResolvedValue(mockReqBody);
      mockDatabaseMethods.findOne.mockResolvedValue({
        id: 1,
        email: "john@example.com",
      }); // Existing user

      // Act
      await userController.createUser(mockContext);

      // Assert
      expect(mockContext.json).toHaveBeenCalledWith(
        { error: "User with this email already exists" },
        409,
      );
    });

    it("should return 500 if there is an error creating user", async () => {
      // Arrange
      const mockReqBody = {
        name: "John Doe",
        email: "john@example.com",
        age: 30,
      };

      (mockContext.req.json as any).mockResolvedValue(mockReqBody);
      mockDatabaseMethods.findOne.mockResolvedValue(null);
      mockDatabaseMethods.create.mockRejectedValue(new Error("Database error"));

      // Act
      await userController.createUser(mockContext);

      // Assert
      expect(mockContext.json).toHaveBeenCalledWith(
        { error: "Internal server error" },
        500,
      );
    });
  });

  describe("updateUser", () => {
    it("should update user successfully", async () => {
      // Arrange
      const mockReqBody = {
        name: "John Doe Updated",
        age: 31,
      };

      const mockExistingUser = {
        id: 1,
        name: "John Doe",
        email: "john@example.com",
        age: 30,
        createdAt: "2023-01-01T00:00:00.000Z",
      };

      const mockUpdatedUser = {
        id: 1,
        name: "John Doe Updated",
        email: "john@example.com",
        age: 31,
        createdAt: "2023-01-01T00:00:00.000Z",
      };

      (mockContext.req.param as any).mockReturnValue("1");
      (mockContext.req.json as any).mockResolvedValue(mockReqBody);
      mockDatabaseMethods.findById.mockResolvedValue(mockExistingUser);
      mockDatabaseMethods.update.mockResolvedValue(mockUpdatedUser);

      // Act
      await userController.updateUser(mockContext);

      // Assert
      expect(mockDatabaseMethods.findById).toHaveBeenCalledWith("users", 1);
      expect(mockDatabaseMethods.update).toHaveBeenCalledWith("users", 1, {
        name: "John Doe Updated",
        age: 31,
      });
      expect(mockContext.json).toHaveBeenCalledWith(mockUpdatedUser);
    });

    it("should return 404 if user to update does not exist", async () => {
      // Arrange
      (mockContext.req.param as any).mockReturnValue("999");
      mockDatabaseMethods.findById.mockResolvedValue(null);

      // Act
      await userController.updateUser(mockContext);

      // Assert
      expect(mockContext.json).toHaveBeenCalledWith(
        { error: "User not found" },
        404,
      );
    });

    it("should return 409 if updating email to an already existing email", async () => {
      // Arrange
      const mockReqBody = {
        email: "existing@example.com",
        name: "New Name",
      };

      const mockExistingUser = {
        id: 1,
        name: "Old Name",
        email: "old@example.com",
        age: 30,
        createdAt: "2023-01-01T00:00:00.000Z",
      };

      (mockContext.req.param as any).mockReturnValue("1");
      (mockContext.req.json as any).mockResolvedValue(mockReqBody);
      mockDatabaseMethods.findById.mockResolvedValue(mockExistingUser);
      mockDatabaseMethods.findOne.mockResolvedValue({
        id: 2,
        email: "existing@example.com",
      }); // Another user with same email

      // Act
      await userController.updateUser(mockContext);

      // Assert
      expect(mockContext.json).toHaveBeenCalledWith(
        { error: "User with this email already exists" },
        409,
      );
    });

    it("should return 500 if there is an error updating user", async () => {
      // Arrange
      const mockReqBody = {
        name: "John Doe Updated",
      };

      const mockExistingUser = {
        id: 1,
        name: "John Doe",
        email: "john@example.com",
        age: 30,
        createdAt: "2023-01-01T00:00:00.000Z",
      };

      (mockContext.req.param as any).mockReturnValue("1");
      (mockContext.req.json as any).mockResolvedValue(mockReqBody);
      mockDatabaseMethods.findById.mockResolvedValue(mockExistingUser);
      mockDatabaseMethods.update.mockRejectedValue(new Error("Database error"));

      // Act
      await userController.updateUser(mockContext);

      // Assert
      expect(mockContext.json).toHaveBeenCalledWith(
        { error: "Internal server error" },
        500,
      );
    });
  });

  describe("deleteUser", () => {
    it("should delete user successfully", async () => {
      // Arrange
      const mockUser = {
        id: 1,
        name: "John Doe",
        email: "john@example.com",
        age: 30,
        createdAt: "2023-01-01T00:00:00.000Z",
      };

      (mockContext.req.param as any).mockReturnValue("1");
      mockDatabaseMethods.findById.mockResolvedValue(mockUser);
      mockDatabaseMethods.delete.mockResolvedValue(true);

      // Act
      await userController.delete(mockContext);

      // Assert
      expect(mockDatabaseMethods.findById).toHaveBeenCalledWith("users", 1);
      expect(mockDatabaseMethods.delete).toHaveBeenCalledWith("users", 1);
      expect(mockContext.json).toHaveBeenCalledWith({
        message: "user deleted successfully",
        item: mockUser,
      });
    });

    it("should return 404 if user to delete does not exist", async () => {
      // Arrange
      (mockContext.req.param as any).mockReturnValue("999");
      mockDatabaseMethods.findById.mockResolvedValue(null);

      // Act
      await userController.delete(mockContext);

      // Assert
      expect(mockContext.json).toHaveBeenCalledWith(
        { error: "user not found" },
        404,
      );
    });

    it("should return 500 if there is an error deleting user", async () => {
      // Arrange
      const mockUser = {
        id: 1,
        name: "John Doe",
        email: "john@example.com",
        age: 30,
        createdAt: "2023-01-01T00:00:00.000Z",
      };

      (mockContext.req.param as any).mockReturnValue("1");
      mockDatabaseMethods.findById.mockResolvedValue(mockUser);
      mockDatabaseMethods.delete.mockResolvedValue(false); // Failed to delete

      // Act
      await userController.delete(mockContext);

      // Assert
      expect(mockContext.json).toHaveBeenCalledWith(
        { error: "Failed to delete user" },
        500,
      );
    });
  });
});
