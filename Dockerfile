# Multi-stage build for QanoonHub
# Stage 1: Build Frontend
FROM node:18-alpine AS frontend-build

WORKDIR /app/frontend

# Copy frontend package files
COPY frontend/package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy frontend source
COPY frontend/ ./

# Build frontend
RUN npm run build

# Stage 2: Setup Backend
FROM node:18-alpine

WORKDIR /app

# Copy backend package files
COPY package*.json ./

# Install production dependencies
RUN npm ci --only=production

# Copy backend source
COPY . .

# Copy built frontend from previous stage
COPY --from=frontend-build /app/frontend/build ./public

# Create uploads directory
RUN mkdir -p uploads

# Expose port
EXPOSE 9000

# Set environment to production
ENV NODE_ENV=production

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD node -e "require('http').get('http://localhost:9000/api/cases', (r) => {process.exit(r.statusCode === 200 || r.statusCode === 401 ? 0 : 1)})"

# Start the application
CMD ["npm", "start"]
