#!/bin/bash
# generate_docs.sh - Script to generate documentation

echo "Generating documentation..."
dart doc

echo "Documentation generated in doc/api directory"
echo "To view documentation, open doc/api/index.html in a web browser"