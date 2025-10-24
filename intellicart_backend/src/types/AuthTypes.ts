import { Context } from 'hono';
import { sign } from 'hono/jwt';

export interface LoginCredentials {
  email: string;
  password: string;
}

export interface AuthResponse {
  token: string;
  refreshToken?: string;
  user: {
    id: string;
    name: string;
    email: string;
    role: string;
    createdAt?: string;
  };
}

export interface RefreshTokenRequest {
  refreshToken: string;
}

export interface RefreshTokenResponse {
  token: string;
  refreshToken?: string;
}

export interface JWTUserPayload {
  id: string;
  email: string;
  role: string;
  [key: string]: any; // Index signature to be compatible with Hono JWT
}