FROM ghcr.io/hazmi35/node:22-dev-alpine as build-stage

# Prepare npm with corepack (experimental feature)
RUN corepack enable && corepack prepare npm@latest

# Copy package.json, lockfile and npm config files
COPY package.json package-lock.json *.npmrc  ./

# Fetch dependencies to virtual store
# RUN npm fetch

# Install dependencies
RUN npm install --force 

# Copy Project files
COPY . .

# Build TypeScript Project
RUN npm run build

# Prune devDependencies
# RUN npm prune --production

# Get ready for production
FROM ghcr.io/hazmi35/node:22-alpine

LABEL name "rawon"
LABEL maintainer "Stegripe Development <support@stegripe.org>"

# Install ffmpeg
RUN apk add --no-cache ffmpeg python3 && ln -sf python3 /usr/bin/python

# Copy needed files
COPY --from=build-stage /tmp/build/package.json .
COPY --from=build-stage /tmp/build/node_modules ./node_modules
COPY --from=build-stage /tmp/build/dist ./dist
COPY --from=build-stage /tmp/build/yt-dlp-utils ./yt-dlp-utils
COPY --from=build-stage /tmp/build/lang ./lang
COPY --from=build-stage /tmp/build/index.js ./index.js

# Additional Environment Variables
ENV NODE_ENV production

# Add scripts volumes
VOLUME /app/scripts

# Start the app with node
CMD ["node", "--es-module-specifier-resolution=node", "index.js"]
