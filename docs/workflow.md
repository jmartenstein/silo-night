# Workflow Coordination Guide

This document defines the standard workflow for developers and automated agents contributing to Silo Night. Adhering to this process ensures clear communication, visibility of work, and high-quality contributions.

## 1. Discovery and Claiming
All work begins with a GitHub Issue. Issues represent features, bugs, or documentation tasks.

### Reviewing Issues
Use the `gh` CLI to list and view issues:
```bash
# List all open issues
gh issue list

# List issues with a specific label
gh issue list --label "enhancement"

# View details of a specific issue
gh issue view <issue-number>
```

### Claiming an Issue
Before starting any work, you must claim the issue to avoid duplicate efforts.
```bash
# Add the 'claimed' label to the issue
gh issue edit <issue-number> --add-label "claimed"
```

## 2. Branching and Initialization
Work is never performed directly on the `main` branch.

### Create a Feature Branch
Create a new branch named descriptively (e.g., `feature/add-tmdb-adapter` or `fix/user-login-error`).
```bash
git checkout -b <branch-name>
```

### Create a Pull Request (PR)
A Pull Request must be created **before** the core implementation work begins. This signals to others that the task is actively being handled.

1.  **Create an initial commit:**
    ```bash
    git commit --allow-empty -m "Initial commit for issue #<issue-number>"
    ```
2.  **Push the branch:**
    ```bash
    git push -u origin <branch-name>
    ```
3.  **Create the Draft PR:**
    ```bash
    gh pr create --title "Work on #<issue-number>: <short-description>" --body "Closes #<issue-number>" --draft
    ```

## 3. Planning with TODO.md
Before writing any implementation code, you must study the feature requirements and create a plan. This ensures that if work is interrupted or dropped, it can be resumed effectively.

### Create a detailed TODO.md
Create a `TODO.md` file in the root directory of the project. This file will be the primary source of truth for tracking progress on the specific feature or bug fix, replacing GitHub issues for granular task management during the development of the branch.

The `TODO.md` file must:
- Be highly specific and granular.
- Contain step-by-step instructions.
- Use Markdown checkboxes (`- [ ]`) to track progress.

Example `TODO.md` structure:
```markdown
# Feature: TMDB Adapter Integration

- [x] Research TMDB API endpoints for show search
- [ ] Create `lib/tmdb_adapter.rb` with basic configuration
- [ ] Implement `search_show` method in `TmdbAdapter`
- [ ] Add unit tests in `spec/tmdb_adapter_spec.rb`
- [ ] Integrate `TmdbAdapter` into `MetadataService`
- [ ] Verify integration with integration tests
```

### Commit the Plan
Immediately commit and push the `TODO.md` file to your branch.
```bash
git add TODO.md
git commit -m "Add implementation plan (TODO.md)"
git push
```

## 4. Implementation (In Progress)
Once the plan is committed, transition the issue to "in progress".

### Update Issue Status
```bash
# Mark the issue as in-progress
gh issue edit <issue-number> --add-label "in-progress"
```

### Development Cycle
Perform your work on the branch, committing frequently with clear, concise messages. **As you complete tasks, update the `TODO.md` file by marking checkboxes.**

```bash
# Mark a task as complete in TODO.md
# Add changes including TODO.md updates
git add .

# Commit changes
git commit -m "Implement TMDB search logic and update TODO.md"

# Push to the remote branch
git push
```

## 5. Completion and Review
Once the work is complete and verified locally with tests:

1.  **Run Tests:** Ensure all tests pass.
    ```bash
    rake test
    ```
2.  **Remove TODO.md:** The `TODO.md` file is for branch-specific progress and should not be merged into the `main` branch.
    ```bash
    rm TODO.md
    git add TODO.md
    git commit -m "Remove TODO.md before PR review"
    git push
    ```
3.  **Update PR Description:** Ensure the PR description is detailed and provides context for the reviewers. It should include what was changed, why, and any relevant testing performed.
    ```bash
    gh pr edit --body "## Summary
    Brief description of changes.

    ## Changes
    - Detail 1
    - Detail 2

    ## Testing
    - [x] Unit tests passed
    - [x] Integration tests passed"
    ```
4.  **Mark PR as Ready:**
    ```bash
    gh pr ready
    ```
5.  **Request Review:** (Optional, if not automated)
    ```bash
    gh pr edit --add-reviewer <username>
    ```

Once the PR is merged, the associated issue should be closed automatically (if "Closes #ID" was used in the PR body) and labels will be managed by the maintainers.
