FROM oven/bun:latest

WORKDIR /app

# Copy package files
COPY package.json bun.lock ./

# Install dependencies
RUN bun install

# Copy source code
COPY src/ ./src/
COPY tsconfig.json ./

# Expose port (default is 3000, but we can make it configurable)
EXPOSE 3000

# Run the application
CMD ["bun", "run", "src/index.ts"]