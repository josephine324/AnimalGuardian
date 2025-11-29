# Git History Rewrite Script
# This script rewrites ALL commits to be attributed to josephine324
# WARNING: This will rewrite git history and requires force push!

$NEW_NAME = "josephine324"
$NEW_EMAIL = "j.mutesi@alustudent.com"

Write-Host "================================================" -ForegroundColor Yellow
Write-Host "Git History Rewrite Script" -ForegroundColor Yellow
Write-Host "================================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "This will rewrite ALL commits to:" -ForegroundColor Cyan
Write-Host "  Name: $NEW_NAME" -ForegroundColor Cyan
Write-Host "  Email: $NEW_EMAIL" -ForegroundColor Cyan
Write-Host ""
Write-Host "WARNING: This is a destructive operation!" -ForegroundColor Red
Write-Host "- All commit authors will be changed" -ForegroundColor Red
Write-Host "- You will need to force push to remote" -ForegroundColor Red
Write-Host "- Anyone who cloned the repo will need to re-clone" -ForegroundColor Red
Write-Host ""

$confirm = Read-Host "Do you want to continue? (yes/no)"
if ($confirm -ne "yes") {
    Write-Host "Operation cancelled." -ForegroundColor Yellow
    exit
}

Write-Host ""
Write-Host "Step 1: Setting git config..." -ForegroundColor Green
git config user.name "$NEW_NAME"
git config user.email "$NEW_EMAIL"
git config --global user.name "$NEW_NAME"
git config --global user.email "$NEW_EMAIL"

Write-Host "Step 2: Creating backup branch..." -ForegroundColor Green
git branch backup-before-rewrite

Write-Host "Step 3: Rewriting git history..." -ForegroundColor Green
Write-Host "This may take a while depending on repository size..." -ForegroundColor Yellow

# Get the root commit
$rootCommit = git rev-list --max-parents=0 HEAD

# Rewrite all commits
git filter-branch --env-filter @"
export GIT_AUTHOR_NAME='$NEW_NAME'
export GIT_AUTHOR_EMAIL='$NEW_EMAIL'
export GIT_COMMITTER_NAME='$NEW_NAME'
export GIT_COMMITTER_EMAIL='$NEW_EMAIL'
"@ --tag-name-filter cat -- --branches --tags

Write-Host ""
Write-Host "Step 4: Cleaning up..." -ForegroundColor Green
git for-each-ref --format="%(refname)" refs/original/ | ForEach-Object { git update-ref -d $_ }
git reflog expire --expire=now --all
git gc --prune=now --aggressive

Write-Host ""
Write-Host "================================================" -ForegroundColor Green
Write-Host "History rewrite complete!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Verifying changes..." -ForegroundColor Cyan
$allAuthors = git log --format="%an <%ae>" --all | Select-Object -Unique
Write-Host "All commits are now attributed to:" -ForegroundColor Cyan
$allAuthors | ForEach-Object { Write-Host "  $_" -ForegroundColor White }

Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Review the changes: git log" -ForegroundColor White
Write-Host "2. If satisfied, force push to remote:" -ForegroundColor White
Write-Host "   git push --force --all" -ForegroundColor Cyan
Write-Host "   git push --force --tags" -ForegroundColor Cyan
Write-Host ""
Write-Host "3. If something went wrong, restore from backup:" -ForegroundColor White
Write-Host "   git reset --hard backup-before-rewrite" -ForegroundColor Cyan
Write-Host ""

