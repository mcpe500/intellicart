# Intellicart Data Source Analysis

## Overview
This document analyzes the Intellicart frontend application to determine which data should be stored in local SQLite database versus which data should use the cloud backend API service.

## Current Data Sources

### 1. API Service (`api_service.dart`)
The API service handles all communication with the remote backend server and manages:

- **Authentication**: Login, registration
- **User Management**: Retrieving user information by ID
- **Product Management**: 
  - Fetching products (with pagination, search, and category filtering)
  - Adding, updating, and deleting products
  - Fetching seller-specific products
- **Order Management**:
  - Fetching seller orders (with status filtering)
  - Updating order status
- **Token Management**: Authentication tokens

### 2. SQLite Helper (`sqlite_helper.dart`)
The SQLite helper manages local data storage:

- **App State**: Application mode (buyer/seller)
- **Product Cache**: Basic product information (name, description, price, original price, image URL)
- **Reviews**: Basic placeholder (commented as needing separate table in future)

### 3. Mock Backend (`mock_backend.dart`)
The mock backend provides in-memory data storage for development:

- **User Data**: Email, name, role
- **Product Data**: Detailed product information including reviews
- **Order Data**: Customer orders with status
- **Password Storage**: In-memory password storage (for development only)

## Recommended Data Distribution Strategy

### Local SQLite Storage
The following data types should be stored using SQLite for better performance and offline functionality:

#### 1. Application State
- App mode (buyer/seller) - Already implemented
- User preferences and settings
- UI configuration (theme, language)

#### 2. Cached Product Data
- Product catalogs for offline browsing
- Favorite/liked products
- Recently viewed products
- Search history and filters

#### 3. Temporary Shopping Cart
- Items added to cart before checkout
- Wishlist items
- Shopping cart preferences

#### 4. User Preferences
- Language settings
- Theme preferences
- Filter and sort settings
- Local browsing history

#### 5. Offline Queue
- Pending actions when offline
- Draft orders ready to submit when online
- Local updates pending sync

### Cloud Backend (API Service)
The following data types must be handled by the cloud backend for security, consistency, and business requirements:

#### 1. Authentication and Security
- User login credentials
- Password management
- Account registration
- Authentication tokens
- Session management

#### 2. Sensitive User Data
- Personal information
- Payment information
- Order history
- Account settings

#### 3. Real-time Product Operations
- Live inventory counts
- Real-time pricing
- Product availability
- Stock level updates
- New product creation

#### 4. Order Processing
- Order creation
- Payment processing
- Shipping information
- Order status updates
- Order tracking

#### 5. User-Generated Content
- Product reviews and ratings
- User comments
- Feedback and testimonials

#### 6. Business Operations
- Seller dashboard data
- Sales analytics
- Business metrics
- Administrative functions

### Hybrid Approach (Recommended)
For optimal user experience, implement a hybrid approach where:

#### 1. Products
- Fetch from cloud backend and cache in SQLite with TTL (time-to-live)
- Allow offline browsing of cached products
- Sync with backend when connection is available
- Show indicators for potentially outdated information

#### 2. Shopping Cart
- Store locally in SQLite initially
- Sync with backend when user logs in or at checkout
- Merge cloud and local cart if both exist

#### 3. Orders
- Store pending orders locally when offline
- Submit to backend when connection is available
- Maintain local history for quick access

#### 4. User Preferences
- Store non-sensitive preferences locally
- Sync sensitive preferences to cloud for cross-device access

## Implementation Recommendations

### 1. Enhance SQLite Schema
Consider adding tables for:
- Shopping cart items
- User preferences
- Review cache
- Order queue
- Recently viewed items

### 2. Implement Caching Strategy
- Set appropriate TTL for cached data
- Implement cache invalidation
- Provide mechanisms for manual refresh

### 3. Offline-First Architecture
- Design UI to handle offline states gracefully
- Implement background sync when online
- Provide clear indicators of online/offline status

### 4. Data Synchronization
- Implement conflict resolution for offline changes
- Handle data synchronization when back online
- Preserve user data across app sessions

## Conclusion
The Intellicart application should adopt a hybrid approach where authentication, real-time operations, and sensitive data use the cloud backend API service, while application state, caching, preferences, and offline functionality use local SQLite storage. This approach provides the best user experience while maintaining security and data consistency.