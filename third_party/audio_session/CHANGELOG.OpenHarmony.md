## 0.2.2-ohos-1.0.1 - 2026.8

### Added
* Implement `AbilityAware` on `AudioSessionPlugin` with `ensureSystemListeners` / `releaseSystemListeners` to restore or release `deviceChange` and `audioSessionDeactivated` listeners across Ability recreate. (PR ID)
* Add MethodChannel argument validation (`requireArgs`) for OHOS `OhosAudioManager` and `AudioSessionPlugin` entry points. (PR ID)
* Add unit tests for core `AudioSession` / `AudioSessionConfiguration`, OHOS models and manager proxies, and Android / Darwin API surfaces; add `mocktail` and `coverage` as dev dependencies. (PR ID)

### Changed
* Return `UnsupportedOperation` for OHOS public-SDK / system-only APIs instead of silently returning null: `setMicrophoneMute` (requires `MANAGE_AUDIO_CONFIG`), Bluetooth SCO APIs, `setMode` / `setAudioScene`, `dispatchMediaKeyEvent`, `setAllowedCapturePolicy` / `getAllowedCapturePolicy`, `generateAudioSessionId`, `getProperty`, and `adjustSuggestedStreamVolume`. (PR ID)
* Split the OHOS example API coverage page into separate AudioSession / OhosAudioManager routes so the two pages are not mounted together. (PR ID)

### Fixed
* Complete async OHOS MethodChannel void calls via `MethodResult.success` / `MethodResult.error` (for example `setSpeakerphoneOn`, volume adjust / set, `setAudioParameter`) so Dart Futures no longer hang or miss failures. (PR ID)
* Release `deviceChange` and `audioSessionDeactivated` callbacks with matching `off` and break callback circular references to avoid listener leaks. (PR ID)
* Clear shared static `AudioSessionPlugin` configuration when the last plugin instance detaches from the engine. (PR ID)
* Normalize configuration numeric fields to integers in OHOS `setConfiguration` before echoing `onConfigurationChanged`, so Dart `fromJson` does not fail on MethodChannel doubles. (PR ID)
* Fix `setInterruptionEventListener` to treat `isOnListener` as bool, store pending `audioAttributes`, and avoid stacking anonymous interruption callbacks. (PR ID)
* Show `devicesChangedEventStream` logs in the example: drop competing `OhosAudioManager` device listeners from the demo page, and subscribe via `AudioSession.devicesChangedEventStream` on the OHOS API page. (PR ID)
* Treat OHOS `setActive(false)` as success when the session is already inactive or `deactivateAudioSession` returns 6800301, so repeated deactivate no longer fails. (PR ID)

## 0.2.2-ohos.1.0.0

* TAG 0.2.2-ohos.1.0.0
