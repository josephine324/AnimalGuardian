# OneDrive Build Issues - Solution Guide

## Problem
OneDrive sync can lock build files during Flutter builds, causing errors like:
```
Unable to delete directory '...\build\...'
Failed to delete some children. This might happen because a process has files open
```

## Solutions

### Solution 1: Exclude Build Folder from OneDrive (Recommended - Permanent Fix)

#### Method A: Using File Explorer
1. Open File Explorer and navigate to the `frontend` folder
2. Right-click on the `build` folder
3. Select **"Always keep on this device"** (this prevents OneDrive from syncing it)
4. If that option isn't available, go to OneDrive Settings:
   - Click OneDrive icon in system tray
   - Click **Settings** → **Sync and backup**
   - Click **Advanced settings**
   - Click **Choose folders**
   - Uncheck the `build` folder

#### Method B: Using PowerShell Script
Run the provided script:
```powershell
cd frontend
.\exclude_build_from_onedrive.ps1
```

### Solution 2: Pause OneDrive During Builds (Temporary Fix)

#### Quick Method:
```powershell
# Pause OneDrive
Stop-Process -Name "OneDrive" -Force -ErrorAction SilentlyContinue

# Run your Flutter build
flutter run -d emulator-5554

# Resume OneDrive (after build completes)
Start-Process "$env:LOCALAPPDATA\Microsoft\OneDrive\OneDrive.exe"
```

#### Using Provided Scripts:
```powershell
# Pause OneDrive
.\pause_onedrive.ps1

# Run Flutter app
flutter run -d emulator-5554

# Resume OneDrive
.\resume_onedrive.ps1
```

#### Automated Script:
```powershell
# This script pauses OneDrive, runs the app, and resumes OneDrive automatically
.\run_without_onedrive.ps1
```

### Solution 3: Move Project Outside OneDrive (Best for Development)

If you frequently encounter issues, consider moving the project:
```powershell
# Move project to a non-OneDrive location
Move-Item "C:\Users\Administrator\OneDrive\Desktop\AnimalGuardian" "C:\Projects\AnimalGuardian"
```

Then update your development environment to use the new location.

## Quick Reference

### Before Building:
```powershell
# Option 1: Pause OneDrive
.\pause_onedrive.ps1

# Option 2: Use automated script
.\run_without_onedrive.ps1
```

### After Building:
```powershell
# Resume OneDrive (if you paused it)
.\resume_onedrive.ps1
```

## Prevention

1. **Exclude build folder** - Best long-term solution
2. **Use .gitignore** - Already configured, but OneDrive doesn't respect it
3. **Pause OneDrive during builds** - Quick fix when needed
4. **Move project outside OneDrive** - Best for active development

## Notes

- OneDrive doesn't support `.onedriveignore` files like Git
- The build folder doesn't need to be synced (it's generated)
- Excluding the build folder won't affect your project files
- You can always re-sync later if needed

