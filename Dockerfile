# Use a stable Debian base
FROM debian:bookworm-slim

USER root
ENV DEBIAN_FRONTEND=noninteractive

# 1. Install system prerequisites
RUN apt-get update && apt-get install -y \
    curl \
    git \
    ca-certificates \
    gnupg \
    python3 \
    make \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# 2. Install Node.js 24 (The specific version you need)
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# 3. Install OpenCode and your CLI tools via NPM
# This is the most reliable method for Docker as it handles the PATH automatically
RUN npm install -g opencode-ai @google/gemini-cli @openai/codex

# 4. Set the working directory
WORKDIR /workspace
EXPOSE 4096

# 5. Start the server with the correct flags
# '--print-logs' ensures you see output in 'docker logs'
CMD ["opencode", "serve", "--hostname", "0.0.0.0", "--port", "4096", "--print-logs"]
