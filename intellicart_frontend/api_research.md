# API Backend Research for Intellicart

## Overview

This document analyzes the current mock backend implementation in the Intellicart frontend application and outlines the requirements for transitioning to a real API backend. The analysis includes API contracts, security considerations, and recommended implementation patterns.

## Current Mock Backend Analysis

### Data Sources

- `lib/data/datasources/mock_backend.dart` - Contains mock data and business logic
- `lib/data/datasources/api_service.dart` - Current service that wraps mock backend calls

### Current Features Implemented

1. **Authentication Methods**
   - Login with email/password
   - User registration
   - User retrieval by ID

2. **Product Management**
   - Fetch all products
   - Add new products
   - Update existing products
   - Delete products
   - Fetch seller-specific products

3. **Order Management**
   - Fetch seller orders
   - Update order status

## API Contract Design

### Base URL and Error Handling

For a real backend, we'll implement the following:

- **Base URL**: `https://api.intellicart.com/v1` (or similar domain)
- **Error Handling**: Standard HTTP status codes with error details in JSON format
- **Content Type**: All requests/responses will use `application/json`

### Authentication API Endpoints

#### 1. User Registration
- **Endpoint**: `POST /auth/register`
- **Request**:
  ```json
  {
    "email": "string",
    "password": "string",
    "name": "string",
    "role": "string"
  }
  ```
- **Response** (201 Created):
  ```json
  {
    "user": {
      "id": "string",
      "email": "string",
      "name": "string",
      "role": "string",
      "createdAt": "datetime"
    },
    "token": "string"
  }
  ```
- **Possible Status Codes**: 201, 400, 409, 500

#### 2. User Login
- **Endpoint**: `POST /auth/login`
- **Request**:
  ```json
  {
    "email": "string",
    "password": "string"
  }
  ```
- **Response** (200 OK):
  ```json
  {
    "user": {
      "id": "string",
      "email": "string",
      "name": "string",
      "role": "string"
    },
    "token": "string",
    "refreshToken": "string"
  }
  ```
- **Possible Status Codes**: 200, 400, 401, 500

#### 3. Token Refresh
- **Endpoint**: `POST /auth/refresh`
- **Request**:
  ```json
  {
    "refreshToken": "string"
  }
  ```
- **Response** (200 OK):
  ```json
  {
    "token": "string",
    "refreshToken": "string"
  }
  ```

#### 4. Get Current User (with authentication)
- **Endpoint**: `GET /auth/me`
- **Headers**: `Authorization: Bearer <token>`
- **Response** (200 OK):
  ```json
  {
    "id": "string",
    "email": "string",
    "name": "string",
    "role": "string"
  }
  ```

### Product API Endpoints

#### 1. Get All Products
- **Endpoint**: `GET /products`
- **Query Parameters**:
  - `page` (integer, default: 1)
  - `limit` (integer, default: 10)
  - `search` (string, optional)
  - `category` (string, optional)
- **Response** (200 OK):
  ```json
  {
    "products": [
      {
        "id": "string",
        "name": "string",
        "description": "string",
        "price": "number",
        "originalPrice": "number",
        "imageUrl": "string",
        "sellerId": "string",
        "categoryId": "string",
        "createdAt": "datetime",
        "updatedAt": "datetime",
        "reviews": [
          {
            "id": "string",
            "title": "string",
            "reviewText": "string",
            "rating": "number",
            "userId": "string",
            "userName": "string",
            "createdAt": "datetime"
          }
        ],
        "averageRating": "number"
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

#### 2. Get Product by ID
- **Endpoint**: `GET /products/{id}`
- **Response** (200 OK):
  ```json
  {
    "product": {
      "id": "string",
      "name": "string",
      "description": "string",
      "price": "number",
      "originalPrice": "number",
      "imageUrl": "string",
      "sellerId": "string",
      "categoryId": "string",
      "createdAt": "datetime",
      "updatedAt": "datetime",
      "reviews": [
        {
          "id": "string",
          "title": "string",
          "reviewText": "string",
          "rating": "number",
          "userId": "string",
          "userName": "string",
          "createdAt": "datetime"
        }
      ],
      "averageRating": "number"
    }
  }
  ```

#### 3. Create Product (requires authentication)
- **Endpoint**: `POST /products`
- **Headers**: `Authorization: Bearer <token>`
- **Request**:
  ```json
  {
    "name": "string",
    "description": "string",
    "price": "number",
    "originalPrice": "number",
    "imageUrl": "string",
    "categoryId": "string"
  }
  ```
- **Response** (201 Created):
  ```json
  {
    "product": {
      "id": "string",
      "name": "string",
      "description": "string",
      "price": "number",
      "originalPrice": "number",
      "imageUrl": "string",
      "sellerId": "string",
      "categoryId": "string",
      "createdAt": "datetime",
      "updatedAt": "datetime"
    }
  }
  ```

#### 4. Update Product (requires authentication and ownership)
- **Endpoint**: `PUT /products/{id}`
- **Headers**: `Authorization: Bearer <token>`
- **Request**:
  ```json
  {
    "name": "string",
    "description": "string",
    "price": "number",
    "originalPrice": "number",
    "imageUrl": "string",
    "categoryId": "string"
  }
  ```
- **Response** (200 OK):
  ```json
  {
    "product": {
      "id": "string",
      "name": "string",
      "description": "string",
      "price": "number",
      "originalPrice": "number",
      "imageUrl": "string",
      "sellerId": "string",
      "categoryId": "string",
      "createdAt": "datetime",
      "updatedAt": "datetime"
    }
  }
  ```

#### 5. Delete Product (requires authentication and ownership)
- **Endpoint**: `DELETE /products/{id}`
- **Headers**: `Authorization: Bearer <token>`
- **Response** (204 No Content)

#### 6. Get Seller Products
- **Endpoint**: `GET /products/seller/{sellerId}`
- **Query Parameters**:
  - `page` (integer, default: 1)
  - `limit` (integer, default: 10)
- **Response** (200 OK):
  ```json
  {
    "products": [
      {
        "id": "string",
        "name": "string",
        "description": "string",
        "price": "number",
        "originalPrice": "number",
        "imageUrl": "string",
        "categoryId": "string",
        "createdAt": "datetime",
        "updatedAt": "datetime"
      }
    ]
  }
  ```

### Order API Endpoints

#### 1. Get Seller Orders (requires authentication)
- **Endpoint**: `GET /orders/seller`
- **Headers**: `Authorization: Bearer <token>`
- **Query Parameters**:
  - `status` (string, optional, e.g., "pending", "shipped", "delivered")
  - `page` (integer, default: 1)
  - `limit` (integer, default: 10)
- **Response** (200 OK):
  ```json
  {
    "orders": [
      {
        "id": "string",
        "customerId": "string",
        "customerName": "string",
        "total": "number",
        "status": "string",
        "orderDate": "datetime",
        "items": [
          {
            "productId": "string",
            "productName": "string",
            "quantity": "number",
            "price": "number"
          }
        ]
      }
    ]
  }
  ```

#### 2. Update Order Status (requires authentication)
- **Endpoint**: `PUT /orders/{id}/status`
- **Headers**: `Authorization: Bearer <token>`
- **Request**:
  ```json
  {
    "status": "string" // e.g., "pending", "processing", "shipped", "delivered", "cancelled"
  }
  ```
- **Response** (200 OK):
  ```json
  {
    "order": {
      "id": "string",
      "customerId": "string",
      "customerName": "string",
      "total": "number",
      "status": "string",
      "orderDate": "datetime",
      "items": [
        {
          "productId": "string",
          "productName": "string",
          "quantity": "number",
          "price": "number"
        }
      ]
    }
  }
  ```

#### 3. Get User Orders (requires authentication)
- **Endpoint**: `GET /orders/user`
- **Headers**: `Authorization: Bearer <token>`
- **Response** (200 OK):
  ```json
  {
    "orders": [
      {
        "id": "string",
        "total": "number",
        "status": "string",
        "orderDate": "datetime",
        "items": [
          {
            "productId": "string",
            "productName": "string",
            "quantity": "number",
            "price": "number"
          }
        ]
      }
    ]
  }
  ```

## Security Considerations

### Authentication & Authorization

1. **JWT Tokens**: Implement JSON Web Tokens for session management
2. **HTTPS**: All API endpoints must be served over HTTPS
3. **Token Refresh**: Implement refresh token mechanism for better security
4. **Role-based Access Control**: Different permissions for buyers and sellers

### Data Protection

1. **Password Security**: 
   - Never store plain text passwords
   - Use bcrypt or similar for password hashing
   - Implement proper password strength requirements

2. **Input Validation**:
   - Validate all inputs on the server side
   - Sanitize user inputs to prevent injection attacks
   - Implement rate limiting to prevent abuse

3. **Data Privacy**:
   - Don't expose sensitive user information unnecessarily
   - Implement proper user data access controls
   - Use OAuth for third-party integrations if needed

### API Security

1. **Rate Limiting**: Prevent API abuse through rate limiting
2. **CORS Policy**: Configure proper CORS settings to prevent XSS attacks
3. **API Keys**: For backend services, implement API key authentication
4. **Request Size Limits**: Prevent large payload attacks

### Frontend Security

1. **Secure Token Storage**: Store JWT tokens securely (e.g., secure HTTP-only cookies or secure local storage)
2. **Input Sanitization**: Sanitize all user inputs before sending to the API
3. **Error Handling**: Don't expose internal server errors to users

## Implementation Recommendations

### HTTP Client Setup

Use `http` or `dio` package for API calls with the following configuration:

```dart
class ApiClient {
  static const String baseUrl = 'https://api.intellicart.com/v1';
  
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: 10000,
      receiveTimeout: 10000,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );
  
  // Add interceptors for token management
  void addAuthInterceptors(String token) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['Authorization'] = 'Bearer $token';
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          if (error.response?.statusCode == 401) {
            // Handle unauthorized access
          }
          return handler.next(error);
        },
      ),
    );
  }
}
```

### DTOs and Models

Create separate DTOs (Data Transfer Objects) for API communications:

```dart
// Example User DTO for API responses
class UserDto {
  final String id;
  final String email;
  final String name;
  final String role;
  
  UserDto({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
  });
  
  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      role: json['role'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
    };
  }
}
```

### Error Handling with Comprehensive Status Codes

Implement proper error handling with custom exceptions that handle all common HTTP status codes:

```dart
class ApiException implements Exception {
  final int statusCode;
  final String message;
  final String? serverMessage;
  
  ApiException(this.statusCode, this.message, {this.serverMessage});
  
  factory ApiException.fromDioException(DioException e) {
    String message = "An unknown error occurred";
    String? serverMessage;
    
    // Extract server message if available
    if (e.response?.data != null && e.response?.data is Map<String, dynamic>) {
      final data = e.response!.data as Map<String, dynamic>;
      serverMessage = data['message'] ?? data['error'];
    }
    
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return ApiException(0, "Connection timeout", serverMessage: serverMessage);
      case DioExceptionType.sendTimeout:
        return ApiException(0, "Send timeout", serverMessage: serverMessage);
      case DioExceptionType.receiveTimeout:
        return ApiException(0, "Receive timeout", serverMessage: serverMessage);
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? 0;
        
        switch (statusCode) {
          case 200:
          case 201:
          case 204:
            // These should not trigger errors, but if they do, it might be a logic error
            return ApiException(statusCode, "Unexpected response", serverMessage: serverMessage);
          case 400:
            return ApiException(statusCode, "Bad request - Please check your input", serverMessage: serverMessage);
          case 401:
            return ApiException(statusCode, "Unauthorized - Please log in again", serverMessage: serverMessage);
          case 403:
            return ApiException(statusCode, "Forbidden - You don't have permission to access this resource", serverMessage: serverMessage);
          case 404:
            return ApiException(statusCode, "Resource not found", serverMessage: serverMessage);
          case 409:
            return ApiException(statusCode, "Conflict - The request could not be completed due to a conflict", serverMessage: serverMessage);
          case 422:
            return ApiException(statusCode, "Unprocessable entity - Validation error", serverMessage: serverMessage);
          case 429:
            return ApiException(statusCode, "Too many requests - Please try again later", serverMessage: serverMessage);
          case 500:
            return ApiException(statusCode, "Internal server error - Please try again later", serverMessage: serverMessage);
          case 502:
            return ApiException(statusCode, "Bad gateway - Server temporarily unavailable", serverMessage: serverMessage);
          case 503:
            return ApiException(statusCode, "Service unavailable - Server is temporarily unavailable", serverMessage: serverMessage);
          case 504:
            return ApiException(statusCode, "Gateway timeout", serverMessage: serverMessage);
          default:
            return ApiException(statusCode, e.response?.statusMessage ?? "Server error", serverMessage: serverMessage);
        }
      case DioExceptionType.cancel:
        return ApiException(0, "Request cancelled", serverMessage: serverMessage);
      case DioExceptionType.badCertificate:
        return ApiException(0, "Bad certificate", serverMessage: serverMessage);
      case DioExceptionType.connectionError:
        return ApiException(0, "Connection error", serverMessage: serverMessage);
      default:
        return ApiException(0, "Something went wrong", serverMessage: serverMessage);
    }
  }
}
```

### HTTP Status Code Reference for Intellicart API

#### Success Codes
- **200 OK**: Request successful (e.g., GET, PUT operations)
- **201 Created**: Resource successfully created (e.g., POST operations)
- **204 No Content**: Request successful, no content returned (e.g., DELETE operations)

#### Client Error Codes
- **400 Bad Request**: Request is invalid or malformed (e.g., invalid JSON, missing required fields)
- **401 Unauthorized**: Authentication required or token expired
- **403 Forbidden**: User authenticated but lacks permission for the resource
- **404 Not Found**: Requested resource does not exist
- **409 Conflict**: Resource conflict (e.g., duplicate email during registration)
- **422 Unprocessable Entity**: Validation error (e.g., invalid input format)
- **429 Too Many Requests**: Rate limiting applied

#### Server Error Codes
- **500 Internal Server Error**: Generic server error
- **502 Bad Gateway**: Server acting as gateway received invalid response
- **503 Service Unavailable**: Server temporarily unable to handle request
- **504 Gateway Timeout**: Gateway did not receive timely response

### Recommended Error Handling Strategy

1. **For Authentication Errors (401)**:
   - Clear the stored token
   - Redirect user to login page
   - Show appropriate message

2. **For Rate Limiting (429)**:
   - Implement exponential backoff
   - Show message to user to try later
   - Consider implementing local queuing mechanism

3. **For Validation Errors (400, 422)**:
   - Show specific field validation messages
   - Highlight problematic fields in UI

4. **For Resource Not Found (404)**:
   - Redirect to appropriate error page
   - Show user-friendly "not found" message

5. **For Server Errors (5xx)**:
   - Show generic error message
   - Log error details for debugging
   - Allow retry after a delay

## Security Checklist for Implementation

- [ ] Implement JWT authentication
- [ ] Add HTTPS enforcement
- [ ] Implement input validation and sanitization
- [ ] Add rate limiting to API endpoints
- [ ] Configure proper CORS policy
- [ ] Implement secure password storage (hashing)
- [ ] Add proper error handling without exposing sensitive info
- [ ] Set up secure token storage
- [ ] Implement role-based access control
- [ ] Add API request size limits
- [ ] Implement logging for security monitoring
- [ ] Add security headers for API responses

## Conclusion

Transitioning from a mock backend to a real API will involve:
1. Replacing mock data calls with HTTP requests to real endpoints
2. Implementing JWT-based authentication
3. Adding proper error handling and security measures
4. Creating DTOs for API communication
5. Testing all API endpoints with real data

This transition will enhance the application's functionality, security, and scalability.