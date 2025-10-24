import { sign } from 'hono/jwt';
import { db } from '../database/db_service';
import { JWTUserPayload, AuthResponse } from '../types/AuthTypes';
import { User } from '../types/UserTypes';
import { Logger } from '../utils/logger';

export class AuthService {
  private static getSecret(): string {
    const secret = process.env.JWT_SECRET;
    if (!secret) {
      Logger.error('JWT_SECRET not set in environment variables');
      throw new Error('JWT_SECRET not configured');
    }
    return secret;
  }

  static async generateTokens(user: User): Promise<{ token: string; refreshToken: string }> {
    const secret = this.getSecret();
    
    const payload: JWTUserPayload = {
      id: user.id,
      email: user.email,
      role: user.role,
    };

    const token = await sign(payload, secret);
    const refreshToken = await sign({ ...payload, type: 'refresh' }, secret + '_refresh');

    return { token, refreshToken };
  }

  static async createAuthResponse(user: User): Promise<AuthResponse> {
    const { token, refreshToken } = await this.generateTokens(user);

    return {
      token,
      refreshToken,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
        createdAt: user.createdAt,
      },
    };
  }

  static async validateCredentials(email: string, password: string): Promise<User | null> {
    const user = await db().getUserByEmail(email);
    if (!user) {
      return null;
    }
    // In production, compare hashed passwords here
    return user;
  }
}
