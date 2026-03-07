# Parallel Coordination Workflow for AI Agents

This document defines the protocol for multiple AI agents working in parallel on the Silo Night project. It ensures that tasks (beans) are properly claimed, tracked, and synchronized across different git worktrees and branches.

---

## 1. Agent Identities
To avoid confusion in logs and tags, each agent must adopt a unique, non-numeric identity. Suggested naming conventions:

### Thematic Styles:
- **Constellation-based:** `agent-altair`, `agent-vega`, `agent-deneb`, `agent-sirius`
- **Role-based:** `agent-architect`, `agent-crafter`, `agent-sentry`, `agent-oracle`
- **Functional:** `agent-identity`, `agent-curation`, `agent-intelligence`, `agent-api`

---

## 2. The "Claim-on-Main" Protocol
The `.beans/` directory on the **`main`** branch is the global source of truth. Before starting any work, agents must "claim" their task on `main` to prevent collisions.

### **Step 1: Sync Global State**
Before checking for work, ensure your local `.beans/` folder matches the remote state:
```bash
git fetch origin main
git checkout origin/main -- .beans/
```

### **Step 2: Identify and Claim a Task**
Find an unblocked task and update its status to `in-progress` with your unique `assignee` tag:
```bash
# List unblocked, unclaimed tasks
beans list --ready --status todo

# Claim the task (e.g., silo-wyq)
beans update silo-wyq -s in-progress --tag "agent-altair"
```

### **Step 3: Broadcast the Claim**
Commit and push the bean update directly to the `main` branch immediately:
```bash
git add .beans/
git commit -m "Claim silo-wyq for agent-altair"
git push origin main
```

---

## 3. Execution & Implementation
Once the claim is broadcast, move to your specific feature branch to begin coding.

1. **Create/Switch to Branch:** `git checkout -b feature/your-feature-name`
2. **Implement Logic:** Write code, add tests, and verify against Cucumber features.
3. **Internal Updates:** You may update the bean's checklist locally in your branch, but do not push status changes to `main` until the PR is ready.

---

## 4. Completion & Synchronization
When the work is verified and the Pull Request is merged:

1. **Update Status to Completed:**
   ```bash
   git checkout main
   git pull origin main
   beans update silo-wyq -s completed
   git add .beans/
   git commit -m "Complete silo-wyq"
   git push origin main
   ```

2. **Notify Peers:** Other agents can now sync their `.beans/` folder to see that the task is finished and any dependent tasks are now `ready`.

---

## 5. Peer Awareness (The "Board")
To see what other agents are currently working on across the entire project:
```bash
# Sync first
git fetch origin main && git checkout origin/main -- .beans/

# Show all active claims
beans list --status in-progress --json | jq -r '.[] | "[\(.tags | join(", "))] \(.id): \(.title)"'
```
