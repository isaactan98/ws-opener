# WhatsApp Chat Opener

Open a WhatsApp chat without saving the number to your contacts. Paste a
number in any format — spaces, dashes and `+` are stripped — check the readout
showing the exact digits WhatsApp will dial, and open the chat.

Everything runs in the browser. There is no backend, no database and no
telemetry: the number you type never leaves your device.

## Requirements

Node 24 (the Active LTS line), as pinned in `.nvmrc`.

```bash
nvm use
npm ci
```

## Development

```bash
npm run dev          # http://localhost:3000
```

## Production build

The app has no server code, so it builds to a static bundle of about 250 KB:

```bash
npm run generate     # output in .output/public
```

Those files can be served by any static host.

## Deploying to a homelab

### The one thing to get right: HTTPS is not optional

The "On your clipboard" paste tray calls `navigator.clipboard.readText()`,
which browsers only expose in a
[secure context](https://developer.mozilla.org/en-US/docs/Web/API/Clipboard/readText).
`http://192.168.1.x:8080` is **not** a secure context — only HTTPS and
`localhost` are. Worse, the failure is silent: `readClipboard()` in `app.vue`
treats a missing API as "nothing to suggest", so the tray simply never appears
and the app looks like it built wrong.

So serve this over real HTTPS. `compose.yaml` binds the published port to
loopback and expects Tailscale Serve in front, which issues a genuine
Let's Encrypt certificate for the host's `*.ts.net` name:

```bash
tailscale serve --bg --https=443 8080
```

Any other reverse proxy with a real certificate works the same way; point it
at `127.0.0.1:8080`.

### Pulling the published image

CI builds `linux/amd64` and `linux/arm64` images on every push to `master` and
publishes them to GHCR.

```bash
docker compose pull
docker compose up -d
```

GHCR packages are created **private** even when the repository is public, so
the first pull needs one of:

- make the package public once, under the repository's Packages settings; or
- `docker login ghcr.io -u <username>` on the homelab host with a personal
  access token carrying the `read:packages` scope.

### Building on the host instead

No registry required:

```bash
docker compose up -d --build
```

### Updating

```bash
docker compose pull && docker compose up -d
docker image prune -f
```

HTML and Nuxt's build manifest are served `no-cache`, so a redeployed version
is picked up on the next load rather than leaving browsers pointed at hashed
bundles that no longer exist.

### Checking it is healthy

```bash
curl -fsS http://127.0.0.1:8080/healthz     # -> ok
docker compose ps                           # STATUS should read (healthy)
```

## How the container is put together

- **nginx, not Node.** There is no `server/api`, no `useFetch` and no runtime
  config anywhere in this app, so a Nitro server would add a couple of hundred
  MB of image and ~100 MB of idle RSS to serve files that never change.
- **The Node build runs on the builder's architecture.** `nuxt generate`
  output is identical on every CPU, so the build stage is pinned to
  `$BUILDPLATFORM` and the arm64 image is assembled without QEMU emulation.
- **Unprivileged and locked down.** nginx runs as a non-root user on port
  8080, so the container drops every Linux capability and runs with a
  read-only root filesystem, with `/tmp` as its only writable path.
- **Serving rules** live in `nginx/nginx.conf`: hashed `_nuxt/` assets are
  immutable for a year, HTML and the build manifest revalidate, unknown paths
  return a real 404, and security headers are attached at the server level so
  they survive on every response.
