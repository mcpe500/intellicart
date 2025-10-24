# Intellicart Backend - OpenAPI Documentation

This document describes how to access and use the OpenAPI documentation for the Intellicart API.

## Endpoints

### OpenAPI JSON Documentation
- **Path**: `/doc`
- **Method**: `GET`
- **Description**: Returns the OpenAPI specification in JSON format

### Swagger UI
- **Path**: `/ui`
- **Method**: `GET`
- **Description**: Interactive API documentation interface

### OpenAPI YAML Documentation
- **Path**: `/swagger.yaml`
- **Method**: `GET`
- **Description**: Returns the OpenAPI specification in YAML format

## Generation Script

The `swagger.yaml` file can be generated manually using the following command:

```bash
bun run generate-openapi
```

This will generate a `swagger.yaml` file in the root directory with the complete OpenAPI specification.

## How It Works

The API uses Hono with Zod validation schemas to automatically generate OpenAPI documentation. 
The `/swagger.yaml` endpoint serves either:
1. A static `swagger.yaml` file if it exists
2. Dynamically generated YAML from the current API routes if no static file exists

The generation script ensures the YAML file includes all required OpenAPI metadata (version, title, description, etc.).