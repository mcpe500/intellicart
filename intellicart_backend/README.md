# Intellicart Backend

## Prerequisites

- [Bun](https://bun.sh/) installed globally (or Node.js with npm)
- Firebase project with Firestore enabled
- Firebase service account key for authentication

## Setup

1. Install dependencies:
```bash
bun install
# or
npm install
```

2. Configure Firebase:
   - Copy `.env.example` to `.env`
   - Fill in your Firebase project details in the `.env` file

3. Run the development server:
```bash
bun run dev
# or
npm run dev
```

## Firebase Configuration

This backend uses Firebase Firestore for data storage. You need to:

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Enable Firestore in your Firebase project
3. Create a service account and download the private key
4. Add your Firebase credentials to the `.env` file

## API Documentation

API documentation is available at:
- `/doc` - OpenAPI specification
- `/ui` - Swagger UI interface

## Available Scripts

- `bun run dev` - Start development server with hot reloading
- `bun run start` - Start production server

## API Endpoints

- `GET /api/users` - Get all users
- `GET /api/users/:id` - Get user by ID
- `POST /api/users` - Create new user
- `PUT /api/users/:id` - Update existing user
- `DELETE /api/users/:id` - Delete user
- `GET /health` - Health check endpoint
