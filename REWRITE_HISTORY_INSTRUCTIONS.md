# Git History Rewrite Instructions

## Overview
This guide will help you rewrite all git commits to be attributed only to **josephine324** (j.mutesi@alustudent.com).

## ⚠️ Important Warnings

1. **This is a destructive operation** - It rewrites git history
2. **Force push required** - You'll need to force push to remote
3. **Team coordination needed** - Anyone who cloned the repo will need to re-clone
4. **Backup created** - A backup branch is created before rewriting

## Method 1: Using the PowerShell Script (Recommended)

### Step 1: Run the Script
```powershell
.\rewrite_git_history.ps1
```

The script will:
- Set your git config to josephine324
- Create a backup branch
- Rewrite all commits
- Clean up old references

### Step 2: Verify Changes
```powershell
git log --format="%an <%ae>" --all | Select-Object -Unique
```

You should see only:
```
josephine324 <j.mutesi@alustudent.com>
```

### Step 3: Force Push to Remote
```powershell
# Push all branches
git push --force --all

# Push all tags
git push --force --tags
```

## Method 2: Manual Commands

### Step 1: Set Git Config
```powershell
git config user.name "josephine324"
git config user.email "j.mutesi@alustudent.com"
git config --global user.name "josephine324"
git config --global user.email "j.mutesi@alustudent.com"
```

### Step 2: Create Backup
```powershell
git branch backup-before-rewrite
```

### Step 3: Rewrite History
```powershell
git filter-branch --env-filter @"
export GIT_AUTHOR_NAME='josephine324'
export GIT_AUTHOR_EMAIL='j.mutesi@alustudent.com'
export GIT_COMMITTER_NAME='josephine324'
export GIT_COMMITTER_EMAIL='j.mutesi@alustudent.com'
"@ --tag-name-filter cat -- --branches --tags
```

### Step 4: Clean Up
```powershell
# Remove backup refs
git for-each-ref --format="%(refname)" refs/original/ | ForEach-Object { git update-ref -d $_ }

# Expire reflog
git reflog expire --expire=now --all

# Garbage collect
git gc --prune=now --aggressive
```

### Step 5: Verify
```powershell
git log --format="%an <%ae>" --all | Select-Object -Unique
```

### Step 6: Force Push
```powershell
git push --force --all
git push --force --tags
```

## Method 3: Using git-filter-repo (Most Efficient)

If you have `git-filter-repo` installed:

```powershell
# Install git-filter-repo first (if not installed)
# pip install git-filter-repo

git filter-repo --name-callback 'return b"josephine324"' --email-callback 'return b"j.mutesi@alustudent.com"'
```

## Verification Commands

### Check All Authors
```powershell
git log --format="%an <%ae>" --all | Select-Object -Unique
```

### Check Commit Count by Author
```powershell
git log --format="%an" --all | Group-Object | Select-Object Name, Count
```

### View Recent Commits
```powershell
git log --format="%h - %an <%ae> - %s" -10
```

## If Something Goes Wrong

### Restore from Backup
```powershell
git reset --hard backup-before-rewrite
```

### Or Reset to Remote
```powershell
git fetch origin
git reset --hard origin/master
```

## After Force Push

### For Team Members
Anyone who has cloned the repository will need to:

```powershell
# Option 1: Re-clone (easiest)
cd ..
rm -rf AnimalGuardian
git clone <repository-url>
cd AnimalGuardian

# Option 2: Reset their local copy
git fetch origin
git reset --hard origin/master
```

## Notes

- The backup branch `backup-before-rewrite` will remain until you delete it
- All commit hashes will change (this is normal when rewriting history)
- GitHub/GitLab contributors page will update after force push
- This operation cannot be undone after force push (unless you have the backup)

## Current Status Check

Before running, check current authors:
```powershell
git log --format="%an <%ae>" --all | Select-Object -Unique
```

If you already see only `josephine324 <j.mutesi@alustudent.com>`, the history may already be correct!

