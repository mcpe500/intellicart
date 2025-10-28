import { describe, it, expect, beforeEach, vi } from "bun:test";
import { OrderController } from "../../../src/controllers/OrderController";
import { Context } from "hono";
import { dbManager } from "../../../src/database/Config";

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

describe("OrderController", () => {
  let mockContext: Context;

  beforeEach(() => {
    // Reset all mocks
    vi.clearAllMocks();

    // Setup mock context
    mockContext = {
      req: {
        param: vi.fn(),
        valid: vi.fn(),
        json: vi.fn(async () => ({})), // Add the missing json method that returns a promise
      },
      json: vi.fn(),
      get: vi.fn(),
    } as unknown as Context;

    // Mock the database
    vi.spyOn(dbManager, "getDatabase").mockReturnValue(
      mockDatabaseMethods as any,
    );
  });

  describe("getSellerOrders", () => {
    it("should return orders for the authenticated seller", async () => {
      // Arrange
      const mockOrders = [
        { id: 1, productId: 1, buyerId: 2, status: "pending", sellerId: 1 },
        { id: 2, productId: 3, buyerId: 4, status: "completed", sellerId: 1 },
      ];

      const mockUser = { userId: 1 };

      (mockContext.get as any).mockReturnValue(mockUser);
      mockDatabaseMethods.findBy.mockResolvedValue(mockOrders);

      // Act
      await OrderController.getSellerOrders(mockContext);

      // Assert
      expect(mockContext.get).toHaveBeenCalledWith("user");
      expect(mockDatabaseMethods.findBy).toHaveBeenCalledWith("orders", {
        sellerId: 1,
      });
      expect(mockContext.json).toHaveBeenCalledWith(mockOrders);
    });

    it("should return 500 if there is an error retrieving orders", async () => {
      // Arrange
      const mockUser = { userId: 1 };

      (mockContext.get as any).mockReturnValue(mockUser);
      mockDatabaseMethods.findBy.mockRejectedValue(new Error("Database error"));

      // Act
      await OrderController.getSellerOrders(mockContext);

      // Assert
      expect(mockContext.json).toHaveBeenCalledWith(
        { error: "Internal server error" },
        500,
      );
    });
  });

  describe("updateOrderStatus", () => {
    it("should update order status successfully for the seller", async () => {
      // Arrange
      const mockExistingOrder = {
        id: 1,
        productId: 1,
        buyerId: 2,
        status: "pending",
        sellerId: 1,
      };

      const mockUpdatedOrder = {
        id: 1,
        productId: 1,
        buyerId: 2,
        status: "shipped",
        sellerId: 1,
      };

      const mockUser = { userId: 1 };

      (mockContext.req.param as any).mockReturnValue("1");
      const mockReqBody = { status: "shipped" };
      (mockContext.req.valid as any).mockReturnValue(mockReqBody);
      (mockContext.req.json as any).mockResolvedValue(mockReqBody);
      (mockContext.get as any).mockReturnValue(mockUser);
      mockDatabaseMethods.findById.mockResolvedValue(mockExistingOrder);
      mockDatabaseMethods.update.mockResolvedValue(mockUpdatedOrder);

      // Act
      await OrderController.updateOrderStatus(mockContext);

      // Assert
      expect(mockDatabaseMethods.findById).toHaveBeenCalledWith("orders", 1);
      expect(mockContext.get).toHaveBeenCalledWith("user");
      expect(mockDatabaseMethods.update).toHaveBeenCalledWith("orders", 1, {
        status: "shipped",
      });
      expect(mockContext.json).toHaveBeenCalledWith(mockUpdatedOrder);
    });

    it("should return 404 if order to update does not exist", async () => {
      // Arrange
      (mockContext.req.param as any).mockReturnValue("999");
      const mockReqBody = { status: "shipped" };
      (mockContext.req.valid as any).mockReturnValue(mockReqBody);
      (mockContext.req.json as any).mockResolvedValue(mockReqBody);
      mockDatabaseMethods.findById.mockResolvedValue(null);

      // Act
      await OrderController.updateOrderStatus(mockContext);

      // Assert
      expect(mockContext.json).toHaveBeenCalledWith(
        { error: "Order not found" },
        404,
      );
    });

    it("should return 403 if user is not the seller of the order", async () => {
      // Arrange
      const mockExistingOrder = {
        id: 1,
        productId: 1,
        buyerId: 2,
        status: "pending",
        sellerId: 2, // Different seller
      };

      const mockUser = { userId: 1 }; // Different user

      (mockContext.req.param as any).mockReturnValue("1");
      const mockReqBody = { status: "shipped" };
      (mockContext.req.valid as any).mockReturnValue(mockReqBody);
      (mockContext.req.json as any).mockResolvedValue(mockReqBody);
      (mockContext.get as any).mockReturnValue(mockUser);
      mockDatabaseMethods.findById.mockResolvedValue(mockExistingOrder);

      // Act
      await OrderController.updateOrderStatus(mockContext);

      // Assert
      expect(mockContext.json).toHaveBeenCalledWith(
        { error: "You can only update orders associated with your products" },
        403,
      );
    });

    it("should return 500 if there is an error updating order status", async () => {
      // Arrange
      const mockExistingOrder = {
        id: 1,
        productId: 1,
        buyerId: 2,
        status: "pending",
        sellerId: 1,
      };

      const mockUser = { userId: 1 };

      (mockContext.req.param as any).mockReturnValue("1");
      const mockReqBody = { status: "shipped" };
      (mockContext.req.valid as any).mockReturnValue(mockReqBody);
      (mockContext.req.json as any).mockResolvedValue(mockReqBody);
      (mockContext.get as any).mockReturnValue(mockUser);
      mockDatabaseMethods.findById.mockResolvedValue(mockExistingOrder);
      mockDatabaseMethods.update.mockRejectedValue(new Error("Database error"));

      // Act
      await OrderController.updateOrderStatus(mockContext);

      // Assert
      expect(mockContext.json).toHaveBeenCalledWith(
        { error: "Internal server error" },
        500,
      );
    });
  });
});
