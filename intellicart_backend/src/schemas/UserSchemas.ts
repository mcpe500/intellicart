import { z } from 'zod';

// Existing schemas (likely from original file)
export const UserSchema = z.object({
  id: z.string(),
  name: z.string(),
  email: z.string().email(),
  role: z.string(),
  phoneNumber: z.string().optional(),
  createdAt: z.string(),
});

export const UserIdParamSchema = z.object({
  id: z.string(),
});

export const CreateUserSchema = z.object({
  name: z.string().min(1, 'Name is required'),
  email: z.string().email('Invalid email format'),
  password: z.string().min(6, 'Password must be at least 6 characters'),
  role: z.string().optional(),
});

// Update User Information request body (for the new user management feature)
export const UpdateUserRequestSchema = z.object({
  name: z.string().optional(),
  phoneNumber: z.string().optional(),
});

// Update User Schema (for compatibility with existing PUT endpoint)
export const UpdateUserSchema = z.object({
  name: z.string().optional(),
  email: z.string().email().optional(),
  role: z.string().optional(),
  phoneNumber: z.string().optional(),
});

// Response schema for updated user
export const UpdateUserResponseSchema = z.object({
  user: z.object({
    id: z.string(),
    email: z.string().email(),
    name: z.string(),
    role: z.string(),
    phoneNumber: z.string().optional(),
  }),
});

// Request Email Change request body
export const RequestEmailChangeRequestSchema = z.object({
  reason: z.enum([
    'forgot_password',
    'want_different_email',
    'security_concerns',
    'other'
  ]),
  phoneNumber: z.string(),
});

// Verify Phone request body
export const VerifyPhoneRequestSchema = z.object({
  phoneNumber: z.string(),
  otp: z.string().length(6),
});

// Request Phone Change request body
export const RequestPhoneChangeRequestSchema = z.object({
  reason: z.enum([
    'forgot_old_phone',
    'changed_phone_number',
    'privacy_concerns',
    'security_reasons',
    'switched_to_new_carrier',
    'other'
  ]),
  newPhoneNumber: z.string(),
});

// Update Phone After Verification request body
export const UpdatePhoneRequestSchema = z.object({
  newPhoneNumber: z.string(),
  otp: z.string().length(6),
});

// Error response schema (reusing existing if it exists)
export const ErrorSchema = z.object({
  error: z.string(),
  details: z.string().optional(),
});

export const DeleteUserResponseSchema = z.object({
  message: z.string(),
  user: UserSchema,
});