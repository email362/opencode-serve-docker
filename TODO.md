# OpenCode Server Troubleshooting Checklist

### 1. Fix Codex / OpenAI Authentication (401 Error)

* [ ] **Wipe Session Cache:** Run `docker exec -it opencode-web rm -rf /root/.codex/auth.json` to ensure a clean slate.
* [ ] **Force Logout:** Run `docker exec -it opencode-web codex logout`.
* [ ] **Setup SSH Tunnel:** On your local machine, run `ssh -L 1455:localhost:1455 [user]@[homelab-ip]` to handle the `localhost` callback.
* [ ] **Perform Fresh Login:** Run `docker exec -it opencode-web codex login` and complete the browser authentication.
* [ ] **Validate Auth:** Run `docker exec -it opencode-web codex auth status`.

### 2. Configure Git Access for Private Repositories

* [ ] **Option A: Mount SSH Keys (Recommended)**
* [ ] Add `- ~/.ssh:/root/.ssh:ro` to the `volumes` section of your `docker-compose.yml`.
* [ ] Fix permissions on the host: `chmod 700 ~/.ssh && chmod 600 ~/.ssh/*`.
* [ ] Update Known Hosts: `docker exec -it opencode-web bash -c "mkdir -p /root/.ssh && ssh-keyscan -t rsa github.com >> /root/.ssh/known_hosts"`.


* [ ] **Option B: Use Personal Access Token (PAT)**
* [ ] Generate a "Classic" PAT on GitHub with `repo` scope.
* [ ] Update the remote URL inside the container: `git remote set-url origin https://[username]:[token]@github.com/[owner]/[repo].git`.



### 3. Post-Fix Verification

* [ ] **Restart Service:** Apply changes with `docker compose restart opencode-web`.
* [ ] **Test Git Connectivity:** Verify with `docker exec -it opencode-web git pull`.
* [ ] **Confirm LLM Functionality:** Send a test prompt to an OpenAI/Codex model in the Web UI.

---

*Note: If you use the SSH Key Mount method, ensure your private key is named `id_rsa` or `id_ed25519` so Git finds it automatically without extra configuration.*
