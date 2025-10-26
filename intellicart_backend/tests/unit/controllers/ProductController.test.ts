import { describe, it, expect, beforeEach, vi } from 'bun:test';
import { ProductController } from '../../../src/controllers/ProductController';
import { Context } from 'hono';
import { dbManager } from '../../../src/database/Config';

// Mock the database methods
const mockDatabaseMethods = {
  findAll: vi.fn(),
  findById: vi.fn(),
  create: vi.fn(),
  update: vi.fn(),
  delete: vi.fn(),
  findBy: vi.fn(),
  findOne: vi.fn(),
};

const productController = new ProductController(mockDatabaseMethods as any);

// Keep a reference to the original getDatabase function to mock it
const originalGetDatabase = dbManager.getDatabase;

describe('ProductController', () => {
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
      get: vi.fn(),
    } as unknown as Context;
    
    // Mock the database
    vi.spyOn(dbManager, 'getDatabase').mockReturnValue(mockDatabaseMethods);
  });

  describe('getAllProducts', () => {
    it('should return all products successfully', async () => {
      // Arrange
      const mockProducts = [
        { id: 1, name: 'Product 1', description: 'Description 1', price: '10.99', sellerId: 1 },
        { id: 2, name: 'Product 2', description: 'Description 2', price: '15.99', sellerId: 1 }
      ];
      
      mockDatabaseMethods.findAll.mockResolvedValue(mockProducts);
      
      // Act
      await productController.getAll(mockContext);
      
      // Assert
      expect(mockDatabaseMethods.findAll).toHaveBeenCalledWith('products');
      expect(mockContext.json).toHaveBeenCalledWith(mockProducts);
    });

    it('should return 500 if there is an error retrieving products', async () => {
      // Arrange
      mockDatabaseMethods.findAll.mockRejectedValue(new Error('Database error'));
      
      // Act
      await productController.getAll(mockContext);
      
      // Assert
      expect(mockContext.json).toHaveBeenCalledWith(
        { error: 'Internal server error' }, 
        500
      );
    });
  });

  describe('getProductById', () => {
    it('should return product by ID successfully', async () => {
      // Arrange
      const mockProduct = { 
        id: 1, 
        name: 'Product 1', 
        description: 'Description 1', 
        price: '10.99',
        sellerId: 1,
        createdAt: '2023-01-01T00:00:00.000Z' 
      };
      
      (mockContext.req.param as any).mockReturnValue('1');
      mockDatabaseMethods.findById.mockResolvedValue(mockProduct);
      
      // Act
      await productController.getById(mockContext);
      
      // Assert
      expect(mockContext.req.param).toHaveBeenCalledWith('id');
      expect(mockDatabaseMethods.findById).toHaveBeenCalledWith('products', 1);
      expect(mockContext.json).toHaveBeenCalledWith(mockProduct);
    });

    it('should return 404 if product is not found', async () => {
      // Arrange
      (mockContext.req.param as any).mockReturnValue('999');
      mockDatabaseMethods.findById.mockResolvedValue(null);
      
      // Act
      await productController.getById(mockContext);
      
      // Assert
      expect(mockContext.json).toHaveBeenCalledWith(
        { error: 'product not found' }, 
        404
      );
    });

    it('should return 500 if there is an error retrieving product', async () => {
      // Arrange
      (mockContext.req.param as any).mockReturnValue('1');
      mockDatabaseMethods.findById.mockRejectedValue(new Error('Database error'));
      
      // Act
      await productController.getById(mockContext);
      
      // Assert
      expect(mockContext.json).toHaveBeenCalledWith(
        { error: 'Internal server error' }, 
        500
      );
    });
  });

  describe('createProduct', () => {
    it('should create a new product successfully', async () => {
      // Arrange
      const mockReqBody = {
        name: 'New Product',
        description: 'Product Description',
        price: '19.99',
        imageUrl: 'https://example.com/image.jpg'
      };
      
      const mockCreatedProduct = {
        id: 1,
        name: 'New Product',
        description: 'Product Description',
        price: '19.99',
        imageUrl: 'https://example.com/image.jpg',
        sellerId: 1,
        reviews: [],
        createdAt: '2023-01-01T00:00:00.000Z'
      };
      
      const mockUser = { userId: 1 };
      
      (mockContext.req.json as any).mockResolvedValue(mockReqBody);
      (mockContext.get as any).mockReturnValue(mockUser);
      mockDatabaseMethods.create.mockResolvedValue(mockCreatedProduct);
      
      // Act
      await productController.create(mockContext, mockReqBody);
      
      // Assert
      expect(mockDatabaseMethods.create).toHaveBeenCalledWith('products', {
        name: 'New Product',
        description: 'Product Description',
        price: '19.99',
        imageUrl: 'https://example.com/image.jpg',
        createdAt: expect.any(String)
      });
      expect(mockContext.json).toHaveBeenCalledWith(mockCreatedProduct, 201);
    });

    it('should return 500 if there is an error creating product', async () => {
      // Arrange
      const mockReqBody = {
        name: 'New Product',
        description: 'Product Description',
        price: '19.99',
        imageUrl: 'https://example.com/image.jpg'
      };
      
      const mockUser = { userId: 1 };
      
      (mockContext.req.valid as any).mockReturnValue(mockReqBody);
      (mockContext.get as any).mockReturnValue(mockUser);
      mockDatabaseMethods.create.mockRejectedValue(new Error('Database error'));
      
      // Act
      await productController.create(mockContext, mockReqBody);
      
      // Assert
      expect(mockContext.json).toHaveBeenCalledWith(
        { error: 'Internal server error' }, 
        500
      );
    });
  });

  describe('updateProduct', () => {
    it('should update product successfully for the owner', async () => {
      // Arrange
      const mockReqBody = {
        name: 'Updated Product',
        price: '29.99'
      };
      
      const mockExistingProduct = {
        id: 1,
        name: 'Original Product',
        description: 'Original Description',
        price: '19.99',
        sellerId: 1,
        createdAt: '2023-01-01T00:00:00.000Z'
      };
      
      const mockUpdatedProduct = {
        id: 1,
        name: 'Updated Product',
        description: 'Original Description',
        price: '29.99',
        sellerId: 1,
        createdAt: '2023-01-01T00:00:00.000Z'
      };
      
      const mockUser = { userId: 1 };
      
      (mockContext.req.param as any).mockReturnValue('1');
      (mockContext.req.json as any).mockResolvedValue(mockReqBody);
      (mockContext.get as any).mockReturnValue(mockUser);
      mockDatabaseMethods.findById.mockResolvedValue(mockExistingProduct);
      mockDatabaseMethods.update.mockResolvedValue(mockUpdatedProduct);
      
      // Act
      await productController.update(mockContext, mockReqBody);
      
      // Assert
      expect(mockDatabaseMethods.findById).toHaveBeenCalledWith('products', 1);
      expect(mockDatabaseMethods.update).toHaveBeenCalledWith('products', 1, { name: 'Updated Product', price: '29.99' });
      expect(mockContext.json).toHaveBeenCalledWith(mockUpdatedProduct);
    });

    it('should return 404 if product to update does not exist', async () => {
      // Arrange
      (mockContext.req.param as any).mockReturnValue('999');
      mockDatabaseMethods.findById.mockResolvedValue(null);
      
      // Act
      await productController.update(mockContext, {});
      
      // Assert
      expect(mockContext.json).toHaveBeenCalledWith(
        { error: 'product not found' }, 
        404
      );
    });

    it('should return 500 if there is an error updating product', async () => {
      // Arrange
      const mockReqBody = {
        name: 'Updated Product'
      };
      
      const mockExistingProduct = {
        id: 1,
        name: 'Original Product',
        sellerId: 1,
        createdAt: '2023-01-01T00:00:00.000Z'
      };
      
      const mockUser = { userId: 1 };
      
      (mockContext.req.param as any).mockReturnValue('1');
      (mockContext.req.valid as any).mockReturnValue(mockReqBody);
      (mockContext.get as any).mockReturnValue(mockUser);
      mockDatabaseMethods.findById.mockResolvedValue(mockExistingProduct);
      mockDatabaseMethods.update.mockRejectedValue(new Error('Database error'));
      
      // Act
      await productController.update(mockContext, mockReqBody);
      
      // Assert
      expect(mockContext.json).toHaveBeenCalledWith(
        { error: 'Internal server error' }, 
        500
      );
    });
  });

  describe('deleteProduct', () => {
    it('should delete product successfully for the owner', async () => {
      // Arrange
      const mockProduct = {
        id: 1,
        name: 'Product to Delete',
        sellerId: 1,
        createdAt: '2023-01-01T00:00:00.000Z'
      };
      
      const mockUser = { userId: 1 };
      
      (mockContext.req.param as any).mockReturnValue('1');
      (mockContext.get as any).mockReturnValue(mockUser);
      mockDatabaseMethods.findById.mockResolvedValue(mockProduct);
      mockDatabaseMethods.delete.mockResolvedValue(true);
      
      // Act
      await productController.delete(mockContext);
      
      // Assert
      expect(mockDatabaseMethods.findById).toHaveBeenCalledWith('products', 1);
      expect(mockDatabaseMethods.delete).toHaveBeenCalledWith('products', 1);
      expect(mockContext.json).toHaveBeenCalledWith({
        message: 'product deleted successfully',
        item: mockProduct
      });
    });

    it('should return 404 if product to delete does not exist', async () => {
      // Arrange
      (mockContext.req.param as any).mockReturnValue('999');
      mockDatabaseMethods.findById.mockResolvedValue(null);
      
      // Act
      await productController.delete(mockContext);
      
      // Assert
      expect(mockContext.json).toHaveBeenCalledWith(
        { error: 'product not found' }, 
        404
      );
    });

    it('should return 500 if there is an error deleting product', async () => {
      // Arrange
      const mockProduct = {
        id: 1,
        name: 'Product to Delete',
        sellerId: 1,
        createdAt: '2023-01-01T00:00:00.000Z'
      };
      
      const mockUser = { userId: 1 };
      
      (mockContext.req.param as any).mockReturnValue('1');
      (mockContext.get as any).mockReturnValue(mockUser);
      mockDatabaseMethods.findById.mockResolvedValue(mockProduct);
      mockDatabaseMethods.delete.mockResolvedValue(false); // Failed to delete
      
      // Act
      await productController.delete(mockContext);
      
      // Assert
      expect(mockContext.json).toHaveBeenCalledWith(
        { error: 'Failed to delete product' }, 
        500
      );
    });
  });

  describe('getSellerProducts', () => {
    it('should return products for the authenticated seller', async () => {
      // Arrange
      const mockProducts = [
        { id: 1, name: 'Product 1', sellerId: 1 },
        { id: 2, name: 'Product 2', sellerId: 1 }
      ];
      
      const mockUser = { userId: 1 };
      
      (mockContext.req.param as any).mockReturnValue('1');
      (mockContext.get as any).mockReturnValue(mockUser);
      mockDatabaseMethods.findBy.mockResolvedValue(mockProducts);
      
      // Act
      await ProductController.getSellerProducts(mockContext);
      
      // Assert
      expect(mockContext.get).toHaveBeenCalledWith('user');
      expect(mockDatabaseMethods.findBy).toHaveBeenCalledWith('products', { sellerId: 1 });
      expect(mockContext.json).toHaveBeenCalledWith(mockProducts);
    });

    it('should return 403 if requesting user is not the seller', async () => {
      // Arrange
      const mockUser = { userId: 2 }; // Different user
      
      (mockContext.req.param as any).mockReturnValue('1');
      (mockContext.get as any).mockReturnValue(mockUser);
      
      // Act
      await ProductController.getSellerProducts(mockContext);
      
      // Assert
      expect(mockContext.json).toHaveBeenCalledWith(
        { error: 'Access denied' }, 
        403
      );
    });

    it('should return 500 if there is an error retrieving seller products', async () => {
      // Arrange
      const mockUser = { userId: 1 };
      
      (mockContext.req.param as any).mockReturnValue('1');
      (mockContext.get as any).mockReturnValue(mockUser);
      mockDatabaseMethods.findBy.mockRejectedValue(new Error('Database error'));
      
      // Act
      await ProductController.getSellerProducts(mockContext);
      
      // Assert
      expect(mockContext.json).toHaveBeenCalledWith(
        { error: 'Internal server error' }, 
        500
      );
    });
  });
});