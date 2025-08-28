# docker/Dockerfile

# Stage 1: Build
FROM node:20-alpine AS builder

WORKDIR /app

# Copy dependencies and install
COPY package*.json ./
#RUN npm install
RUN npm install -g npm@11.5.2
# Copy source code
COPY . .

# Build the app
RUN npm run build

# Stage 2: Production image
FROM node:18-alpine

WORKDIR /app

# Copy only needed files from build stage
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist

# Start the app
CMD ["node", "dist/main"]

