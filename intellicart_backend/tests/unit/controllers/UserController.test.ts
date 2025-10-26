import { describe, it, expect, beforeEach, vi, MockedFunction } from 'bun:test';
import { UserController } from '../../../src/controllers/UserController';
import { Context } from 'hono';
import { dbManager } from '../../../src/database/Config';

// Mock dependencies
vi.mock('../../../src/database/Config', () => ({
  dbManager: {
    getDatabase: vi.fn()
  }
}));

describe('UserController', () => {
  let mockContext: Context;
  let mockDatabase: any;

  beforeEach(() => {
    // Reset all mocks
    vi.clearAllMocks();
    
    // Setup mock context
    mockContext = {
      req: {
        param: vi.fn(),
        valid: vi.fn(),
      },
      json: vi.fn(),
    } as unknown as Context;
    
    // Setup mock database
    mockDatabase = {
      findAll: vi.fn(),
      findById: vi.fn(),
      create: vi.fn(),
      update: vi.fn(),
      delete: vi.fn(),
      findOne: vi.fn(),
    };
    
    (dbManager.getDatabase as MockedFunction<any>).mockReturnValue(mockDatabase);
  });

  describe('getAllUsers', () => {
    it('should return all users successfully', async () => {
      // Arrange
      const mockUsers = [
        { id: 1, name: 'John Doe', email: 'john@example.com', createdAt: '2023-01-01T00:00:00.000Z' },
        { id: 2, name: 'Jane Smith', email: 'jane@example.com', createdAt: '2023-01-02T00:00:00.000Z' }
      ];
      
      mockDatabase.findAll.mockResolvedValue(mockUsers);
      
      // Act
      await UserController.getAllUsers(mockContext);
      
      // Assert
      expect(mockDatabase.findAll).toHaveBeenCalledWith('users');
      expect(mockContext.json).toHaveBeenCalledWith(mockUsers);
    });

    it('should return 500 if there is an error retrieving users', async () => {
      // Arrange
      mockDatabase.findAll.mockRejectedValue(new Error('Database error'));
      
      // Act
      await UserController.getAllUsers(mockContext);
      
      // Assert
      expect(mockContext.json).toHaveBeenCalledWith(
        { error: 'Internal server error' }, 
        500
      );
    });
  });

  describe('getUserById', () => {
    it('should return user by ID successfully', async () => {
      // Arrange
      const mockUser = { 
        id: 1, 
        name: 'John Doe', 
        email: 'john@example.com', 
        age: 30,
        createdAt: '2023-01-01T00:00:00.000Z' 
      };
      
      (mockContext.req.param as MockedFunction<any>).mockReturnValue('1');
      mockDatabase.findById.mockResolvedValue(mockUser);
      
      // Act
      await UserController.getUserById(mockContext);
      
      // Assert
      expect(mockContext.req.param).toHaveBeenCalledWith('id');
      expect(mockDatabase.findById).toHaveBeenCalledWith('users', 1);
      expect(mockContext.json).toHaveBeenCalledWith(mockUser);
    });

    it('should return 404 if user is not found', async () => {
      // Arrange
      (mockContext.req.param as MockedFunction<any>).mockReturnValue('999');
      mockDatabase.findById.mockResolvedValue(null);
      
      // Act
      await UserController.getUserById(mockContext);
      
      // Assert
      expect(mockContext.json).toHaveBeenCalledWith(
        { error: 'User not found' }, 
        404
      );
    });

    it('should return 500 if there is an error retrieving user', async () => {
      // Arrange
      (mockContext.req.param as MockedFunction<any>).mockReturnValue('1');
      mockDatabase.findById.mockRejectedValue(new Error('Database error'));
      
      // Act
      await UserController.getUserById(mockContext);
      
      // Assert
      expect(mockContext.json).toHaveBeenCalledWith(
        { error: 'Internal server error' }, 
        500
      );
    });
  });

  describe('createUser', () => {
    it('should create a new user successfully', async () => {
      // Arrange
      const mockReqBody = {
        name: 'John Doe',
        email: 'john@example.com',
        age: 30
      };
      
      const mockCreatedUser = {
        id: 1,
        name: 'John Doe',
        email: 'john@example.com',
        age: 30,
        createdAt: '2023-01-01T00:00:00.000Z'
      };
      
      (mockContext.req.valid as MockedFunction<any>).mockReturnValue(mockReqBody);
      mockDatabase.findOne.mockResolvedValue(null); // No existing user with same email
      mockDatabase.create.mockResolvedValue(mockCreatedUser);
      
      // Act
      await UserController.createUser(mockContext);
      
      // Assert
      expect(mockDatabase.findOne).toHaveBeenCalledWith('users', { email: 'john@example.com' });
      expect(mockDatabase.create).toHaveBeenCalledWith({
        name: 'John Doe',
        email: 'john@example.com',
        age: 30,
        createdAt: expect.any(String)
      });
      expect(mockContext.json).toHaveBeenCalledWith(mockCreatedUser, 201);
    });

    it('should return 409 if user with same email already exists', async () => {
      // Arrange
      const mockReqBody = {
        name: 'John Doe',
        email: 'john@example.com',
        age: 30
      };
      
      (mockContext.req.valid as MockedFunction<any>).mockReturnValue(mockReqBody);
      mockDatabase.findOne.mockResolvedValue({ id: 1, email: 'john@example.com' }); // Existing user
      
      // Act
      await UserController.createUser(mockContext);
      
      // Assert
      expect(mockContext.json).toHaveBeenCalledWith(
        { error: 'User with this email already exists' }, 
        409
      );
    });

    it('should return 500 if there is an error creating user', async () => {
      // Arrange
      const mockReqBody = {
        name: 'John Doe',
        email: 'john@example.com',
        age: 30
      };
      
      (mockContext.req.valid as MockedFunction<any>).mockReturnValue(mockReqBody);
      mockDatabase.findOne.mockResolvedValue(null);
      mockDatabase.create.mockRejectedValue(new Error('Database error'));
      
      // Act
      await UserController.createUser(mockContext);
      
      // Assert
      expect(mockContext.json).toHaveBeenCalledWith(
        { error: 'Internal server error' }, 
        500
      );
    });
  });

  describe('updateUser', () => {
    it('should update user successfully', async () => {
      // Arrange
      const mockReqBody = {
        name: 'John Doe Updated',
        age: 31
      };
      
      const mockExistingUser = {
        id: 1,
        name: 'John Doe',
        email: 'john@example.com',
        age: 30,
        createdAt: '2023-01-01T00:00:00.000Z'
      };
      
      const mockUpdatedUser = {
        id: 1,
        name: 'John Doe Updated',
        email: 'john@example.com',
        age: 31,
        createdAt: '2023-01-01T00:00:00.000Z'
      };
      
      (mockContext.req.param as MockedFunction<any>).mockReturnValue('1');
      (mockContext.req.valid as MockedFunction<any>).mockReturnValue(mockReqBody);
      mockDatabase.findById.mockResolvedValue(mockExistingUser);
      mockDatabase.update.mockResolvedValue(mockUpdatedUser);
      
      // Act
      await UserController.updateUser(mockContext);
      
      // Assert
      expect(mockDatabase.findById).toHaveBeenCalledWith('users', 1);
      expect(mockDatabase.update).toHaveBeenCalledWith('users', 1, { name: 'John Doe Updated', age: 31 });
      expect(mockContext.json).toHaveBeenCalledWith(mockUpdatedUser);
    });

    it('should return 404 if user to update does not exist', async () => {
      // Arrange
      (mockContext.req.param as MockedFunction<any>).mockReturnValue('999');
      mockDatabase.findById.mockResolvedValue(null);
      
      // Act
      await UserController.updateUser(mockContext);
      
      // Assert
      expect(mockContext.json).toHaveBeenCalledWith(
        { error: 'User not found' }, 
        404
      );
    });

    it('should return 409 if updating email to an already existing email', async () => {
      // Arrange
      const mockReqBody = {
        email: 'existing@example.com',
        name: 'New Name'
      };
      
      const mockExistingUser = {
        id: 1,
        name: 'Old Name',
        email: 'old@example.com',
        age: 30,
        createdAt: '2023-01-01T00:00:00.000Z'
      };
      
      (mockContext.req.param as MockedFunction<any>).mockReturnValue('1');
      (mockContext.req.valid as MockedFunction<any>).mockReturnValue(mockReqBody);
      mockDatabase.findById.mockResolvedValue(mockExistingUser);
      mockDatabase.findOne.mockResolvedValue({ id: 2, email: 'existing@example.com' }); // Another user with same email
      
      // Act
      await UserController.updateUser(mockContext);
      
      // Assert
      expect(mockContext.json).toHaveBeenCalledWith(
        { error: 'User with this email already exists' }, 
        409
      );
    });

    it('should return 500 if there is an error updating user', async () => {
      // Arrange
      const mockReqBody = {
        name: 'John Doe Updated'
      };
      
      const mockExistingUser = {
        id: 1,
        name: 'John Doe',
        email: 'john@example.com',
        age: 30,
        createdAt: '2023-01-01T00:00:00.000Z'
      };
      
      (mockContext.req.param as MockedFunction<any>).mockReturnValue('1');
      (mockContext.req.valid as MockedFunction<any>).mockReturnValue(mockReqBody);
      mockDatabase.findById.mockResolvedValue(mockExistingUser);
      mockDatabase.update.mockRejectedValue(new Error('Database error'));
      
      // Act
      await UserController.updateUser(mockContext);
      
      // Assert
      expect(mockContext.json).toHaveBeenCalledWith(
        { error: 'Internal server error' }, 
        500
      );
    });
  });

  describe('deleteUser', () => {
    it('should delete user successfully', async () => {
      // Arrange
      const mockUser = {
        id: 1,
        name: 'John Doe',
        email: 'john@example.com',
        age: 30,
        createdAt: '2023-01-01T00:00:00.000Z'
      };
      
      (mockContext.req.param as MockedFunction<any>).mockReturnValue('1');
      mockDatabase.findById.mockResolvedValue(mockUser);
      mockDatabase.delete.mockResolvedValue(true);
      
      // Act
      await UserController.deleteUser(mockContext);
      
      // Assert
      expect(mockDatabase.findById).toHaveBeenCalledWith('users', 1);
      expect(mockDatabase.delete).toHaveBeenCalledWith('users', 1);
      expect(mockContext.json).toHaveBeenCalledWith({
        message: 'User deleted successfully',
        user: mockUser
      });
    });

    it('should return 404 if user to delete does not exist', async () => {
      // Arrange
      (mockContext.req.param as MockedFunction<any>).mockReturnValue('999');
      mockDatabase.findById.mockResolvedValue(null);
      
      // Act
      await UserController.deleteUser(mockContext);
      
      // Assert
      expect(mockContext.json).toHaveBeenCalledWith(
        { error: 'User not found' }, 
        404
      );
    });

    it('should return 500 if there is an error deleting user', async () => {
      // Arrange
      const mockUser = {
        id: 1,
        name: 'John Doe',
        email: 'john@example.com',
        age: 30,
        createdAt: '2023-01-01T00:00:00.000Z'
      };
      
      (mockContext.req.param as MockedFunction<any>).mockReturnValue('1');
      mockDatabase.findById.mockResolvedValue(mockUser);
      mockDatabase.delete.mockResolvedValue(false); // Failed to delete
      
      // Act
      await UserController.deleteUser(mockContext);
      
      // Assert
      expect(mockContext.json).toHaveBeenCalledWith(
        { error: 'Failed to delete user' }, 
        500
      );
    });
  });
});