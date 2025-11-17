# Adding the Agasthi Mobile Logo

## Steps to Add Your Logo

1. **Save your logo image file** in this folder (`assets/images/`)
   - File name should be: `logo.png`
   - Recommended format: PNG (supports transparency)
   - Recommended size: At least 400x200 pixels for good quality

2. **After adding the logo file**, run:
   ```bash
   flutter pub get
   ```

3. **The logo will automatically appear** on:
   - Login screen (at the top)
   - Signup screen (at the top)

## Logo Specifications

Based on your logo design:
- **Format**: PNG (recommended) or JPG
- **Background**: Transparent or white
- **Aspect Ratio**: Should accommodate the circular emblem on left and Sinhala text on right
- **Color**: Dark purple (#6B46C1) - as shown in your logo

## Current Status

✅ Logo widget created and integrated into both screens
✅ Assets folder configured in `pubspec.yaml`
✅ Placeholder will show until you add the actual logo file

## File Location

Your logo should be placed at:
```
assets/images/logo.png
```

The app will automatically load and display it once the file is added.

