import { Context } from 'hono';
import { db } from '../database/db_service';
import { JWTUserPayload } from '../types/AuthTypes';
import { Logger } from '../utils/logger';
import { User } from '../types/UserTypes';

export class UserController {
  static async updateUserInfo(c: Context) {
    try {
      const jwtPayload = c.get('jwtPayload') as JWTUserPayload;
      if (!jwtPayload) {
        Logger.warn('Update user info failed: No JWT payload');
        return c.json({ error: 'Authentication required' }, 401);
      }

      // Get userId from path parameters (can be either 'userId' or 'id' depending on route)
      let userId = c.req.param('userId');
      if (!userId) {
        userId = c.req.param('id');
      }
      
      // Check if user is authorized to update this account
      if (jwtPayload.id !== userId) {
        Logger.warn(`Update user info failed: Unauthorized access to user ${userId} by ${jwtPayload.id}`);
        return c.json({ error: 'User not authorized to update this account' }, 403);
      }

      const { name, phoneNumber } = await c.req.json();
      
      // Validate request body
      if (name === undefined && phoneNumber === undefined) {
        return c.json({ error: 'At least one field (name or phoneNumber) must be provided' }, 400);
      }

      // Update user information in database
      const userData: Partial<User> = {};
      if (name !== undefined) userData.name = name;
      if (phoneNumber !== undefined) userData.phoneNumber = phoneNumber;
      
      const updatedUser = await db().updateUser(userId, userData);

      if (!updatedUser) {
        Logger.warn(`Update user info failed: User not found: ${userId}`);
        return c.json({ error: 'User not found' }, 404);
      }

      Logger.info(`User info updated successfully for user: ${userId}`);
      return c.json({
        user: {
          id: updatedUser.id,
          email: updatedUser.email,
          name: updatedUser.name,
          role: updatedUser.role,
          phoneNumber: updatedUser.phoneNumber
        }
      });
    } catch (error) {
      Logger.error('Update user info error:', { error: (error as Error).message, stack: (error as Error).stack });
      return c.json({ error: 'Internal server error' }, 500);
    }
  }

  // Alias for the existing route - matches the expected name in userRoutes.ts
  static async updateUser(c: Context) {
    return UserController.updateUserInfo(c);
  }

  static async requestEmailChange(c: Context) {
    try {
      const jwtPayload = c.get('jwtPayload') as JWTUserPayload;
      if (!jwtPayload) {
        Logger.warn('Request email change failed: No JWT payload');
        return c.json({ error: 'Authentication required' }, 401);
      }

      const { reason, phoneNumber } = await c.req.json();

      // Validate request body
      if (!reason || !phoneNumber) {
        return c.json({ error: 'Reason and phoneNumber are required' }, 400);
      }

      // In a real implementation, you would send an OTP/SMS to the old email
      // For now, we'll just log the request
      Logger.info(`Email change request for user ${jwtPayload.id}: reason=${reason}, phoneNumber=${phoneNumber}`);

      // Simulate rate limiting check (in a real app you'd check this against a store)
      // const recentRequests = await checkRateLimit(jwtPayload.id, 'email_change');
      // if (recentRequests > 5) {
      //   return c.json({ error: 'Rate limit exceeded' }, 429);
      // }

      // Store the email change request (in a real app you'd use a separate table)
      // await storeEmailChangeRequest(jwtPayload.id, newEmail, reason, phoneNumber);
      
      Logger.info(`Email change request successful for user: ${jwtPayload.id}`);
      return c.json({ message: 'Email change request successful' });
    } catch (error) {
      Logger.error('Request email change error:', { error: (error as Error).message, stack: (error as Error).stack });
      return c.json({ error: 'Internal server error' }, 500);
    }
  }

  static async verifyPhone(c: Context) {
    try {
      const jwtPayload = c.get('jwtPayload') as JWTUserPayload;
      if (!jwtPayload) {
        Logger.warn('Verify phone failed: No JWT payload');
        return c.json({ error: 'Authentication required' }, 401);
      }

      const { phoneNumber, otp } = await c.req.json();

      // Validate request body
      if (!phoneNumber || !otp) {
        return c.json({ error: 'phoneNumber and otp are required' }, 400);
      }

      // In a real implementation, you would verify the OTP against a store
      // For now, we'll just validate length (in a real app you'd check if it matches what was sent)
      if (otp.length !== 6) {
        return c.json({ error: 'Invalid OTP code' }, 400);
      }

      // Simulate OTP verification (in a real app you'd check this against a store)
      // const isValidOtp = await verifyOtp(jwtPayload.id, phoneNumber, otp);
      // if (!isValidOtp) {
      //   return c.json({ error: 'Invalid OTP code' }, 401);
      // }

      Logger.info(`Phone number verified for user: ${jwtPayload.id}, phoneNumber: ${phoneNumber}`);
      return c.json({ message: 'Phone number verified successfully' });
    } catch (error) {
      Logger.error('Verify phone error:', { error: (error as Error).message, stack: (error as Error).stack });
      return c.json({ error: 'Internal server error' }, 500);
    }
  }

  static async requestPhoneChange(c: Context) {
    try {
      const jwtPayload = c.get('jwtPayload') as JWTUserPayload;
      if (!jwtPayload) {
        Logger.warn('Request phone change failed: No JWT payload');
        return c.json({ error: 'Authentication required' }, 401);
      }

      const { reason, newPhoneNumber } = await c.req.json();

      // Validate request body
      if (!reason || !newPhoneNumber) {
        return c.json({ error: 'reason and newPhoneNumber are required' }, 400);
      }

      // In a real implementation, you would send an OTP to the new phone number
      // For now, we'll just log the request
      Logger.info(`Phone change request for user ${jwtPayload.id}: reason=${reason}, newPhoneNumber=${newPhoneNumber}`);

      // Store the phone change request (in a real app you'd use a separate table)
      // await storePhoneChangeRequest(jwtPayload.id, newPhoneNumber, reason);
      
      Logger.info(`Phone change request successful for user: ${jwtPayload.id}`);
      return c.json({ message: 'Phone change request successful' });
    } catch (error) {
      Logger.error('Request phone change error:', { error: (error as Error).message, stack: (error as Error).stack });
      return c.json({ error: 'Internal server error' }, 500);
    }
  }

  static async updatePhoneAfterVerification(c: Context) {
    try {
      const jwtPayload = c.get('jwtPayload') as JWTUserPayload;
      if (!jwtPayload) {
        Logger.warn('Update phone after verification failed: No JWT payload');
        return c.json({ error: 'Authentication required' }, 401);
      }

      const { newPhoneNumber, otp } = await c.req.json();

      // Validate request body
      if (!newPhoneNumber || !otp) {
        return c.json({ error: 'newPhoneNumber and otp are required' }, 400);
      }

      // In a real implementation, you would verify the OTP against a store
      // For now, we'll just validate length (in a real app you'd check if it matches what was sent)
      if (otp.length !== 6) {
        return c.json({ error: 'Invalid OTP code' }, 400);
      }

      // In a real implementation, you would verify the OTP first
      // const isValidOtp = await verifyOtp(jwtPayload.id, newPhoneNumber, otp);
      // if (!isValidOtp) {
      //   return c.json({ error: 'Invalid OTP code' }, 401);
      // }

      // Update the user's phone number in the database
      const userData: Partial<User> = { phoneNumber: newPhoneNumber };
      const updatedUser = await db().updateUser(jwtPayload.id, userData);

      if (!updatedUser) {
        Logger.warn(`Update phone after verification failed: User not found: ${jwtPayload.id}`);
        return c.json({ error: 'User not found' }, 404);
      }

      Logger.info(`Phone number updated successfully for user: ${jwtPayload.id}, newPhoneNumber: ${newPhoneNumber}`);
      return c.json({ message: 'Phone number updated successfully' });
    } catch (error) {
      Logger.error('Update phone after verification error:', { error: (error as Error).message, stack: (error as Error).stack });
      return c.json({ error: 'Internal server error' }, 500);
    }
  }
}