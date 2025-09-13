# Intellicart Documentation

This directory contains the generated documentation for the Intellicart project.

## Generating Documentation

To generate documentation for this project, you can either run the generation scripts or use the dart doc command directly:

### Using Scripts

For Unix-like systems (macOS, Linux):
```bash
./doc/generate_docs.sh
```

For Windows:
```bash
doc\generate_docs.bat
```

### Using Direct Command

```bash
dart doc
```

The documentation will be generated in the `doc/api` directory.

## Viewing Documentation

To view the generated documentation, open `doc/api/index.html` in a web browser.

## Continuous Documentation Generation

Documentation is automatically generated and deployed as part of the CI/CD pipeline.