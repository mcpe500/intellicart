# Intellicart Frontend - Backend API Contract

This document outlines the API endpoints implemented in the backend application for the Intellicart e-commerce platform.

## Base URL
All API endpoints are prefixed with `/api` and are served from the base URL. For example:
- Development: `http://localhost:3000/api/`
- Production: `https://yourdomain.com/api/`

## Authentication

Most endpoints require authentication using Bearer tokens. Include the token in the Authorization header:
```
Authorization: Bearer {token}
```

## Response Format

All API responses follow these standard formats:

### Success Response
```json
{
  "data": { /* response payload */ }
}
```

### Error Response
```json
{
  "message": "Error description",
  "details": { /* optional error details */ }
}
```

## Authentication Endpoints

### POST /auth/login
**Description**: Authenticate user and return token
- **Request**:
  ```json
  {
    "email": "string",
    "password": "string"
  }
  ```
- **Response (200)**:
  ```json
  {
    "user": {
      "id": "string",
      "email": "string",
      "name": "string",
      "role": "string"
    },
    "token": "string"
  }
  ```
- **Errors**: 400 (Bad Request), 401 (Unauthorized), 429 (Rate Limited)

### POST /auth/register
**Description**: Register new user
- **Request**:
  ```json
  {
    "email": "string",
    "password": "string",
    "name": "string",
    "role": "string"
  }
  ```
- **Response (201)**:
  ```json
  {
    "user": {
      "id": "string",
      "email": "string",
      "name": "string",
      "role": "string"
    },
    "token": "string"
  }
  ```
- **Errors**: 400 (Bad Request), 409 (Conflict - email exists)

### GET /auth/me
**Description**: Get authenticated user profile
- **Headers**: Authorization: Bearer {token}
- **Response (200)**:
  ```json
  {
    "id": "string",
    "name": "string",
    "email": "string",
    "role": "string",
    "createdAt": "string"
  }
  ```
- **Errors**: 401 (Unauthorized)

### GET /auth/profile
**Description**: Get authenticated user profile (legacy endpoint)
- **Headers**: Authorization: Bearer {token}
- **Response (200)**:
  ```json
  {
    "id": "string",
    "name": "string",
    "email": "string",
    "role": "string",
    "createdAt": "string"
  }
  ```
- **Errors**: 401 (Unauthorized)

## User Endpoints

### GET /users/:userId
**Description**: Get user information by ID
- **Headers**: Authorization: Bearer {token}
- **Response (200)**:
  ```json
  {
    "id": "string",
    "name": "string",
    "email": "string",
    "role": "string",
    "createdAt": "string"
  }
  ```
- **Errors**: 401 (Unauthorized), 403 (Forbidden), 404 (Not Found)

## Order Endpoints

### GET /orders/user
**Description**: Get all orders for the authenticated user
- **Headers**: Authorization: Bearer {token}
- **Query Parameters**: status (optional), page (optional), limit (optional)
- **Response (200)**:
  ```json
  {
    "orders": [
      {
        "id": "string",
        "customerId": "string",
        "customerName": "string",
        "sellerId": "string",
        "total": "number",
        "status": "string",
        "orderDate": "string",
        "items": [
          {
            "productId": "string",
            "productName": "string",
            "quantity": "number",
            "price": "number"
          }
        ]
      }
    ],
    "pagination": {
      "page": "number",
      "limit": "number",
      "total": "number",
      "totalPages": "number"
    }
  }
  ```
- **Errors**: 400 (Bad Request), 401 (Unauthorized), 403 (Forbidden), 404 (Not Found)

### GET /orders/user/:userId
**Description**: Get all orders for a specific user by ID (authorization required)
- **Headers**: Authorization: Bearer {token}
- **Query Parameters**: status (optional), page (optional), limit (optional)
- **Response (200)**:
  ```json
  {
    "orders": [
      {
        "id": "string",
        "customerId": "string",
        "customerName": "string",
        "sellerId": "string",
        "total": "number",
        "status": "string",
        "orderDate": "string",
        "items": [
          {
            "productId": "string",
            "productName": "string",
            "quantity": "number",
            "price": "number"
          }
        ]
      }
    ],
    "pagination": {
      "page": "number",
      "limit": "number",
      "total": "number",
      "totalPages": "number"
    }
  }
  ```
- **Errors**: 400 (Bad Request), 401 (Unauthorized), 403 (Forbidden), 404 (Not Found)

### GET /orders/orders
**Description**: Get all orders for the current authenticated seller
- **Headers**: Authorization: Bearer {token}
- **Query Parameters**: status (optional), page (optional), limit (optional)
- **Response (200)**:
  ```json
  {
    "orders": [
      {
        "id": "string",
        "customerId": "string",
        "customerName": "string",
        "sellerId": "string",
        "total": "number",
        "status": "string",
        "orderDate": "string",
        "items": [
          {
            "productId": "string",
            "productName": "string",
            "quantity": "number",
            "price": "number"
          }
        ]
      }
    ],
    "pagination": {
      "page": "number",
      "limit": "number",
      "total": "number",
      "totalPages": "number"
    }
  }
  ```
- **Errors**: 400 (Bad Request), 401 (Unauthorized), 403 (Forbidden), 404 (Not Found)

### PUT /orders/orders/:orderId
**Description**: Update order status
- **Headers**: Authorization: Bearer {token}
- **Request**:
  ```json
  {
    "status": "string"
  }
  ```
- **Response (200)**:
  ```json
  {
    "id": "string",
    "customerId": "string",
    "customerName": "string",
    "sellerId": "string",
    "total": "number",
    "status": "string",
    "orderDate": "string",
    "items": [
      {
        "productId": "string",
        "productName": "string",
        "quantity": "number",
        "price": "number"
      }
    ]
  }
  ```
- **Errors**: 400 (Bad Request), 401 (Unauthorized), 403 (Forbidden), 404 (Not Found), 422 (Unprocessable Entity)

## Address Endpoints

### GET /addresses/user/:userId
**Description**: Get all addresses for a specific user
- **Headers**: Authorization: Bearer {token}
- **Response (200)**:
  ```json
  {
    "addresses": [
      {
        "id": "string",
        "userId": "string",
        "name": "string",
        "street": "string",
        "city": "string",
        "state": "string",
        "zipCode": "string",
        "country": "string",
        "phoneNumber": "string",
        "isDefault": "boolean"
      }
    ]
  }
  ```
- **Errors**: 401 (Unauthorized), 403 (Forbidden), 404 (Not Found)

### POST /addresses/user/:userId
**Description**: Add a new address for a user
- **Headers**: Authorization: Bearer {token}
- **Request**:
  ```json
  {
    "name": "string",
    "street": "string",
    "city": "string",
    "state": "string",
    "zipCode": "string",
    "country": "string",
    "phoneNumber": "string",
    "isDefault": "boolean"
  }
  ```
- **Response (201)**:
  ```json
  {
    "address": {
      "id": "string",
      "userId": "string",
      "name": "string",
      "street": "string",
      "city": "string",
      "state": "string",
      "zipCode": "string",
      "country": "string",
      "phoneNumber": "string",
      "isDefault": "boolean"
    }
  }
  ```
- **Errors**: 400 (Bad Request), 401 (Unauthorized), 403 (Forbidden), 422 (Unprocessable Entity)

### PUT /addresses/:addressId
**Description**: Update an existing address
- **Headers**: Authorization: Bearer {token}
- **Request**:
  ```json
  {
    "name": "string",
    "street": "string",
    "city": "string",
    "state": "string",
    "zipCode": "string",
    "country": "string",
    "phoneNumber": "string",
    "isDefault": "boolean"
  }
  ```
- **Response (200)**:
  ```json
  {
    "address": {
      "id": "string",
      "userId": "string",
      "name": "string",
      "street": "string",
      "city": "string",
      "state": "string",
      "zipCode": "string",
      "country": "string",
      "phoneNumber": "string",
      "isDefault": "boolean"
    }
  }
  ```
- **Errors**: 400 (Bad Request), 401 (Unauthorized), 403 (Forbidden), 404 (Not Found), 422 (Unprocessable Entity)

### DELETE /addresses/:addressId
**Description**: Delete an address
- **Headers**: Authorization: Bearer {token}
- **Response (204)**: No content
- **Errors**: 401 (Unauthorized), 403 (Forbidden), 404 (Not Found)

## Payment Methods Endpoints

### GET /payment-methods/user/:userId
**Description**: Get all payment methods for a specific user
- **Headers**: Authorization: Bearer {token}
- **Response (200)**:
  ```json
  {
    "paymentMethods": [
      {
        "id": "string",
        "userId": "string",
        "type": "string",
        "cardNumber": "string",
        "cardHolderName": "string",
        "expiryMonth": "string",
        "expiryYear": "string",
        "cvv": "string",
        "isDefault": "boolean",
        "brand": "string",
        "last4": "string"
      }
    ]
  }
  ```
- **Errors**: 401 (Unauthorized), 403 (Forbidden), 404 (Not Found)

### POST /payment-methods/user/:userId
**Description**: Add a new payment method for a user
- **Headers**: Authorization: Bearer {token}
- **Request**:
  ```json
  {
    "type": "string",
    "cardNumber": "string",
    "cardHolderName": "string",
    "expiryMonth": "string",
    "expiryYear": "string",
    "cvv": "string",
    "isDefault": "boolean"
  }
  ```
- **Response (201)**:
  ```json
  {
    "paymentMethod": {
      "id": "string",
      "userId": "string",
      "type": "string",
      "cardNumber": "string",
      "cardHolderName": "string",
      "expiryMonth": "string",
      "expiryYear": "string",
      "cvv": "string",
      "isDefault": "boolean",
      "brand": "string",
      "last4": "string"
    }
  }
  ```
- **Errors**: 400 (Bad Request), 401 (Unauthorized), 403 (Forbidden), 422 (Unprocessable Entity)

### PUT /payment-methods/:paymentMethodId
**Description**: Update an existing payment method
- **Headers**: Authorization: Bearer {token}
- **Request**:
  ```json
  {
    "type": "string",
    "cardHolderName": "string",
    "isDefault": "boolean"
  }
  ```
- **Response (200)**:
  ```json
  {
    "paymentMethod": {
      "id": "string",
      "userId": "string",
      "type": "string",
      "cardNumber": "string",
      "cardHolderName": "string",
      "expiryMonth": "string",
      "expiryYear": "string",
      "cvv": "string",
      "isDefault": "boolean",
      "brand": "string",
      "last4": "string"
    }
  }
  ```
- **Errors**: 400 (Bad Request), 401 (Unauthorized), 403 (Forbidden), 404 (Not Found), 422 (Unprocessable Entity)

### DELETE /payment-methods/:paymentMethodId
**Description**: Delete a payment method
- **Headers**: Authorization: Bearer {token}
- **Response (204)**: No content
- **Errors**: 401 (Unauthorized), 403 (Forbidden), 404 (Not Found)

## Delivery/Shipping Endpoints

### GET /deliveries/user/:userId
**Description**: Get all deliveries for a specific user
- **Headers**: Authorization: Bearer {token}
- **Response (200)**:
  ```json
  {
    "deliveries": [
      {
        "id": "string",
        "orderId": "string",
        "status": "string",
        "trackingNumber": "string",
        "estimatedDelivery": "string",
        "actualDelivery": "string",
        "shippingAddress": "string",
        "carrier": "string",
        "lastUpdate": "string",
        "updates": [
          {
            "status": "string",
            "location": "string",
            "timestamp": "string",
            "description": "string"
          }
        ]
      }
    ]
  }
  ```
- **Errors**: 401 (Unauthorized), 403 (Forbidden), 404 (Not Found)

### GET /deliveries/tracking/:trackingNumber
**Description**: Get delivery information by tracking number
- **Headers**: Authorization: Bearer {token}
- **Response (200)**:
  ```json
  {
    "delivery": {
      "id": "string",
      "orderId": "string",
      "status": "string",
      "trackingNumber": "string",
      "estimatedDelivery": "string",
      "actualDelivery": "string",
      "shippingAddress": "string",
      "carrier": "string",
      "lastUpdate": "string",
      "updates": [
        {
          "status": "string",
          "location": "string",
          "timestamp": "string",
          "description": "string"
        }
      ]
    }
  }
  ```
- **Errors**: 401 (Unauthorized), 403 (Forbidden), 404 (Not Found)

### POST /deliveries
**Description**: Create a new delivery
- **Headers**: Authorization: Bearer {token}
- **Request**:
  ```json
  {
    "orderId": "string",
    "trackingNumber": "string",
    "estimatedDelivery": "string",
    "carrier": "string"
  }
  ```
- **Response (201)**:
  ```json
  {
    "delivery": {
      "id": "string",
      "orderId": "string",
      "status": "string",
      "trackingNumber": "string",
      "estimatedDelivery": "string",
      "actualDelivery": "string",
      "shippingAddress": "string",
      "carrier": "string",
      "lastUpdate": "string",
      "updates": [
        {
          "status": "string",
          "location": "string",
          "timestamp": "string",
          "description": "string"
        }
      ]
    }
  }
  ```
- **Errors**: 400 (Bad Request), 401 (Unauthorized), 403 (Forbidden), 409 (Conflict)

### PUT /deliveries/:deliveryId
**Description**: Update a delivery
- **Headers**: Authorization: Bearer {token}
- **Request**:
  ```json
  {
    "status": "string",
    "actualDelivery": "string",
    "updates": [
      {
        "status": "string",
        "location": "string",
        "timestamp": "string",
        "description": "string"
      }
    ]
  }
  ```
- **Response (200)**:
  ```json
  {
    "delivery": {
      "id": "string",
      "orderId": "string",
      "status": "string",
      "trackingNumber": "string",
      "estimatedDelivery": "string",
      "actualDelivery": "string",
      "shippingAddress": "string",
      "carrier": "string",
      "lastUpdate": "string",
      "updates": [
        {
          "status": "string",
          "location": "string",
          "timestamp": "string",
          "description": "string"
        }
      ]
    }
  }
  ```
- **Errors**: 400 (Bad Request), 401 (Unauthorized), 403 (Forbidden), 404 (Not Found)

### DELETE /deliveries/:deliveryId
**Description**: Delete a delivery
- **Headers**: Authorization: Bearer {token}
- **Response (204)**: No content
- **Errors**: 401 (Unauthorized), 403 (Forbidden), 404 (Not Found)

## Product Endpoints

### GET /products
**Description**: Get list of products with pagination
- **Query Parameters**: page (optional), limit (optional), search (optional), category (optional)
- **Response (200)**:
  ```json
  {
    "products": [
      {
        "id": "string",
        "name": "string",
        "description": "string",
        "price": "number",
        "category": "string",
        "image": "string",
        "sellerId": "string",
        "stock": "number"
      }
    ],
    "pagination": {
      "page": "number",
      "limit": "number",
      "total": "number",
      "totalPages": "number"
    }
  }
  ```
- **Errors**: 400 (Bad Request), 404 (Not Found)

### GET /products/seller/:sellerId
**Description**: Get products for a specific seller with pagination
- **Query Parameters**: page (optional), limit (optional)
- **Response (200)**:
  ```json
  {
    "products": [
      {
        "id": "string",
        "name": "string",
        "description": "string",
        "price": "number",
        "category": "string",
        "image": "string",
        "sellerId": "string",
        "stock": "number"
      }
    ],
    "pagination": {
      "page": "number",
      "limit": "number",
      "total": "number",
      "totalPages": "number"
    }
  }
  ```
- **Errors**: 400 (Bad Request), 401 (Unauthorized), 403 (Forbidden), 404 (Not Found)

### GET /products/:id
**Description**: Get product by ID
- **Response (200)**:
  ```json
  {
    "id": "string",
    "name": "string",
    "description": "string",
    "price": "number",
    "category": "string",
    "image": "string",
    "sellerId": "string",
    "stock": "number"
  }
  ```
- **Errors**: 404 (Not Found)

### POST /products
**Description**: Add new product (seller only)
- **Headers**: Authorization: Bearer {token}
- **Request**:
  ```json
  {
    "name": "string",
    "description": "string",
    "price": "number",
    "category": "string",
    "image": "string",
    "stock": "number"
  }
  ```
- **Response (201)**:
  ```json
  {
    "id": "string",
    "name": "string",
    "description": "string",
    "price": "number",
    "category": "string",
    "image": "string",
    "sellerId": "string",
    "stock": "number"
  }
  ```
- **Errors**: 400 (Bad Request), 401 (Unauthorized), 403 (Forbidden), 422 (Unprocessable Entity)

### PUT /products/:productId
**Description**: Update existing product (seller only)
- **Request**:
  ```json
  {
    "name": "string",
    "description": "string",
    "price": "number",
    "category": "string",
    "image": "string",
    "stock": "number"
  }
  ```
- **Response (200)**:
  ```json
  {
    "id": "string",
    "name": "string",
    "description": "string",
    "price": "number",
    "category": "string",
    "image": "string",
    "sellerId": "string",
    "stock": "number"
  }
  ```
- **Errors**: 400 (Bad Request), 401 (Unauthorized), 403 (Forbidden), 404 (Not Found), 422 (Unprocessable Entity)

### DELETE /products/:productId
**Description**: Delete a product (seller only)
- **Headers**: Authorization: Bearer {token}
- **Response (200)**:
  ```json
  {
    "message": "Product deleted successfully"
  }
  ```
- **Errors**: 401 (Unauthorized), 403 (Forbidden), 404 (Not Found)

### POST /products/:productId/reviews
**Description**: Add a review to a product
- **Headers**: Authorization: Bearer {token}
- **Request**:
  ```json
  {
    "rating": "number",
    "title": "string",
    "reviewText": "string"
  }
  ```
- **Response (201)**:
  ```json
  {
    "id": "string",
    "userId": "string",
    "productId": "string",
    "title": "string",
    "reviewText": "string",
    "rating": "number",
    "userName": "string",
    "createdAt": "string"
  }
  ```
- **Errors**: 400 (Bad Request), 401 (Unauthorized), 403 (Forbidden), 404 (Not Found)

## Review Endpoints

### GET /reviews/product/:productId
**Description**: Get all reviews for a specific product
- **Response (200)**:
  ```json
  {
    "success": true,
    "data": [
      {
        "id": "string",
        "userId": "string",
        "productId": "string",
        "title": "string",
        "reviewText": "string",
        "rating": "number",
        "userName": "string",
        "createdAt": "string"
      }
    ]
  }
  ```
- **Errors**: 400 (Bad Request), 404 (Not Found)

### POST /reviews
**Description**: Submit a new review for a product
- **Headers**: Authorization: Bearer {token}
- **Request**:
  ```json
  {
    "productId": "string",
    "rating": "number",
    "title": "string",
    "reviewText": "string"
  }
  ```
- **Response (201)**:
  ```json
  {
    "success": true,
    "data": {
      "id": "string",
      "userId": "string",
      "productId": "string",
      "title": "string",
      "reviewText": "string",
      "rating": "number",
      "userName": "string",
      "createdAt": "string"
    }
  }
  ```
- **Errors**: 400 (Bad Request), 401 (Unauthorized), 422 (Unprocessable Entity)

## Common Error Responses

### 400 Bad Request
```json
{
  "message": "Invalid input",
  "details": {}
}
```

### 401 Unauthorized
```json
{
  "message": "Unauthorized: Invalid or missing token"
}
```

### 403 Forbidden
```json
{
  "message": "Forbidden: You are not authorized to perform this action"
}
```

### 404 Not Found
```json
{
  "message": "Resource not found"
}
```

### 409 Conflict
```json
{
  "message": "Conflict: Resource already exists"
}
```

### 422 Unprocessable Entity
```json
{
  "message": "Unprocessable entity: Validation error"
}
```

### 429 Too Many Requests
```json
{
  "message": "Too many requests: Rate limit exceeded"
}
```

## Health Check Endpoints

### GET /
**Description**: Root endpoint for API information
- **Response (200)**:
  ```json
  {
    "message": "Welcome to Intellicart API! Visit /ui for Swagger documentation."
  }
  ```

### GET /health
**Description**: Health check endpoint
- **Response (200)**:
  ```json
  {
    "status": "ok",
    "timestamp": "string"
  }
  ```

### GET /doc
**Description**: OpenAPI specification
- **Response (200)**: OpenAPI JSON specification

### GET /ui
**Description**: Swagger UI documentation
- **Response (200)**: Interactive API documentation UI