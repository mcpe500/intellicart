# Intellicart Backend Testing Suite

This document provides an overview of the comprehensive testing suite implemented for the Intellicart backend.

## Test Structure

The tests are organized in three main categories:

### 1. Unit Tests (`tests/unit/`)
- Test individual components in isolation
- Focus on controllers and services
- Use extensive mocking to isolate functionality
- Fast execution and focused testing

### 2. Integration Tests (`tests/integration/`)
- Test interactions between components
- Focus on middleware and route integration
- Verify that components work together properly
- Include authentication middleware tests

### 3. End-to-End Tests (`tests/e2e/`)
- Test complete API workflows
- Verify real API endpoints with actual requests
- Test authentication flows, CRUD operations, and business logic
- Include database initialization and cleanup

## Running Tests

### All Tests
```bash
bun test
```

### Specific Test Categories
```bash
# Unit tests only
bun test --only unit

# Integration tests only
bun test --only integration

# E2E tests only
bun test --only e2e
```

### Specific Test File
```bash
bun test tests/e2e/auth.test.ts
```

### Test Coverage
```bash
bun test --coverage
```

## Test Setup

### Database Testing
- Tests use a backup/restore strategy for the JSON database
- Each test suite gets a clean database state
- Setup and cleanup functions ensure test isolation

### Authentication Testing
- JWT tokens are properly generated and verified in tests
- Authentication middleware is tested for both valid and invalid scenarios
- Profile endpoint testing with proper token handling

## Test Coverage

The testing suite covers:

- **Authentication API**: Registration, login, profile retrieval
- **Product API**: Get all products, get by ID, create, update, delete, add reviews
- **Order API**: Get orders by seller, update order status
- **Middleware**: Authentication and validation middleware
- **Error Handling**: Proper error responses for all edge cases
- **Validation**: Input validation for all endpoints

## Test Examples

### Unit Test Example
```typescript
it('should return 200 with token and user data on successful login', async () => {
  // Test logic here
});
```

### E2E Test Example
```typescript
it('POST /api/auth/login - should login successfully with correct credentials', async () => {
  // Full API test here
});
```

## Best Practices Implemented

- **Test Isolation**: Each test runs in a clean environment
- **Mocking**: Proper mocking of external dependencies
- **Setup/Cleanup**: Database state management
- **Error Testing**: Comprehensive error scenario testing
- **Integration Coverage**: Middleware and route integration tests
- **Realistic Scenarios**: End-to-end workflow testing