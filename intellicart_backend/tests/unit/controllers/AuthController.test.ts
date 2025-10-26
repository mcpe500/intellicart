import { describe, it, expect, beforeEach, vi, MockedFunction } from 'bun:test';
import { AuthController } from '../../../src/controllers/authController';
import { Context } from 'hono';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { dbManager } from '../../../src/database/Config';
import { logger } from '../../../src/utils/logger';

// Mock dependencies
vi.mock('../../../src/database/Config', () => ({
  dbManager: {
    getDatabase: vi.fn()
  }
}));

vi.mock('../../../src/utils/logger', () => ({
  logger: {
    info: vi.fn(),
    warn: vi.fn(),
    error: vi.fn()
  }
}));

vi.mock('bcryptjs', async () => {
  const actual = await vi.importActual('bcryptjs');
  return {
    ...actual,
    hash: vi.fn(),
    compare: vi.fn()
  };
});

vi.mock('jsonwebtoken', async () => {
  const actual = await vi.importActual('jsonwebtoken');
  return {
    ...actual,
    sign: vi.fn(),
    decode: vi.fn()
  };
});

describe('AuthController', () => {
  let mockContext: Context;
  let mockDatabase: any;

  beforeEach(() => {
    // Reset all mocks
    vi.clearAllMocks();
    
    // Setup mock context
    mockContext = {
      req: {
        valid: vi.fn(),
        header: vi.fn(),
      },
      json: vi.fn(),
      get: vi.fn(),
    } as unknown as Context;
    
    // Setup mock database
    mockDatabase = {
      findOne: vi.fn(),
      create: vi.fn(),
      findById: vi.fn(),
    };
    
    (dbManager.getDatabase as MockedFunction<any>).mockReturnValue(mockDatabase);
  });

  describe('register', () => {
    it('should register a new user successfully', async () => {
      // Arrange
      const mockUser = {
        id: 1,
        email: 'test@example.com',
        name: 'Test User',
        password: 'hashed_password',
        role: 'buyer',
        createdAt: '2023-01-01T00:00:00.000Z'
      };
      
      const mockReqBody = {
        email: 'test@example.com',
        password: 'password123',
        name: 'Test User',
        role: 'buyer'
      };
      
      (mockContext.req.valid as MockedFunction<any>).mockReturnValue(mockReqBody);
      mockDatabase.findOne.mockResolvedValue(null); // No existing user
      mockDatabase.create.mockResolvedValue(mockUser);
      (bcrypt.hash as MockedFunction<any>).mockResolvedValue('hashed_password');
      (jwt.sign as MockedFunction<any>).mockReturnValue('mock_jwt_token');
      (jwt.decode as MockedFunction<any>).mockReturnValue({ exp: 1234567890 });
      
      // Act
      await AuthController.register(mockContext);
      
      // Assert
      expect(mockDatabase.findOne).toHaveBeenCalledWith('users', { email: 'test@example.com' });
      expect(bcrypt.hash).toHaveBeenCalledWith('password123', 10);
      expect(mockDatabase.create).toHaveBeenCalledWith({
        email: 'test@example.com',
        password: 'hashed_password',
        name: 'Test User',
        role: 'buyer',
        createdAt: expect.any(String)
      });
      expect(jwt.sign).toHaveBeenCalledWith(
        { userId: 1, email: 'test@example.com' },
        'default_secret',
        { expiresIn: '24h' }
      );
      expect(mockContext.json).toHaveBeenCalledWith({
        user: {
          id: 1,
          email: 'test@example.com',
          name: 'Test User',
          role: 'buyer',
          createdAt: '2023-01-01T00:00:00.000Z'
        },
        token: 'mock_jwt_token'
      }, 201);
    });

    it('should return 409 if user already exists', async () => {
      // Arrange
      const existingUser = {
        id: 1,
        email: 'test@example.com',
        name: 'Test User'
      };
      
      const mockReqBody = {
        email: 'test@example.com',
        password: 'password123',
        name: 'Test User',
        role: 'buyer'
      };
      
      (mockContext.req.valid as MockedFunction<any>).mockReturnValue(mockReqBody);
      mockDatabase.findOne.mockResolvedValue(existingUser);
      
      // Act
      await AuthController.register(mockContext);
      
      // Assert
      expect(mockDatabase.findOne).toHaveBeenCalledWith('users', { email: 'test@example.com' });
      expect(mockContext.json).toHaveBeenCalledWith(
        { error: 'User with this email already exists' }, 
        409
      );
    });

    it('should return 500 if there is an error during registration', async () => {
      // Arrange
      const mockReqBody = {
        email: 'test@example.com',
        password: 'password123',
        name: 'Test User',
        role: 'buyer'
      };
      
      (mockContext.req.valid as MockedFunction<any>).mockReturnValue(mockReqBody);
      mockDatabase.findOne.mockRejectedValue(new Error('Database error'));
      
      // Act
      await AuthController.register(mockContext);
      
      // Assert
      expect(logger.error).toHaveBeenCalled();
      expect(mockContext.json).toHaveBeenCalledWith(
        { error: 'Internal server error' }, 
        500
      );
    });
  });

  describe('login', () => {
    it('should login user successfully with correct credentials', async () => {
      // Arrange
      const mockUser = {
        id: 1,
        email: 'test@example.com',
        name: 'Test User',
        password: 'hashed_password',
        role: 'buyer',
        createdAt: '2023-01-01T00:00:00.000Z'
      };
      
      const mockReqBody = {
        email: 'test@example.com',
        password: 'password123'
      };
      
      (mockContext.req.valid as MockedFunction<any>).mockReturnValue(mockReqBody);
      mockDatabase.findOne.mockResolvedValue(mockUser);
      (bcrypt.compare as MockedFunction<any>).mockResolvedValue(true);
      (jwt.sign as MockedFunction<any>).mockReturnValue('mock_jwt_token');
      (jwt.decode as MockedFunction<any>).mockReturnValue({ exp: 1234567890 });
      
      // Act
      await AuthController.login(mockContext);
      
      // Assert
      expect(mockDatabase.findOne).toHaveBeenCalledWith('users', { email: 'test@example.com' });
      expect(bcrypt.compare).toHaveBeenCalledWith('password123', 'hashed_password');
      expect(jwt.sign).toHaveBeenCalledWith(
        { userId: 1, email: 'test@example.com' },
        'default_secret',
        { expiresIn: '24h' }
      );
      expect(mockContext.json).toHaveBeenCalledWith({
        user: {
          id: 1,
          email: 'test@example.com',
          name: 'Test User',
          role: 'buyer',
          createdAt: '2023-01-01T00:00:00.000Z'
        },
        token: 'mock_jwt_token'
      });
    });

    it('should return 401 if user is not found', async () => {
      // Arrange
      const mockReqBody = {
        email: 'test@example.com',
        password: 'password123'
      };
      
      (mockContext.req.valid as MockedFunction<any>).mockReturnValue(mockReqBody);
      mockDatabase.findOne.mockResolvedValue(null);
      
      // Act
      await AuthController.login(mockContext);
      
      // Assert
      expect(mockContext.json).toHaveBeenCalledWith(
        { error: 'Invalid email or password' }, 
        401
      );
    });

    it('should return 401 if password is invalid', async () => {
      // Arrange
      const mockUser = {
        id: 1,
        email: 'test@example.com',
        name: 'Test User',
        password: 'hashed_password',
        role: 'buyer',
        createdAt: '2023-01-01T00:00:00.000Z'
      };
      
      const mockReqBody = {
        email: 'test@example.com',
        password: 'wrong_password'
      };
      
      (mockContext.req.valid as MockedFunction<any>).mockReturnValue(mockReqBody);
      mockDatabase.findOne.mockResolvedValue(mockUser);
      (bcrypt.compare as MockedFunction<any>).mockResolvedValue(false);
      
      // Act
      await AuthController.login(mockContext);
      
      // Assert
      expect(bcrypt.compare).toHaveBeenCalledWith('wrong_password', 'hashed_password');
      expect(mockContext.json).toHaveBeenCalledWith(
        { error: 'Invalid email or password' }, 
        401
      );
    });

    it('should return 500 if there is an error during login', async () => {
      // Arrange
      const mockReqBody = {
        email: 'test@example.com',
        password: 'password123'
      };
      
      (mockContext.req.valid as MockedFunction<any>).mockReturnValue(mockReqBody);
      mockDatabase.findOne.mockRejectedValue(new Error('Database error'));
      
      // Act
      await AuthController.login(mockContext);
      
      // Assert
      expect(logger.error).toHaveBeenCalled();
      expect(mockContext.json).toHaveBeenCalledWith(
        { error: 'Internal server error' }, 
        500
      );
    });
  });

  describe('getCurrentUser', () => {
    it('should return current user profile when authenticated', async () => {
      // Arrange
      const mockUser = {
        id: 1,
        email: 'test@example.com',
        name: 'Test User',
        password: 'hashed_password',
        role: 'buyer',
        createdAt: '2023-01-01T00:00:00.000Z'
      };
      
      (mockContext.get as MockedFunction<any>).mockReturnValue({ userId: 1 });
      mockDatabase.findById.mockResolvedValue(mockUser);
      
      // Act
      await AuthController.getCurrentUser(mockContext);
      
      // Assert
      expect(mockContext.get).toHaveBeenCalledWith('user');
      expect(mockDatabase.findById).toHaveBeenCalledWith('users', 1);
      expect(mockContext.json).toHaveBeenCalledWith({
        id: 1,
        email: 'test@example.com',
        name: 'Test User',
        role: 'buyer',
        createdAt: '2023-01-01T00:00:00.000Z'
      });
    });

    it('should return 401 if user is not authenticated', async () => {
      // Arrange
      (mockContext.get as MockedFunction<any>).mockReturnValue(null);
      
      // Act
      await AuthController.getCurrentUser(mockContext);
      
      // Assert
      expect(mockContext.json).toHaveBeenCalledWith(
        { error: 'Unauthorized' }, 
        401
      );
    });

    it('should return 404 if user is not found in database', async () => {
      // Arrange
      (mockContext.get as MockedFunction<any>).mockReturnValue({ userId: 1 });
      mockDatabase.findById.mockResolvedValue(null);
      
      // Act
      await AuthController.getCurrentUser(mockContext);
      
      // Assert
      expect(mockContext.json).toHaveBeenCalledWith(
        { error: 'User not found' }, 
        404
      );
    });

    it('should return 500 if there is an error retrieving user', async () => {
      // Arrange
      (mockContext.get as MockedFunction<any>).mockReturnValue({ userId: 1 });
      mockDatabase.findById.mockRejectedValue(new Error('Database error'));
      
      // Act
      await AuthController.getCurrentUser(mockContext);
      
      // Assert
      expect(mockContext.json).toHaveBeenCalledWith(
        { error: 'Internal server error' }, 
        500
      );
    });
  });

  describe('logout', () => {
    it('should logout user successfully', async () => {
      // Arrange
      mockContext.req.header = vi.fn().mockReturnValue('Bearer mock_token');
      (jwt.decode as MockedFunction<any>).mockReturnValue({ userId: 1, email: 'test@example.com' });
      
      // Act
      await AuthController.logout(mockContext);
      
      // Assert
      expect(mockContext.req.header).toHaveBeenCalledWith('Authorization');
      expect(mockContext.json).toHaveBeenCalledWith({
        message: 'Successfully logged out'
      });
    });

    it('should return 400 if no token is provided', async () => {
      // Arrange
      mockContext.req.header = vi.fn().mockReturnValue(null);
      
      // Act
      await AuthController.logout(mockContext);
      
      // Assert
      expect(mockContext.json).toHaveBeenCalledWith(
        { error: 'No token provided' }, 
        400
      );
    });

    it('should return 400 if token does not have Bearer prefix', async () => {
      // Arrange
      mockContext.req.header = vi.fn().mockReturnValue('invalid_token_format');
      
      // Act
      await AuthController.logout(mockContext);
      
      // Assert
      expect(mockContext.json).toHaveBeenCalledWith(
        { error: 'No token provided' }, 
        400
      );
    });
  });

  describe('verifyToken', () => {
    const activeTokens = new Map();
    let originalActiveTokens: any;
    
    beforeEach(() => {
      // Store original activeTokens reference and replace with our test map
      const authControllerModule = require('../../../src/controllers/authController');
      originalActiveTokens = authControllerModule.activeTokens;
      Object.defineProperty(authControllerModule, 'activeTokens', {
        value: activeTokens,
        writable: true
      });
    });
    
    afterEach(() => {
      // Restore original activeTokens
      const authControllerModule = require('../../../src/controllers/authController');
      Object.defineProperty(authControllerModule, 'activeTokens', {
        value: originalActiveTokens,
        writable: true
      });
    });

    it('should verify valid token successfully', async () => {
      // Arrange
      activeTokens.set('valid_token', { userId: 1, email: 'test@example.com', exp: Math.floor(Date.now() / 1000) + 3600 }); // Token expires in 1 hour
      mockContext.req.header = vi.fn().mockReturnValue('Bearer valid_token');
      
      // Act
      await AuthController.verifyToken(mockContext);
      
      // Assert
      expect(mockContext.json).toHaveBeenCalledWith({
        valid: true,
        user: { id: 1, email: 'test@example.com' }
      });
    });

    it('should return false for non-existent token', async () => {
      // Arrange
      mockContext.req.header = vi.fn().mockReturnValue('Bearer non_existent_token');
      
      // Act
      await AuthController.verifyToken(mockContext);
      
      // Assert
      expect(mockContext.json).toHaveBeenCalledWith(
        { valid: false }, 
        401
      );
    });

    it('should return false for expired token', async () => {
      // Arrange
      activeTokens.set('expired_token', { userId: 1, email: 'test@example.com', exp: Math.floor(Date.now() / 1000) - 3600 }); // Token expired 1 hour ago
      mockContext.req.header = vi.fn().mockReturnValue('Bearer expired_token');
      
      // Act
      await AuthController.verifyToken(mockContext);
      
      // Assert
      expect(activeTokens.has('expired_token')).toBe(false); // Token should be removed
      expect(mockContext.json).toHaveBeenCalledWith(
        { valid: false }, 
        401
      );
    });

    it('should return 400 if no token is provided', async () => {
      // Arrange
      mockContext.req.header = vi.fn().mockReturnValue(null);
      
      // Act
      await AuthController.verifyToken(mockContext);
      
      // Assert
      expect(mockContext.json).toHaveBeenCalledWith(
        { valid: false }, 
        400
      );
    });
  });
});