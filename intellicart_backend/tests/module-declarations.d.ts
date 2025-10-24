declare module '../../../../src/middleware/auth' {
  import { MiddlewareHandler } from 'hono';
  export const authMiddleware: MiddlewareHandler;
}

declare module '../../../../src/controllers/ProductController' {
  export class ProductController {
    static getAllProducts: (c: any) => Promise<any>;
    static getSellerProducts: (c: any) => Promise<any>;
    static getProductById: (c: any) => Promise<any>;
    static createProduct: (c: any) => Promise<any>;
    static updateProduct: (c: any) => Promise<any>;
    static deleteProduct: (c: any) => Promise<any>;
    static addReview: (c: any) => Promise<any>;
  }
}