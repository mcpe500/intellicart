import { describe, it, expect, beforeEach, vi, MockedFunction } from 'bun:test';
import { ProductController } from '../../../src/controllers/ProductController';
import { Context } from 'hono';
import { dbManager } from '../../../src/database/Config';

// Mock dependencies
vi.mock('../../../src/database/Config', () => ({
  dbManager: {
    getDatabase: vi.fn()
  }
}));

describe('ProductController', () => {
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
      get: vi.fn(),
    } as unknown as Context;
    
    // Setup mock database
    mockDatabase = {
      findAll: vi.fn(),
      findById: vi.fn(),
      create: vi.fn(),
      update: vi.fn(),
      delete: vi.fn(),
      findBy: vi.fn(),
      findOne: vi.fn(),
    };
    
    (dbManager.getDatabase as MockedFunction<any>).mockReturnValue(mockDatabase);
  });

  describe('getAllProducts', () => {
    it('should return all products successfully', async () => {
      // Arrange
      const mockProducts = [
        { id: 1, name: 'Product 1', description: 'Description 1', price: '10.99', sellerId: 1 },
        { id: 2, name: 'Product 2', description: 'Description 2', price: '15.99', sellerId: 1 }
      ];
      
      mockDatabase.findAll.mockResolvedValue(mockProducts);
      
      // Act
      await ProductController.getAllProducts(mockContext);
      
      // Assert
      expect(mockDatabase.findAll).toHaveBeenCalledWith('products');
      expect(mockContext.json).toHaveBeenCalledWith(mockProducts);
    });

    it('should return 500 if there is an error retrieving products', async () => {
      // Arrange
      mockDatabase.findAll.mockRejectedValue(new Error('Database error'));
      
      // Act
      await ProductController.getAllProducts(mockContext);
      
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
      
      (mockContext.req.param as MockedFunction<any>).mockReturnValue('1');
      mockDatabase.findById.mockResolvedValue(mockProduct);
      
      // Act
      await ProductController.getProductById(mockContext);
      
      // Assert
      expect(mockContext.req.param).toHaveBeenCalledWith('id');
      expect(mockDatabase.findById).toHaveBeenCalledWith('products', 1);
      expect(mockContext.json).toHaveBeenCalledWith(mockProduct);
    });

    it('should return 404 if product is not found', async () => {
      // Arrange
      (mockContext.req.param as MockedFunction<any>).mockReturnValue('999');
      mockDatabase.findById.mockResolvedValue(null);
      
      // Act
      await ProductController.getProductById(mockContext);
      
      // Assert
      expect(mockContext.json).toHaveBeenCalledWith(
        { error: 'Product not found' }, 
        404
      );
    });

    it('should return 500 if there is an error retrieving product', async () => {
      // Arrange
      (mockContext.req.param as MockedFunction<any>).mockReturnValue('1');
      mockDatabase.findById.mockRejectedValue(new Error('Database error'));
      
      // Act
      await ProductController.getProductById(mockContext);
      
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
      
      (mockContext.req.valid as MockedFunction<any>).mockReturnValue(mockReqBody);
      (mockContext.get as MockedFunction<any>).mockReturnValue(mockUser);
      mockDatabase.create.mockResolvedValue(mockCreatedProduct);
      
      // Act
      await ProductController.createProduct(mockContext);
      
      // Assert
      expect(mockContext.get).toHaveBeenCalledWith('user');
      expect(mockDatabase.create).toHaveBeenCalledWith({
        name: 'New Product',
        description: 'Product Description',
        price: '19.99',
        imageUrl: 'https://example.com/image.jpg',
        sellerId: 1,
        reviews: [],
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
      
      (mockContext.req.valid as MockedFunction<any>).mockReturnValue(mockReqBody);
      (mockContext.get as MockedFunction<any>).mockReturnValue(mockUser);
      mockDatabase.create.mockRejectedValue(new Error('Database error'));
      
      // Act
      await ProductController.createProduct(mockContext);
      
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
      
      (mockContext.req.param as MockedFunction<any>).mockReturnValue('1');
      (mockContext.req.valid as MockedFunction<any>).mockReturnValue(mockReqBody);
      (mockContext.get as MockedFunction<any>).mockReturnValue(mockUser);
      mockDatabase.findById.mockResolvedValue(mockExistingProduct);
      mockDatabase.update.mockResolvedValue(mockUpdatedProduct);
      
      // Act
      await ProductController.updateProduct(mockContext);
      
      // Assert
      expect(mockDatabase.findById).toHaveBeenCalledWith('products', 1);
      expect(mockContext.get).toHaveBeenCalledWith('user');
      expect(mockDatabase.update).toHaveBeenCalledWith('products', 1, { name: 'Updated Product', price: '29.99' });
      expect(mockContext.json).toHaveBeenCalledWith(mockUpdatedProduct);
    });

    it('should return 404 if product to update does not exist', async () => {
      // Arrange
      (mockContext.req.param as MockedFunction<any>).mockReturnValue('999');
      mockDatabase.findById.mockResolvedValue(null);
      
      // Act
      await ProductController.updateProduct(mockContext);
      
      // Assert
      expect(mockContext.json).toHaveBeenCalledWith(
        { error: 'Product not found' }, 
        404
      );
    });

    it('should return 403 if user is not the seller of the product', async () => {
      // Arrange
      const mockReqBody = {
        name: 'Updated Product'
      };
      
      const mockExistingProduct = {
        id: 1,
        name: 'Original Product',
        sellerId: 2, // Different seller
        createdAt: '2023-01-01T00:00:00.000Z'
      };
      
      const mockUser = { userId: 1 }; // Different user
      
      (mockContext.req.param as MockedFunction<any>).mockReturnValue('1');
      (mockContext.req.valid as MockedFunction<any>).mockReturnValue(mockReqBody);
      (mockContext.get as MockedFunction<any>).mockReturnValue(mockUser);
      mockDatabase.findById.mockResolvedValue(mockExistingProduct);
      
      // Act
      await ProductController.updateProduct(mockContext);
      
      // Assert
      expect(mockContext.json).toHaveBeenCalledWith(
        { error: 'You can only update products you created' }, 
        403
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
      
      (mockContext.req.param as MockedFunction<any>).mockReturnValue('1');
      (mockContext.req.valid as MockedFunction<any>).mockReturnValue(mockReqBody);
      (mockContext.get as MockedFunction<any>).mockReturnValue(mockUser);
      mockDatabase.findById.mockResolvedValue(mockExistingProduct);
      mockDatabase.update.mockRejectedValue(new Error('Database error'));
      
      // Act
      await ProductController.updateProduct(mockContext);
      
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
      
      (mockContext.req.param as MockedFunction<any>).mockReturnValue('1');
      (mockContext.get as MockedFunction<any>).mockReturnValue(mockUser);
      mockDatabase.findById.mockResolvedValue(mockProduct);
      mockDatabase.delete.mockResolvedValue(true);
      
      // Act
      await ProductController.deleteProduct(mockContext);
      
      // Assert
      expect(mockDatabase.findById).toHaveBeenCalledWith('products', 1);
      expect(mockContext.get).toHaveBeenCalledWith('user');
      expect(mockDatabase.delete).toHaveBeenCalledWith('products', 1);
      expect(mockContext.json).toHaveBeenCalledWith({
        message: 'Product deleted successfully',
        product: mockProduct
      });
    });

    it('should return 404 if product to delete does not exist', async () => {
      // Arrange
      (mockContext.req.param as MockedFunction<any>).mockReturnValue('999');
      mockDatabase.findById.mockResolvedValue(null);
      
      // Act
      await ProductController.deleteProduct(mockContext);
      
      // Assert
      expect(mockContext.json).toHaveBeenCalledWith(
        { error: 'Product not found' }, 
        404
      );
    });

    it('should return 403 if user is not the seller of the product', async () => {
      // Arrange
      const mockProduct = {
        id: 1,
        name: 'Product to Delete',
        sellerId: 2, // Different seller
        createdAt: '2023-01-01T00:00:00.000Z'
      };
      
      const mockUser = { userId: 1 }; // Different user
      
      (mockContext.req.param as MockedFunction<any>).mockReturnValue('1');
      (mockContext.get as MockedFunction<any>).mockReturnValue(mockUser);
      mockDatabase.findById.mockResolvedValue(mockProduct);
      
      // Act
      await ProductController.deleteProduct(mockContext);
      
      // Assert
      expect(mockContext.json).toHaveBeenCalledWith(
        { error: 'You can only delete products you created' }, 
        403
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
      
      (mockContext.req.param as MockedFunction<any>).mockReturnValue('1');
      (mockContext.get as MockedFunction<any>).mockReturnValue(mockUser);
      mockDatabase.findById.mockResolvedValue(mockProduct);
      mockDatabase.delete.mockResolvedValue(false); // Failed to delete
      
      // Act
      await ProductController.deleteProduct(mockContext);
      
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
      
      (mockContext.req.param as MockedFunction<any>).mockReturnValue('1');
      (mockContext.get as MockedFunction<any>).mockReturnValue(mockUser);
      mockDatabase.findBy.mockResolvedValue(mockProducts);
      
      // Act
      await ProductController.getSellerProducts(mockContext);
      
      // Assert
      expect(mockContext.get).toHaveBeenCalledWith('user');
      expect(mockDatabase.findBy).toHaveBeenCalledWith('products', { sellerId: 1 });
      expect(mockContext.json).toHaveBeenCalledWith(mockProducts);
    });

    it('should return 403 if requesting user is not the seller', async () => {
      // Arrange
      const mockUser = { userId: 2 }; // Different user
      
      (mockContext.req.param as MockedFunction<any>).mockReturnValue('1');
      (mockContext.get as MockedFunction<any>).mockReturnValue(mockUser);
      
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
      
      (mockContext.req.param as MockedFunction<any>).mockReturnValue('1');
      (mockContext.get as MockedFunction<any>).mockReturnValue(mockUser);
      mockDatabase.findBy.mockRejectedValue(new Error('Database error'));
      
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