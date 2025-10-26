/**
 * Authentication Routes Module
 *
 * This module defines all authentication-related API endpoints with proper validation
 * using Zod schemas. Each route is documented with OpenAPI specifications
 * that are automatically generated and displayed in Swagger UI.
 *
 * The routes follow RESTful conventions and include proper HTTP status codes,
 * request validation, and response schemas.
 *
 * @module authRoutes
 * @description API routes for authentication
 * @author Intellicart Team
 * @version 1.0.0
 */

import { OpenAPIHono, createRoute, z } from "@hono/zod-openapi";
import { AuthController } from "../controllers/authController";
import { verifyToken } from "../middleware/authMiddleware";

/**
 * Create a new OpenAPIHono instance for authentication routes
 * This allows automatic OpenAPI documentation generation from Zod schemas
 */
const authRoutes = new OpenAPIHono();

/**
 * Zod schema defining the structure of a User object for authentication responses
 * This schema is used for both request and response validation
 */
const AuthUserSchema = z.object({
  // Unique identifier for the user (auto-generated)
  id: z.number().openapi({
    example: 1,
    description: "Unique identifier for the user (auto-generated)",
  }),

  // User's email address (required)
  email: z.string().email().openapi({
    example: "john@example.com",
    description: "User's email address (must be valid email format)",
  }),

  // User's full name (required)
  name: z.string().openapi({
    example: "John Doe",
    description: "User's full name",
  }),

  // User's role (buyer or seller)
  role: z.string().openapi({
    example: "buyer",
    description: "User's role (buyer or seller)",
  }),

  // Creation timestamp (auto-generated)
  createdAt: z.string().datetime().openapi({
    example: new Date().toISOString(),
    description: "Timestamp when the user was created",
  }),
});

/**
 * Zod schema defining the structure for user registration
 * Used for validation of POST /api/auth/register request body
 */
const RegisterUserSchema = z.object({
  // User's email address (required, validated as email format)
  email: z
    .string()
    .email({ message: "Must be a valid email address" })
    .openapi({
      example: "john@example.com",
      description: "User's email address (required, must be valid format)",
    }),

  // User's password (required, minimum length: 6 characters)
  password: z
    .string()
    .min(6, { message: "Password must be at least 6 characters" })
    .openapi({
      example: "password123",
      description: "User's password (required, minimum 6 characters)",
    }),

  // User's full name (required, minimum length: 1 character)
  name: z.string().min(1, { message: "Name is required" }).openapi({
    example: "John Doe",
    description: "User's full name (required, minimum 1 character)",
  }),

  // User's role (optional, defaults to 'buyer')
  role: z.string().optional().openapi({
    example: "buyer",
    description:
      "User's role (buyer or seller, defaults to buyer if not provided)",
  }),
});

/**
 * Zod schema defining the structure for user login
 * Used for validation of POST /api/auth/login request body
 */
const LoginUserSchema = z.object({
  // User's email address (required, validated as email format)
  email: z
    .string()
    .email({ message: "Must be a valid email address" })
    .openapi({
      example: "john@example.com",
      description: "User's email address (required, must be valid format)",
    }),

  // User's password (required)
  password: z.string().openapi({
    example: "password123",
    description: "User's password (required)",
  }),
});

/**
 * Route: POST /api/auth/register
 * Description: Register a new user
 *
 * Request:
 * - Method: POST
 * - Path: /register (relative to /api/auth)
 * - Parameters: None
 * - Query: None
 * - Body: User registration object (validated against RegisterUserSchema)
 *
 * Response:
 * - Status: 201 Created
 * - Content-Type: application/json
 * - Body: Object containing user object and authentication token
 */
const registerRoute = createRoute({
  method: "post",
  path: "/register",
  tags: ["Authentication"], // Add tags for grouping in Swagger UI
  // Validate request body
  request: {
    body: {
      content: {
        "application/json": {
          // Request body schema
          schema: RegisterUserSchema,
        },
      },
    },
  },
  // Documentation for the successful response
  responses: {
    201: {
      description: "User registered successfully",
      content: {
        "application/json": {
          // Response body schema
          schema: z.object({
            user: AuthUserSchema,
            token: z.string().openapi({
              example: "jwt-token-here",
              description:
                "Authentication token to be used in subsequent requests",
            }),
          }),
        },
      },
    },
    409: {
      description: "User with this email already exists",
      content: {
        "application/json": {
          schema: z.object({
            error: z.string().openapi({
              example: "User with this email already exists",
              description: "Error message explaining why the request failed",
            }),
          }),
        },
      },
    },
  },
});

// Register both OpenAPI spec and the handler
authRoutes.openapi(registerRoute, AuthController.register);

/**
 * Route: POST /api/auth/login
 * Description: Login a user
 *
 * Request:
 * - Method: POST
 * - Path: /login (relative to /api/auth)
 * - Parameters: None
 * - Query: None
 * - Body: Login credentials object (validated against LoginUserSchema)
 *
 * Response:
 * - Status: 200 OK
 * - Content-Type: application/json
 * - Body: Object containing user object and authentication token
 */
const loginRoute = createRoute({
  method: "post",
  path: "/login",
  tags: ["Authentication"], // Add tags for grouping in Swagger UI
  // Validate request body
  request: {
    body: {
      content: {
        "application/json": {
          // Request body schema
          schema: LoginUserSchema,
        },
      },
    },
  },
  // Documentation for possible responses
  responses: {
    200: {
      description: "Login successful",
      content: {
        "application/json": {
          // Response body schema
          schema: z.object({
            user: AuthUserSchema,
            token: z.string().openapi({
              example: "jwt-token-here",
              description:
                "Authentication token to be used in subsequent requests",
            }),
          }),
        },
      },
    },
    401: {
      description: "Invalid email or password",
      content: {
        "application/json": {
          schema: z.object({
            error: z.string().openapi({
              example: "Invalid email or password",
              description: "Error message explaining why the request failed",
            }),
          }),
        },
      },
    },
  },
});

// Register both OpenAPI spec and the handler
authRoutes.openapi(loginRoute, AuthController.login);

/**
 * Route: GET /api/auth/me
 * Description: Get current user profile (requires valid token)
 *
 * Request:
 * - Method: GET
 * - Path: /me (relative to /api/auth)
 * - Headers: Authorization: Bearer <token>
 * - Parameters: None
 * - Query: None
 * - Body: None
 *
 * Response:
 * - Status: 200 OK
 * - Content-Type: application/json
 * - Body: User object
 */
const getCurrentUserRoute = createRoute({
  method: "get",
  path: "/me",
  tags: ["Authentication"], // Add tags for grouping in Swagger UI
  security: [{ BearerAuth: [] }], // Require authentication
  middleware: [verifyToken],
  // Documentation for possible responses
  responses: {
    200: {
      description: "Current user profile retrieved successfully",
      content: {
        "application/json": {
          // Response body schema
          schema: AuthUserSchema,
        },
      },
    },
    401: {
      description: "Unauthorized - Invalid or missing token",
      content: {
        "application/json": {
          schema: z.object({
            error: z.string().openapi({
              example: "Unauthorized",
              description: "Error message explaining why the request failed",
            }),
          }),
        },
      },
    },
  },
});

// According to the Hono Zod OpenAPI documentation, when using middleware in the route definition,
// we need to use the traditional Hono route registration method to ensure middleware is applied
authRoutes.openapi(getCurrentUserRoute);
authRoutes.get(getCurrentUserRoute.path, verifyToken, AuthController.getCurrentUser);
/**
 * Route: POST /api/auth/logout
 * Description: Logout user (invalidate token)
 *
 * Request:
 * - Method: POST
 * - Path: /logout (relative to /api/auth)
 * - Headers: Authorization: Bearer <token>
 * - Parameters: None
 * - Query: None
 * - Body: None
 *
 * Response:
 * - Status: 200 OK
 * - Content-Type: application/json
 * - Body: Success message
 */
const logoutRoute = createRoute({
  method: "post",
  path: "/logout",
  tags: ["Authentication"], // Add tags for grouping in Swagger UI
  security: [{ BearerAuth: [] }], // Require authentication
  middleware: [verifyToken],
  // Documentation for possible responses
  responses: {
    200: {
      description: "Successfully logged out",
      content: {
        "application/json": {
          schema: z.object({
            message: z.string().openapi({
              example: "Successfully logged out",
              description: "Confirmation message",
            }),
          }),
        },
      },
    },
    400: {
      description: "No token provided",
      content: {
        "application/json": {
          schema: z.object({
            error: z.string().openapi({
              example: "No token provided",
              description: "Error message explaining why the request failed",
            }),
          }),
        },
      },
    },
  },
});

// Register both OpenAPI spec and the handler with middleware
authRoutes.openapi(logoutRoute);
authRoutes.post('/logout', verifyToken, AuthController.logout);

/**
 * Route: POST /api/auth/verify
 * Description: Verify if a token is valid
 *
 * Request:
 * - Method: POST
 * - Path: /verify (relative to /api/auth)
 * - Headers: Authorization: Bearer <token>
 * - Parameters: None
 * - Query: None
 * - Body: None
 *
 * Response:
 * - Status: 200 OK
 * - Content-Type: application/json
 * - Body: Object with validation status
 */
const verifyTokenRoute = createRoute({
  method: "post",
  path: "/verify",
  tags: ["Authentication"], // Add tags for grouping in Swagger UI
  // Documentation for possible responses
  responses: {
    200: {
      description: "Token validation result",
      content: {
        "application/json": {
          schema: z.object({
            valid: z.boolean().openapi({
              example: true,
              description: "Whether the token is valid",
            }),
            user: z
              .object({
                id: z.number().openapi({
                  example: 1,
                  description: "User ID",
                }),
                email: z.string().email().openapi({
                  example: "user@example.com",
                  description: "User email",
                }),
              })
              .optional()
              .openapi({
                description:
                  "User information (only included if token is valid)",
              }),
          }),
        },
      },
    },
    400: {
      description: "No token provided",
      content: {
        "application/json": {
          schema: z.object({
            valid: z.literal(false),
          }),
        },
      },
    },
    401: {
      description: "Invalid or expired token",
      content: {
        "application/json": {
          schema: z.object({
            valid: z.literal(false),
          }),
        },
      },
    },
  },
});

// Register both OpenAPI spec and the handler
authRoutes.openapi(verifyTokenRoute, AuthController.verifyToken);

// Export the configured routes for use in the main application
export { authRoutes };
