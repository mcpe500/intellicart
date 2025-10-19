import { z } from 'zod';

export const LoginSchema = z.object({
  email: z.string().min(1).regex(/^[^\s@]+@[^\s@]+\.[^\s@]+$/, { message: 'Must be a valid email address' }).openapi({
    example: 'john@example.com',
    description: 'User\'s email address'
  }),
  password: z.string().min(1, { message: 'Password is required' }).openapi({
    example: 'password123',
    description: 'User\'s password'
  })
});

export const RegisterSchema = z.object({
  name: z.string().min(1, { message: 'Name is required' }).openapi({
    example: 'John Doe',
    description: 'User\'s full name'
  }),
  email: z.string().min(1).regex(/^[^\s@]+@[^\s@]+\.[^\s@]+$/, { message: 'Must be a valid email address' }).openapi({
    example: 'john@example.com',
    description: 'User\'s email address'
  }),
  password: z.string().min(6, { message: 'Password must be at least 6 characters' }).openapi({
    example: 'password123',
    description: 'User\'s password (min 6 characters)'
  }),
  role: z.string().optional().default('buyer').openapi({
    example: 'buyer',
    description: 'User\'s role (buyer or seller)'
  })
});

export const AuthResponseSchema = z.object({
  token: z.string().openapi({
    example: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
    description: 'JWT token for authentication'
  }),
  refreshToken: z.string().optional().openapi({
    example: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
    description: 'Refresh token for obtaining new access tokens (optional)'
  }),
  user: z.object({
    id: z.string().openapi({
      example: 'user-1234567890',
      description: 'Unique identifier for the user'
    }),
    name: z.string().openapi({
      example: 'John Doe',
      description: 'User\'s full name'
    }),
    email: z.string().email().openapi({
      example: 'john@example.com',
      description: 'User\'s email address'
    }),
    role: z.string().openapi({
      example: 'buyer',
      description: 'User\'s role (buyer or seller)'
    }),
    createdAt: z.string().optional().openapi({
      example: '2023-01-01T00:00:00.000Z',
      description: 'User creation timestamp (optional)'
    })
  })
});

export const ErrorSchema = z.object({
  error: z.string().openapi({
    example: 'User not found',
    description: 'Error message explaining why the request failed'
  })
});

export const JWTUserPayloadSchema = z.object({
  id: z.string().openapi({
    example: 'user-1234567890',
    description: 'Unique identifier for the user'
  }),
  email: z.string().email().openapi({
    example: 'john@example.com',
    description: 'User\'s email address'
  }),
  role: z.string().openapi({
    example: 'buyer',
    description: 'User\'s role (buyer or seller)'
  })
});

export const RefreshTokenSchema = z.object({
  refreshToken: z.string().openapi({
    example: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
    description: 'Refresh token used to obtain a new access token'
  })
});

export const RefreshResponseSchema = z.object({
  token: z.string().openapi({
    example: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
    description: 'New JWT token for authentication'
  }),
  refreshToken: z.string().optional().openapi({
    example: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
    description: 'New refresh token (optional)'
  })
});