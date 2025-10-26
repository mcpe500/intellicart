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

// Keep a reference to the original getDatabase function to mock it
const originalGetDatabase = dbManager.getDatabase;

describe('ProductController - Add Review Tests', () => {
  let mockContext: Context;

  beforeEach(() => {
    // Reset all mocks
    vi.clearAllMocks();
    
    // Setup mock context
    mockContext = {
      req: {
        param: vi.fn(),
        valid: vi.fn(),
        json: vi.fn(),
      },
      json: vi.fn(),
      get: vi.fn(),
    } as unknown as Context;
    
    // Mock the database
    vi.spyOn(dbManager, 'getDatabase').mockReturnValue(mockDatabaseMethods);
  });

  describe('addReviewToProduct', () => {
    it('should add a review to a product successfully', async () => {
      // Arrange
      const mockProduct = { 
        id: 1, 
        name: 'Test Product', 
        description: 'Test Description',
        price: '10.99',
        sellerId: 1,
        reviews: []
      };
      
      const mockReviewData = {
        title: 'Great Product!',
        text: 'This product is amazing',
        rating: 5
      };
      
      const mockUpdatedProduct = {
        ...mockProduct,
        reviews: [{
          id: 1,
          title: 'Great Product!',
          text: 'This product is amazing',
          rating: 5,
          timeAgo: 'Just now'
        }]
      };
      
      (mockContext.req.param as any).mockReturnValue('1');
      (mockContext.req.json as any).mockResolvedValue(mockReviewData);
      (mockContext.req.valid as any).mockReturnValue(mockReviewData);
      mockDatabaseMethods.findById.mockResolvedValue(mockProduct);
      mockDatabaseMethods.update.mockResolvedValue(mockUpdatedProduct);
      
      // Act
      await ProductController.addReviewToProduct(mockContext);
      
      // Assert
      expect(mockContext.req.param).toHaveBeenCalledWith('id');
      expect(mockContext.req.json).toHaveBeenCalledTimes(1);
      expect(mockDatabaseMethods.findById).toHaveBeenCalledWith('products', 1);
      expect(mockDatabaseMethods.update).toHaveBeenCalledWith('products', 1, {
        reviews: [{
          id: 1,
          title: 'Great Product!',
          text: 'This product is amazing',
          rating: 5,
          timeAgo: 'Just now'
        }]
      });
      expect(mockContext.json).toHaveBeenCalledWith(mockUpdatedProduct);
    });

    it('should return 404 if product to add review to does not exist', async () => {
      // Arrange
      (mockContext.req.param as any).mockReturnValue('999');
      (mockContext.req.json as any).mockResolvedValue({
        title: 'Review for non-existent product',
        text: 'This product does not exist',
        rating: 3
      });
      
      mockDatabaseMethods.findById.mockResolvedValue(null);
      
      // Act
      await ProductController.addReviewToProduct(mockContext);
      
      // Assert
      expect(mockContext.json).toHaveBeenCalledWith(
        { error: 'Product not found' }, 
        404
      );
    });

    it('should return 500 if there is an error adding review to product', async () => {
      // Arrange
      const mockProduct = { 
        id: 1, 
        name: 'Test Product', 
        description: 'Test Description', 
        price: '10.99',
        sellerId: 1,
        reviews: []
      };
      
      (mockContext.req.param as any).mockReturnValue('1');
      (mockContext.req.json as any).mockResolvedValue({
        title: 'Test Review',
        text: 'Test Review Text',
        rating: 4
      });
      
      mockDatabaseMethods.findById.mockResolvedValue(mockProduct);
      mockDatabaseMethods.update.mockRejectedValue(new Error('Database error'));
      
      // Act
      await ProductController.addReviewToProduct(mockContext);
      
      // Assert
      expect(mockContext.json).toHaveBeenCalledWith(
        { error: 'Internal server error' }, 
        500
      );
    });

    it('should handle products with existing reviews when adding a new review', async () => {
      // Arrange
      const mockProduct = { 
        id: 1, 
        name: 'Test Product', 
        description: 'Test Description',
        price: '10.99',
        sellerId: 1,
        reviews: [{
          id: 1,
          title: 'First Review',
          text: 'First review content',
          rating: 4,
          timeAgo: '1 day ago'
        }]
      };
      
      const mockReviewData = {
        title: 'Second Review',
        text: 'Second review content',
        rating: 5
      };
      
      const mockUpdatedProduct = {
        ...mockProduct,
        reviews: [
          {
            id: 1,
            title: 'First Review',
            text: 'First review content',
            rating: 4,
            timeAgo: '1 day ago'
          },
          {
            id: 2, // New review ID
            title: 'Second Review',
            text: 'Second review content',
            rating: 5,
            timeAgo: 'Just now'
          }
        ]
      };
      
      (mockContext.req.param as any).mockReturnValue('1');
      (mockContext.req.json as any).mockResolvedValue(mockReviewData);
      (mockContext.req.valid as any).mockReturnValue(mockReviewData);
      mockDatabaseMethods.findById.mockResolvedValue(mockProduct);
      mockDatabaseMethods.update.mockResolvedValue(mockUpdatedProduct);
      
      // Act
      await ProductController.addReviewToProduct(mockContext);
      
      // Assert
      expect(mockDatabaseMethods.update).toHaveBeenCalledWith('products', 1, {
        reviews: [
          {
            id: 1,
            title: 'First Review',
            text: 'First review content',
            rating: 4,
            timeAgo: '1 day ago'
          },
          {
            id: 2,
            title: 'Second Review',
            text: 'Second review content',
            rating: 5,
            timeAgo: 'Just now'
          }
        ]
      });
      expect(mockContext.json).toHaveBeenCalledWith(mockUpdatedProduct);
    });
  });
});