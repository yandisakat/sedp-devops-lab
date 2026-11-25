# 8. Git and Bash

Objectives: **Git** (inspect, update, merge, rebase) and **Bash**.

## Git: do each on a scratch branch and record the commands

1. **Inspect:** `git log --oneline --graph --all`, `git show <sha>`, `git blame charts/lab-app/values.yaml`, `git diff staging..main` (what promotion would ship).
2. **Merge vs rebase:** create `feature/a` from `staging` and commit twice. Meanwhile, commit something to `staging` that touches the same line. Then:
   - `git merge staging` into one copy and look at the graph.
   - `git rebase staging` on another copy, resolve the conflict, `git rebase --continue`, and `git push --force-with-lease`.
3. **Tidy history:** `git rebase -i HEAD~3` to squash and reword before a PR.
4. **Cherry-pick a hotfix:** fix something on `staging`, then `git cherry-pick <sha>` it onto a branch from `main`.
5. **Bisect:** plant a bug that breaks a test a few commits back, then `git bisect start HEAD <good-sha>` and `git bisect run sh -c 'cd app && python -m pytest -q'`.
6. **Recover:** `git reset --hard HEAD~2`, then get the commits back with `git reflog`.

## Bash: write your own script

Write `scripts/env-diff.sh`, which renders the chart for dev and prod and prints the difference. Requirements:

- `source lib.sh`, so it runs with `set -euo pipefail`
- `require helm diff`
- Write to a `mktemp -d` directory and clean up with `trap … EXIT`
- Return a non-zero exit code if the environments differ in anything except `replicas`, `image` and `config`
- Pass `shellcheck` and CI

## Prove it

- Your git command log with graph screenshots before and after, the bisect result, and the PR adding `env-diff.sh` with CI green.

## Explain it

- When to rebase, and when never to (shared branches). Why `--force-with-lease` over `--force`?
- What `set -e`, `set -u` and `set -o pipefail` each catch. Why quote `"$var"`?
- What `trap … EXIT` guarantees.

## ADSS link

adss-gitops promotes `staging` → `main` by Auto-PR, and `git revert` is its rollback. ADSS scripts live in a `justfile`; read a recipe and `check-token-expiry.sh` with the same eye.
