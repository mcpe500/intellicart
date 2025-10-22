import { OpenAPIHono } from '@hono/zod-openapi';
import { writeFileSync } from 'fs';
import { join } from 'path';
import { stringify } from 'yaml';
import app from '../src/index';

// Function to generate OpenAPI specification in YAML format
async function generateOpenApiYaml() {
  try {
    // Get the OpenAPI document from the Hono app (this contains just the paths and components)
    const openApiDoc = app.getOpenAPIDocument({
      openapi: '3.1.0',
      info: {
        title: 'Intellicart API',
        version: '1.0.0',
      },
    });
    
    // Create a clean copy without functions for YAML serialization
    const cleanOpenApiDoc = JSON.parse(JSON.stringify(openApiDoc, (key, value) => {
      // Skip functions and undefined values
      if (typeof value === 'function' || value === undefined) {
        return undefined;
      }
      return value;
    }));
    
    // Create the complete OpenAPI specification with metadata
    const completeOpenApiSpec = {
      openapi: '3.1.0',
      info: {
        title: 'Intellicart API',
        version: '1.0.0',
        description: 'Auto-generated API documentation with Zod + Hono',
      },
      tags: [
        {
          name: 'Authentication',
          description: 'Authentication related endpoints for user login and registration'
        },
        {
          name: 'Users',
          description: 'Operations related to user management'
        },
        {
          name: 'Products',
          description: 'Operations related to product management'
        },
        {
          name: 'Orders',
          description: 'Operations related to order management'
        },
        {
          name: 'Reviews',
          description: 'Operations related to product reviews'
        },
        {
          name: 'Addresses',
          description: 'Operations related to user addresses'
        },
        {
          name: 'Payment Methods',
          description: 'Operations related to user payment methods'
        },
        {
          name: 'Deliveries',
          description: 'Operations related to order deliveries and tracking'
        }
      ],
      ...cleanOpenApiDoc, // This adds paths, components, etc.
    };
    
    // Convert to YAML format
    const yamlString = stringify(completeOpenApiSpec, { indent: 2 });
    
    // Define output path
    const outputPath = join(process.cwd(), 'swagger.yaml');
    
    // Write the YAML to file
    writeFileSync(outputPath, yamlString);
    
    console.log(`✅ OpenAPI specification successfully generated at: ${outputPath}`);
    console.log(`📋 Generated specification contains:`);
    console.log(`   - ${completeOpenApiSpec.paths ? Object.keys(completeOpenApiSpec.paths).length : 0} endpoints`);
    console.log(`   - ${completeOpenApiSpec.tags ? completeOpenApiSpec.tags.length : 0} tags`);
    console.log(`   - Title: ${completeOpenApiSpec.info?.title || 'N/A'}`);
    console.log(`   - Version: ${completeOpenApiSpec.info?.version || 'N/A'}`);
  } catch (error) {
    console.error('❌ Error generating OpenAPI YAML:', error);
    process.exit(1);
  }
}

// Run the generation
generateOpenApiYaml();