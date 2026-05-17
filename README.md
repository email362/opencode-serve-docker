# OpenCode (Docker)

Run [OpenCode](https://github.com/sst/opencode) as a web server in Docker, with your projects and tool credentials mounted from the host.

## Prerequisites

- Docker and Docker Compose
- Node-based CLIs are installed in the image (`opencode-ai`, `@google/gemini-cli`, `@openai/codex`)

## Quick start

1. Create a `.env` file in this directory (it is gitignored):

   ```env
   OPENCODE_SERVER_USERNAME=your-username
   OPENCODE_SERVER_PASSWORD=your-password
   ```

2. Adjust volume paths in `docker-compose.yml` if needed (defaults assume `~/Projects`, `~/.config/opencode`, etc.).

3. Build and start:

   ```bash
   docker compose up -d --build
   ```

4. Open the web UI at [http://localhost:4096](http://localhost:4096) and sign in with the credentials from `.env`.

## Configuration

### Web UI login

`OPENCODE_SERVER_USERNAME` and `OPENCODE_SERVER_PASSWORD` are read from `.env` (or your shell) and passed into the container. Compose substitutes them via the `environment` section in `docker-compose.yml`.

You can also export them inline for a one-off run:

```bash
OPENCODE_SERVER_USERNAME=chyer OPENCODE_SERVER_PASSWORD=secret docker compose up -d
```

### Volumes

| Host path | Container path | Purpose |
|-----------|----------------|---------|
| `~/Projects` | `/workspace` | Working directory for projects |
| `~/.config/opencode` | `/root/.config/opencode` | OpenCode config |
| `~/.local/share/opencode` | `/root/.local/share/opencode` | OpenCode state |
| `~/.codex` | `/root/.codex` | OpenAI Codex OAuth tokens |
| `~/.gemini` | `/root/.gemini` | Gemini CLI credentials |

Copy or rsync OAuth/token directories from another machine (e.g. WSL) if you already authenticated there.

### Overrides

`docker-compose.override.yml` is gitignored. Use it for machine-specific paths or extra services without changing the base compose file.

## Useful commands

```bash
# Logs
docker compose logs -f

# Shell inside the container
docker exec -it opencode-web bash

# Restart after config changes
docker compose restart

# Rebuild after Dockerfile changes
docker compose up -d --build
```

## Troubleshooting

See [TODO.md](TODO.md) for Git/SSH setup for private repos and post-fix checks.

### Codex / OpenAI 401

OpenCode and the standalone Codex CLI use **separate** credential stores. Try OpenCode auth first; if the web UI still returns 401, re-auth with the `codex` CLI as well.

**OAuth callback:** the login flow opens a browser on `localhost`. From your laptop, forward the callback port to the container host before logging in:

```bash
ssh -L 1455:localhost:1455 user@your-docker-host
```

#### 1. OpenCode provider auth (try this first)

Credentials live in `~/.local/share/opencode/auth.json` (mounted from the host).

```bash
# See what is configured
docker exec -it opencode-web opencode auth list

# Log out (interactive provider picker) or target OpenAI directly
docker exec -it opencode-web opencode auth logout
docker exec -it opencode-web opencode auth login -p openai

# Restart and test in the web UI
docker compose restart
```

To force a clean slate for OpenCode’s OpenAI OAuth entry, remove its auth file on the host (path may vary by version), then run `opencode auth login` again.

#### 2. Codex CLI auth (if 401 persists)

The `codex` tool uses `~/.codex` (also mounted from the host).

```bash
# Optional: wipe stale session
docker exec -it opencode-web rm -rf /root/.codex/auth.json

docker exec -it opencode-web codex logout
docker exec -it opencode-web codex login
docker exec -it opencode-web codex auth status

docker compose restart
```

#### 3. Verify

Send a test prompt to an OpenAI/Codex model in the web UI. Check logs with `docker compose logs -f` if it still fails.

### Private Git repos

Mount `~/.ssh` read-only or use a GitHub PAT (details in [TODO.md](TODO.md)).

## Ports

- `4096` — OpenCode web server (`opencode serve` on `0.0.0.0`)
