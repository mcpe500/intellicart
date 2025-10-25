/**
 * Intellicart API OpenAPI Specification Exporter
 * 
 * This script generates the OpenAPI specification in both JSON and YAML formats
 * by accessing the Hono app's documentation endpoint.
 * 
 * @file OpenAPI spec exporter
 * @author Intellicart Team
 * @version 1.0.0
 */

import app from '../index';
import fs from 'fs';
import path from 'path';

async function generateSpec() {
  try {
    // Create a mock request to get the OpenAPI spec from the /doc endpoint
    const request = new Request('http://localhost/doc');
    const response = await app.fetch(request);
    const spec = await response.json();
    
    // Create specs directory if it doesn't exist
    const specsDir = path.join(process.cwd(), 'specs');
    if (!fs.existsSync(specsDir)) {
      fs.mkdirSync(specsDir, { recursive: true });
    }

    // Write JSON spec
    const jsonPath = path.join(specsDir, 'openapi.json');
    fs.writeFileSync(jsonPath, JSON.stringify(spec, null, 2));
    
    // Convert JSON to YAML
    const yamlContent = jsonToYaml(spec);
    const yamlPath = path.join(specsDir, 'openapi.yaml');
    fs.writeFileSync(yamlPath, yamlContent);

    console.log('OpenAPI specifications generated successfully:');
    console.log(`- JSON: ${jsonPath}`);
    console.log(`- YAML: ${yamlPath}`);
  } catch (error) {
    console.error('Error generating OpenAPI spec:', error);
  }
}

// Simple JSON to YAML converter
function jsonToYaml(obj: any, indent: number = 0): string {
  let yaml = '';
  const spaces = '  '.repeat(indent);

  if (obj === null) {
    return 'null\n';
  }
  
  if (Array.isArray(obj)) {
    if (obj.length === 0) {
      return '[]\n';
    }
    obj.forEach(item => {
      if (typeof item === 'object' && item !== null) {
        yaml += `${spaces}- \n${jsonToYaml(item, indent + 1).substring(spaces.length + 2)}`;
      } else {
        const itemStr = typeof item === 'string' ? `"${item}"` : String(item);
        yaml += `${spaces}- ${itemStr}\n`;
      }
    });
    return yaml;
  }
  
  if (typeof obj === 'object') {
    for (const key in obj) {
      if (obj.hasOwnProperty(key)) {
        const value = obj[key];
        if (value === null) {
          yaml += `${spaces}${key}:\n`;
        } else if (Array.isArray(value)) {
          if (value.length === 0) {
            yaml += `${spaces}${key}: []\n`;
          } else {
            yaml += `${spaces}${key}:\n`;
            value.forEach(item => {
              if (typeof item === 'object' && item !== null) {
                yaml += `  ${spaces}- \n${jsonToYaml(item, indent + 1)}`;
              } else {
                const itemStr = typeof item === 'string' ? `"${item}"` : String(item);
                yaml += `  ${spaces}- ${itemStr}\n`;
              }
            });
          }
        } else if (typeof value === 'object') {
          yaml += `${spaces}${key}:\n${jsonToYaml(value, indent + 1)}`;
        } else {
          const valueStr = typeof value === 'string' ? `"${value}"` : String(value);
          yaml += `${spaces}${key}: ${valueStr}\n`;
        }
      }
    }
    return yaml;
  }
  
  return `${spaces}${typeof obj === 'string' ? `"${obj}"` : String(obj)}\n`;
}

// Run the function
generateSpec().catch(console.error);