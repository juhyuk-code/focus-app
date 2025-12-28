# Focus App - NFC App Blocker

An iOS app that blocks selected apps using NFC chip activation. Once apps are blocked, they can only be unblocked by tapping the NFC chip again.

## Features

- **App Blocking**: Select which apps and categories to block using Apple's Screen Time API
- **NFC Activation**: Toggle blocking on/off by tapping any NFC chip
- **Persistent State**: Blocking state persists across app restarts
- **Privacy First**: All data stays on your device

## Requirements

- iOS 17.0+
- iPhone 7 or later (NFC capable device)
- Screen Time enabled
- Any NFC chip/tag

## Setup

### 1. Apple Developer Account Requirements

To use Screen Time (FamilyControls) features, you need:

1. An Apple Developer account
2. Request the **Family Controls** capability from Apple
3. Add the capability to your App ID in the Developer Portal

### 2. Xcode Configuration

1. Open `FocusApp.xcodeproj` in Xcode 15+
2. Select the project in the navigator
3. Update the **Team** in Signing & Capabilities
4. Ensure these capabilities are enabled:
   - Family Controls
   - NFC Tag Reading

### 3. Running the App

1. Connect your iPhone
2. Build and run (⌘R)
3. Grant Screen Time permissions when prompted
4. Select apps to block
5. Tap your NFC chip to activate blocking

## How It Works

### App Blocking (FamilyControls)

The app uses Apple's Screen Time API:
- `FamilyControls` - For authorization and app selection
- `ManagedSettings` - For applying shields to apps
- `DeviceActivity` - For monitoring (optional)

### NFC Reading (CoreNFC)

- Uses `NFCNDEFReaderSession` to detect NFC tags
- Any NFC tag works - no specific data required
- Simply tapping the tag triggers the toggle

### State Persistence

- Blocking state saved to UserDefaults
- Selected apps encoded with PropertyListEncoder
- State automatically restored on app launch

## Project Structure

```
FocusApp/
├── FocusAppApp.swift          # App entry point
├── ContentView.swift          # Main UI
├── Managers/
│   ├── AppBlockingManager.swift    # Screen Time blocking logic
│   ├── NFCManager.swift            # NFC reading
│   └── BlockingStateManager.swift  # State persistence
├── Views/
│   ├── AppSelectionView.swift      # App picker UI
│   └── SettingsView.swift          # Settings screen
├── Assets.xcassets/
├── Info.plist
└── FocusApp.entitlements
```

## Privacy

- No data leaves your device
- No analytics or tracking
- App tokens are opaque - we never see actual app names
- Screen Time permissions required for blocking only

## Troubleshooting

### "Screen Time authorization failed"
- Enable Screen Time in Settings > Screen Time
- Ensure you're signed into iCloud

### "NFC not available"
- NFC requires iPhone 7 or later
- Ensure NFC is enabled in Settings

### Apps not blocking
- Check that apps are selected in the app
- Verify Screen Time is enabled
- Try re-authorizing in Settings

## License

MIT License - See LICENSE file for details
