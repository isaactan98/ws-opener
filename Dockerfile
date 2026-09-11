# syntax=docker/dockerfile:1

# ---------------------------------------------------------------------------
# Build stage
#
# Pinned to the *builder's* platform on purpose. `nuxt generate` emits plain
# HTML, CSS and JS, which is byte-identical on every architecture, so a
# linux/arm64 image should never pay for an emulated Node build.
#
# Keep the major in step with .nvmrc and the "engines" field in package.json.
# ---------------------------------------------------------------------------
FROM --platform=$BUILDPLATFORM node:24-alpine AS build

WORKDIR /app

# Dependencies first, so editing app.vue does not reinstall node_modules.
#
# --ignore-scripts is needed because this project's own postinstall is
# `nuxt prepare`, which cannot run before the source is copied in; it is run
# explicitly below. The only dependency script it also skips is esbuild's
# postinstall, which is a no-op once the @esbuild/<platform> optional
# dependency is installed, as npm ci does from the lockfile.
COPY package.json package-lock.json .npmrc ./
RUN npm ci --ignore-scripts

COPY . .
RUN npx nuxt prepare && npm run generate

# ---------------------------------------------------------------------------
# Runtime stage
#
# nginx rather than Nitro: this app has no server code at all -- no
# server/api, no useFetch, no runtime config -- so the whole of it is the
# ~250 KB of static files produced above. A Node process at runtime would add
# a couple of hundred MB of image and ~100 MB of idle RSS for nothing.
#
# Deliberately no RUN instruction here, so buildx can assemble the arm64
# image without emulating a single guest instruction.
# ---------------------------------------------------------------------------
FROM nginx:1.30-alpine AS runtime

COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY --from=build /app/.output/public /srv/www

# Unprivileged user on an unprivileged port, so the container needs no
# Linux capabilities whatsoever (see cap_drop in compose.yaml).
USER nginx
EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD ["wget", "-q", "-O", "-", "http://127.0.0.1:8080/healthz"]

# Bypass the image's /docker-entrypoint.sh: its helper scripts write into
# /etc and /var, which a read-only root filesystem refuses, and none of what
# they do (envsubst templating, IPv6 patching) is used here.
ENTRYPOINT ["nginx", "-g", "daemon off;"]
