import { JWTUserPayload } from './AuthTypes';

// Extend the Hono context type to include our custom jwtPayload
declare module 'hono' {
  interface ContextVariableMap {
    jwtPayload: JWTUserPayload;
  }
}