import { OpenAPIHono, createRoute } from '@hono/zod-openapi';
import { AddressController } from '../controllers/AddressController';
import { 
  AddressSchema, 
  CreateAddressSchema, 
  UpdateAddressSchema, 
  AddressIdParamSchema, 
  UserIdParamSchema, 
  ErrorSchema,
  DeleteAddressResponseSchema
} from '../schemas/AddressSchemas';
import { authMiddleware } from '../middleware/auth';

const addressRoutes = new OpenAPIHono();

// Get all addresses for a specific user
const getUserAddressesRoute = createRoute({
  method: 'get',
  path: '/user/{userId}',
  tags: ['Addresses'],
  middleware: [authMiddleware],
  security: [{ BearerAuth: [] }],
  request: {
    params: UserIdParamSchema,
  },
  responses: {
    200: {
      description: 'Returns all addresses for the specified user',
      content: {
        'application/json': {
          schema: AddressSchema.array(),
        },
      },
    },
    401: {
      description: 'Unauthorized: Invalid or missing token',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
    403: {
      description: 'Forbidden: You are not authorized to access these addresses',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
    404: {
      description: 'User not found or has no addresses',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
  },
});

addressRoutes.openapi(getUserAddressesRoute, AddressController.getUserAddresses);

// Add a new address for a user
const createAddressRoute = createRoute({
  method: 'post',
  path: '/user/{userId}',
  tags: ['Addresses'],
  middleware: [authMiddleware],
  security: [{ BearerAuth: [] }],
  request: {
    params: UserIdParamSchema,
    body: {
      content: {
        'application/json': {
          schema: CreateAddressSchema,
        },
      },
    },
  },
  responses: {
    201: {
      description: 'Address created successfully',
      content: {
        'application/json': {
          schema: AddressSchema,
        },
      },
    },
    400: {
      description: 'Invalid input',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
    401: {
      description: 'Unauthorized: Invalid or missing token',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
    403: {
      description: 'Forbidden: You are not authorized to add an address for this user',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
  },
});

addressRoutes.openapi(createAddressRoute, AddressController.createAddress);

// Update an existing address
const updateAddressRoute = createRoute({
  method: 'put',
  path: '/{id}',
  tags: ['Addresses'],
  middleware: [authMiddleware],
  security: [{ BearerAuth: [] }],
  request: {
    params: AddressIdParamSchema,
    body: {
      content: {
        'application/json': {
          schema: UpdateAddressSchema,
        },
      },
    },
  },
  responses: {
    200: {
      description: 'Address updated successfully',
      content: {
        'application/json': {
          schema: AddressSchema,
        },
      },
    },
    400: {
      description: 'Invalid input',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
    401: {
      description: 'Unauthorized: Invalid or missing token',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
    403: {
      description: 'Forbidden: You are not authorized to update this address',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
    404: {
      description: 'Address not found',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
  },
});

addressRoutes.openapi(updateAddressRoute, AddressController.updateAddress);

// Delete an address
const deleteAddressRoute = createRoute({
  method: 'delete',
  path: '/{id}',
  tags: ['Addresses'],
  middleware: [authMiddleware],
  security: [{ BearerAuth: [] }],
  request: {
    params: AddressIdParamSchema,
  },
  responses: {
    204: {
      description: 'Address deleted successfully',
    },
    401: {
      description: 'Unauthorized: Invalid or missing token',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
    403: {
      description: 'Forbidden: You are not authorized to delete this address',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
    404: {
      description: 'Address not found',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
  },
});

addressRoutes.openapi(deleteAddressRoute, AddressController.deleteAddress);

export { addressRoutes };