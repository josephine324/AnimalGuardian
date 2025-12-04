# Building APK Manually

## Quick Steps

### 1. Set Production API URL

Open `frontend/.env` and set:
```
API_BASE_URL=https://animalguardian.onrender.com/api
```

### 2. Navigate to Frontend Directory
```powershell
cd frontend
```

### 3. Clean Previous Builds
```powershell
flutter clean
```

### 4. Get Dependencies
```powershell
flutter pub get
```

### 5. Build Release APK
```powershell
flutter build apk --release
```

This will take several minutes (5-10 minutes typically).

### 6. Find Your APK

After build completes, the APK will be at:
```
frontend\build\app\outputs\flutter-apk\app-release.apk
```

### 7. Revert to Local API (Optional)

After building, if you want to use local API for development:

Open `frontend/.env` and set:
```
API_BASE_URL=http://localhost:8000/api
```

## APK Details

- **API URL**: Production (`https://animalguardian.onrender.com/api`)
- **Build Type**: Release (optimized)
- **Size**: Typically 20-40 MB
- **Ready for**: Distribution/Installation

## Troubleshooting

**If build fails:**
- Check Flutter is installed: `flutter doctor`
- Check Android SDK is configured
- Check you have enough disk space
- Check internet connection (for downloading dependencies)

**If APK is too large:**
- Use split APKs: `flutter build apk --split-per-abi`
- This creates smaller APKs per architecture

## What's Included

This APK includes all latest features:
- ✅ Fixed account deactivation issue
- ✅ Pending approval functionality
- ✅ User approval page
- ✅ All recent bug fixes

