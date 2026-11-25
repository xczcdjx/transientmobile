> Template version: v0.0.1

<p align="center">
  <h1 align="center"> <code>audio_session</code> </h1>
</p>

This project is based on [audio_session](https://pub.dev/packages/audio_session).

## 1. Installation and Usage

### 1.1 Installation

Go to the project directory and add the following dependencies in pubspec.yaml

<!-- tabs:start -->

#### pubspec.yaml

```yaml
---
dependencies:
  audio_session:
    git:
      url: https://gitcode.com/CPF-Flutter/flutter_audio_session.git
      # ref: Select the TAG version that matches your Flutter framework version from the table below
      ref: TAG  # Select a TAG from the TAG version mapping table below
```

Execute Command

```bash
flutter pub get
```

> TAG naming rule: `original version-ohos-version number-betax`, changes between different TAGs can be found in CHANGELOG.OpenHarmony.md.

| Flutter Framework Version | TAG Name               | Branch Name |
| ------------------------- | ----------------------- | ----------- |
| 3.7              | 0.1.18-ohos-1.0.0-beta.1 | master |
| 3.22             | 0.1.21-ohos-1.0.0-beta.1 | br_v0.1.21_ohos |
| 3.27             | 0.2.2-ohos-1.0.1 | br_v0.2.2_ohos |
| 3.35             | 0.2.2-ohos-1.0.1 | br_v0.2.2_ohos |

> Upgrade / migration notes:
> - When upgrading across Flutter framework versions (e.g. 3.7 → 3.27 / 3.35), update the `ref` in `pubspec.yaml` to the matching TAG and run `flutter pub get`. Each TAG is bound to a specific OHOS Flutter SDK; using an unmatched combination may cause build failures.
> - The OHOS implementation is API-compatible across TAGs; existing Dart call sites (`AudioSession.instance`, `OhosAudioManager()`, etc.) do not need code changes when upgrading.
> - If you fork from an older branch, prefer rebasing onto the target branch (`br_v0.2.2_ohos`) rather than cherry-picking, to keep the `ohos/` native layer and the Dart proxy layer in sync.

<!-- tabs:end -->

### 1.2 Usage

The full runnable demo is at [example/lib/main.dart](./example/lib/main.dart). The recommended call chain is: **import → obtain the session → configure → activate**.

```dart
import 'package:audio_session/audio_session.dart';

// 1. Obtain the singleton audio session.
final session = await AudioSession.instance;

// 2. Configure it (the same API works on iOS/Android/OHOS).
await session.configure(const AudioSessionConfiguration.speech());

// 3. Activate the session. On OHOS the underlying AudioManager activates an
//    AudioSessionStrategy with the requested concurrency mode.
await session.setActive(true);
```

For OHOS-specific capabilities exposed through the platform proxy `OhosAudioManager`, import the OHOS module and use the typed API directly:

```dart
import 'package:audio_session/src/ohos.dart';

// OHOS-only: query audio devices using the DevicesFlags bitmask.
final manager = OhosAudioManager();
final devices = await manager.getDevices(
  DevicesFlags.outputDevicesFlag | DevicesFlags.inputDevicesFlag,
);

// OHOS-only: listen for device add/remove events.
manager.setAudioDevicesAddedListener((added) {
  // added: List<OhosAudioDeviceDescriptor>
});
manager.setAudioDevicesRemovedListener((removed) {
  // removed: List<OhosAudioDeviceDescriptor>
});

// OHOS-only: receive audio interruption (deactivation) events.
await manager.setInterruptionEventListener(OhosInterruptListernerRequest(
  audioAttributes: OhosAudioAttributes(
    streamUsage: StreamUsage.music,
    samplingRate: AudioSamplingRate.sampleRate44100,
    channels: AudioChannel.channel2,
    sampleFormat: AudioSampleFormat.sampleFormatS16LE,
    encodingType: AudioEncodingType.encodingTypePcm,
  ),
  isOnListener: true,
  onAudioFocusChanged: (reason) {
    // reason: AudioSessionDeactivatedReason
  },
));
```

## 2. Constraints

### 2.1 OHOS environment setup

To build and run this plugin on OpenHarmony / HarmonyOS, prepare the toolchain below. Version combinations verified by this project are listed in [2.2 Compatibility](#22-compatibility).

1. **DevEco Studio**: install DevEco Studio and launch it once so its bundled SDKs (`ohpm`, `hvigor`, HarmonyOS SDK) are downloaded.
2. **OHOS command-line tools**: make sure `ohpm` and `hvigorw` are on your `PATH` (typically under `<DevEcoStudio>/tools/ohpm/bin` and `<DevEcoStudio>/tools/hvigor/bin`). Verify with `ohpm -v`.
3. **Flutter (OHOS branch)**: install the OHOS-enabled Flutter SDK (`flutter --version` should report an `-ohos` suffix, e.g. `3.27.5-ohos`). `Platform.isOhos` is used for platform detection.
4. **Build the example HAP**: from the `example/` directory, run:

   ```bash
   flutter pub get
   flutter build hap --debug
   # To disable the hvigor daemon for reproducible builds, set
   # execution.daemon=false in example/ohos/hvigor/hvigor-config.json5
   ```

5. **Install to device**: `hdc install <path-to-hap>`, or deploy through DevEco Studio.

### 2.2 Compatibility

This document is verified based on the following versions:

1. Flutter: 3.27.5-ohos-0.0.1; SDK: 5.0.0(12); IDE: DevEco Studio: 5.1.0.828; ROM: 5.1.0.130 SP8;
2. Flutter: 3.35.7-ohos-0.0.1; SDK: 6.0.1(21); IDE: DevEco Studio: 6.0.1.260; ROM: 6.0.0.120 SP6;

### 2.3 Platform limitations

- `OhosAudioManager.setMicrophoneMute`: requires `ohos.permission.MANAGE_AUDIO_CONFIG` (system apps only). Third-party apps receive `UnsupportedOperation`. Read-only `isMicrophoneMute` remains available.

## 3. API

> [!TIP] If the value of **ohos Support** is **yes**, it means that the ohos platform supports this property; **no** means the opposite; **partially** means some capabilities of this property are supported. The usage method is the same on different platforms and the effect is the same as that of iOS or Android.

### OhosAudioManager API

| Name                           | Description                                              | Type     | Input                                                    | Output                                    | ohos Support |
| ------------------------------ | -------------------------------------------------------- | -------- | -------------------------------------------------------- | ----------------------------------------- | ------------ |
| setAudioDevicesAddedListener   | Sets a listener for audio devices added                  | function | `OhosOnAudioDevicesChanged` listener                     | /                                         | yes          |
| setAudioDevicesRemovedListener | Sets a listener for audio devices removed                | function | `OhosOnAudioDevicesChanged` listener                     | /                                         | yes          |
| setInterruptionEventListener   | Sets a listener for interruption events                  | function | `OhosInterruptListernerRequest` listernerRequest         | /                                         | yes          |
| setActive                      | Sets whether the audio session is active                 | function | `bool` active, {`AudioConcurrencyMode?` concurrencyMode} | `Future<bool>`                            | yes          |
| isVolumeUnadjustable           | Checks if the volume is unadjustable                     | function | /                                                        | `Future<bool>`                            | yes          |
| getRingerMode                  | Gets the ringer mode                                     | function | /                                                        | `Future<AudioRingMode>`                   | yes          |
| getMaxVolume                   | Gets the maximum system volume for specified stream type | function | `AudioVolumeType` streamType                             | `Future<int>`                             | yes          |
| getMinVolume                   | Gets the minimum system volume for specified stream type | function | `AudioVolumeType` streamType                             | `Future<int>`                             | yes          |
| getVolume                      | Gets current system volume for specified stream type     | function | `AudioVolumeType` streamType                             | `Future<int>`                             | yes          |
| getSystemVolumeInDb            | Gets system volume in decibels for stream type           | function | `AudioVolumeType` streamType                             | `Future<int>`                             | yes          |
| isMute                         | Checks if specified stream type is muted                 | function | `AudioVolumeType` streamType                             | `Future<bool>`                            | yes          |
| getDevices                     | Gets all audio devices                                   | function | `DevicesFlags` flags                                     | `Future<List<OhosAudioDeviceDescriptor>>` | yes          |
| setSpeakerphoneOn              | Sets whether speakerphone is on                          | function | `bool` enabled                                           | `Future<void>`                            | yes          |
| isSpeakerphoneOn               | Checks if speakerphone is on                             | function | /                                                        | `Future<bool>`                            | yes          |
| setMicrophoneMute              | Sets whether microphone is muted                         | function | `bool` enabled                                           | `Future<void>`                            | no (requires system permission `MANAGE_AUDIO_CONFIG`; third-party apps get UnsupportedOperation) |
| isMicrophoneMute               | Checks if microphone is muted                            | function | /                                                        | `Future<bool>`                            | yes          |
| getAudioScene                  | Gets current audio scene                                 | function | /                                                        | `Future<AudioScene>`                      | yes          |
| isMusicActive                  | Checks if music is currently playing                     | function | /                                                        | `Future<bool>`                            | yes          |
| setAudioParameter              | Sets audio parameters                                    | function | `String` parameters, `String` value                      | `Future<void>`                            | yes          |
| getAudioParameter              | Gets audio parameters                                    | function | `String` key                                             | `Future<String>`                          | yes          |

### OhosInterruptEvent API

| Name      | Description             | Type | Input | Output | ohos Support |
| --------- | ----------------------- | ---- | ----- | ------ | ------------ |
| eventType | Type of interrupt event | enum | /     | /      | yes          |
| forceType | Type of interrupt force | enum | /     | /      | yes          |
| hintType  | Type of interrupt hint  | enum | /     | /      | yes          |

### OhosInterruptType API

| Name               | Description          | Type | Input | Output | ohos Support |
| ------------------ | -------------------- | ---- | ----- | ------ | ------------ |
| interruptTypeBegin | Begins the interrupt | enum | /     | /      | yes          |
| interruptTypeEnd   | Ends the interrupt   | enum | /     | /      | yes          |

### OhosInterruptForceType API

| Name           | Description        | Type | Input | Output | ohos Support |
| -------------- | ------------------ | ---- | ----- | ------ | ------------ |
| interruptForce | Forceful interrupt | enum | /     | /      | yes          |
| interruptShare | Shared interrupt   | enum | /     | /      | yes          |

### OhosInterruptHint API

| Name                | Description | Type | Input | Output | ohos Support |
| ------------------- | ----------- | ---- | ----- | ------ | ------------ |
| interruptHintNone   | No hint     | enum | /     | /      | yes          |
| interruptHintResume | Resume hint | enum | /     | /      | yes          |
| interruptHintPause  | Pause hint  | enum | /     | /      | yes          |
| interruptHintStop   | Stop hint   | enum | /     | /      | yes          |
| interruptHintDuck   | Duck hint   | enum | /     | /      | yes          |
| interruptHintUnduck | Unduck hint | enum | /     | /      | yes          |

### AudioRingMode API

| Name              | Description         | Type | Input | Output | ohos Support |
| ----------------- | ------------------- | ---- | ----- | ------ | ------------ |
| ringerModeSilent  | Silent ringer mode  | enum | /     | /      | yes          |
| ringerModeVibrate | Vibrate ringer mode | enum | /     | /      | yes          |
| ringerModeNormal  | Normal ringer mode  | enum | /     | /      | yes          |

### AudioScene API

| Name                | Description            | Type | Input | Output | ohos Support |
| ------------------- | ---------------------- | ---- | ----- | ------ | ------------ |
| audioSceneDefault   | Default audio scene    | enum | /     | /      | yes          |
| audioSceneRinging   | Ringing audio scene    | enum | /     | /      | yes          |
| audioScenePhoneCall | Phone call audio scene | enum | /     | /      | yes          |
| audioSceneVoiceChat | Voice chat audio scene | enum | /     | /      | yes          |

### AudioSessionDeactivatedReason API

| Name                     | Description                       | Type | Input | Output | ohos Support |
| ------------------------ | --------------------------------- | ---- | ----- | ------ | ------------ |
| deactivatedLowerPriority | Deactivated due to lower priority | enum | /     | /      | yes          |
| deactivatedTimeout       | Deactivated due to timeout        | enum | /     | /      | yes          |

### OhosAudioDeviceDescriptor API

| Name          | Description                      | Type              | Input | Output | ohos Support |
| ------------- | -------------------------------- | ----------------- | ----- | ------ | ------------ |
| deviceRole    | Device role                      | DeviceRole        | /     | /      | yes          |
| deviceType    | Device type                      | DeviceType        | /     | /      | yes          |
| id            | Device ID                        | int               | /     | /      | yes          |
| name          | Device name                      | String            | /     | /      | yes          |
| address       | Device address                   | String            | /     | /      | yes          |
| sampleRates   | List of supported sample rates   | List<int>         | /     | /      | yes          |
| channelCounts | List of supported channel counts | List<int>         | /     | /      | yes          |
| channelMasks  | List of supported channel masks  | List<int>         | /     | /      | yes          |
| displayName   | Display name                     | String            | /     | /      | yes          |
| encodingTypes | Supported encoding types         | AudioEncodingType | /     | /      | yes          |

### AudioEncodingType API

| Name                | Description           | Type | Input | Output | ohos Support |
| ------------------- | --------------------- | ---- | ----- | ------ | ------------ |
| encodingTypeInvalid | Invalid encoding type | enum | /     | /      | yes          |
| encodingTypeRaw     | Raw encoding type     | enum | /     | /      | yes          |

### DeviceRole API

| Name         | Description   | Type | Input | Output | ohos Support |
| ------------ | ------------- | ---- | ----- | ------ | ------------ |
| inputDevice  | Input device  | enum | /     | /      | yes          |
| outputDevice | Output device | enum | /     | /      | yes          |

### DeviceType API

| Name            | Description                      | Type | Input | Output | ohos Support |
| --------------- | -------------------------------- | ---- | ----- | ------ | ------------ |
| invalid         | Invalid device                   | enum | /     | /      | yes          |
| earpiece        | Earpiece                         | enum | /     | /      | yes          |
| speaker         | Speaker                          | enum | /     | /      | yes          |
| wiredHeadset    | Wired headset                    | enum | /     | /      | yes          |
| wiredHeadphones | Wired headphones with microphone | enum | /     | /      | yes          |
| bluetoothSco    | Bluetooth SCO connection         | enum | /     | /      | yes          |
| bluetoothA2dp   | Bluetooth A2DP connection        | enum | /     | /      | yes          |
| mic             | Microphone                       | enum | /     | /      | yes          |
| usbHeadset      | USB headset                      | enum | /     | /      | yes          |
| defaultDevice   | Default device                   | enum | /     | /      | yes          |

### AudioVolumeType API

| Name           | Description     | Type | Input | Output | ohos Support |
| -------------- | --------------- | ---- | ----- | ------ | ------------ |
| voiceCall      | Voice call      | enum | /     | /      | yes          |
| ringTone       | Ringtone        | enum | /     | /      | yes          |
| media          | Media           | enum | /     | /      | yes          |
| alarm          | Alarm           | enum | /     | /      | yes          |
| accessibility  | Accessibility   | enum | /     | /      | yes          |
| voiceAssistant | Voice assistant | enum | /     | /      | yes          |
| ultraSonic     | Ultrasound      | enum | /     | /      | yes          |
| all            | All             | enum | /     | /      | yes          |

### OhosAudioAttributes API

| Name         | Description   | Type              | Input | Output | ohos Support |
| ------------ | ------------- | ----------------- | ----- | ------ | ------------ |
| streamUsage  | Stream usage  | StreamUsage       | /     | /      | yes          |
| samplingRate | Sampling rate | AudioSamplingRate | /     | /      | yes          |
| channels     | Channels      | AudioChannel      | /     | /      | yes          |
| sampleFormat | Sample format | AudioSampleFormat | /     | /      | yes          |
| encodingType | Encoding type | AudioEncodingType | /     | /      | yes          |

### StreamUsage API

| Name               | Description         | Type | Input | Output | ohos Support |
| ------------------ | ------------------- | ---- | ----- | ------ | ------------ |
| unknown            | Unknown usage       | enum | /     | /      | yes          |
| music              | Music               | enum | /     | /      | yes          |
| voiceCommunication | Voice communication | enum | /     | /      | yes          |
| voiceAssistant     | Voice assistant     | enum | /     | /      | yes          |
| alarm              | Alarm               | enum | /     | /      | yes          |
| voiceMessage       | Voice message       | enum | /     | /      | yes          |
| ringTone           | Ringtone            | enum | /     | /      | yes          |
| notification       | Notification        | enum | /     | /      | yes          |
| accessibility      | Accessibility       | enum | /     | /      | yes          |
| movie              | Movie               | enum | /     | /      | yes          |
| game               | Game                | enum | /     | /      | yes          |
| audioBook          | Audiobook           | enum | /     | /      | yes          |
| navigation         | Navigation          | enum | /     | /      | yes          |

### OhosInterruptListernerRequest API

| Name                | Description                      | Type                | Input | Output | ohos Support |
| ------------------- | -------------------------------- | ------------------- | ----- | ------ | ------------ |
| audioAttributes     | Audio attributes                 | OhosAudioAttributes | /     | /      | yes          |
| onAudioFocusChanged | Callback for audio focus changes | function            | /     | /      | yes          |
| isOnListener        | Whether the listener is on       | bool                | /     | /      | yes          |

### AudioSamplingRate API

| Name            | Description           | Type | Input | Output | ohos Support |
| --------------- | --------------------- | ---- | ----- | ------ | ------------ |
| sampleRate8000  | 8000Hz sampling rate  | enum | /     | /      | yes          |
| sampleRate11025 | 11025Hz sampling rate | enum | /     | /      | yes          |
| sampleRate12000 | 12000Hz sampling rate | enum | /     | /      | yes          |
| sampleRate16000 | 16000Hz sampling rate | enum | /     | /      | yes          |
| sampleRate22050 | 22050Hz sampling rate | enum | /     | /      | yes          |
| sampleRate24000 | 24000Hz sampling rate | enum | /     | /      | yes          |
| sampleRate32000 | 32000Hz sampling rate | enum | /     | /      | yes          |
| sampleRate44100 | 44100Hz sampling rate | enum | /     | /      | yes          |
| sampleRate48000 | 48000Hz sampling rate | enum | /     | /      | yes          |
| sampleRate64000 | 64000Hz sampling rate | enum | /     | /      | yes          |
| sampleRate96000 | 96000Hz sampling rate | enum | /     | /      | yes          |

### AudioChannel API

| Name      | Description    | Type | Input | Output | ohos Support |
| --------- | -------------- | ---- | ----- | ------ | ------------ |
| channel1  | Mono channel   | enum | /     | /      | yes          |
| channel2  | Stereo channel | enum | /     | /      | yes          |
| channel3  | 3-channel      | enum | /     | /      | yes          |
| channel4  | 4-channel      | enum | /     | /      | yes          |
| channel5  | 5-channel      | enum | /     | /      | yes          |
| channel6  | 6-channel      | enum | /     | /      | yes          |
| channel7  | 7-channel      | enum | /     | /      | yes          |
| channel8  | 8-channel      | enum | /     | /      | yes          |
| channel9  | 9-channel      | enum | /     | /      | yes          |
| channel10 | 10-channel     | enum | /     | /      | yes          |
| channel11 | 11-channel     | enum | /     | /      | yes          |
| channel12 | 12-channel     | enum | /     | /      | yes          |
| channel13 | 13-channel     | enum | /     | /      | yes          |
| channel14 | 14-channel     | enum | /     | /      | yes          |
| channel15 | 15-channel     | enum | /     | /      | yes          |
| channel16 | 16-channel     | enum | /     | /      | yes          |

### AudioSampleFormat API

| Name                | Description                         | Type | Input | Output | ohos Support |
| ------------------- | ----------------------------------- | ---- | ----- | ------ | ------------ |
| sampleFormatInvalid | Invalid format                      | enum | /     | /      | yes          |
| sampleFormatU8      | 8-bit unsigned integer              | enum | /     | /      | yes          |
| sampleFormatS16LE   | 16-bit signed integer little endian | enum | /     | /      | yes          |
| sampleFormatS24LE   | 24-bit signed integer little endian | enum | /     | /      | yes          |
| sampleFormatS32LE   | 32-bit signed integer little endian | enum | /     | /      | yes          |
| sampleFormatF32LE   | 32-bit floating point little endian | enum | /     | /      | yes          |

### AudioConcurrencyMode API

| Name                     | Description              | Type | Input | Output | ohos Support |
| ------------------------ | ------------------------ | ---- | ----- | ------ | ------------ |
| concurrencyDefault       | Default concurrency mode | enum | /     | /      | yes          |
| concurrencyMixWithOthers | Mix with others          | enum | /     | /      | yes          |
| concurrencyDuckOthers    | Duck others              | enum | /     | /      | yes          |
| concurrencyPauseOthers   | Pause others             | enum | /     | /      | yes          |

### DevicesFlags API

Bitmask used by `OhosAudioManager.getDevices(flags)` to filter the returned audio devices. Flags can be combined with the bitwise operators below.

| Name                       | Description                                   | Type   | Input | Output | ohos Support |
| -------------------------- | --------------------------------------------- | ------ | ----- | ------ | ------------ |
| noneDevicesFlag            | No device flag (value `0`)                    | const  | /     | /      | yes          |
| outputDevicesFlag          | Output devices (value `1`)                    | const  | /     | /      | yes          |
| inputDevicesFlag           | Input devices (value `2`)                     | const  | /     | /      | yes          |
| allDevicesFlag             | All local devices (value `3`)                 | const  | /     | /      | yes          |
| distributedOutputDevicesFlag | Distributed output devices (value `4`)      | const  | /     | /      | yes          |
| distributedInputDevicesFlag  | Distributed input devices (value `8`)       | const  | /     | /      | yes          |
| addDistributedDevicesFlag  | All distributed devices (value `12`)          | const  | /     | /      | yes          |
| operator \|                | Returns the union of two flags                | method | `DevicesFlags` | `DevicesFlags` | yes |
| operator &                 | Returns the intersection of two flags         | method | `DevicesFlags` | `DevicesFlags` | yes |
| contains                   | Whether this flag set fully contains another  | method | `DevicesFlags` | `bool` | yes          |

### InterruptMode API

Audio interruption sharing mode for OHOS.

| Name          | Description                                 | Type | Input | Output | ohos Support |
| ------------- | ------------------------------------------- | ---- | ----- | ------ | ------------ |
| shareMode     | Multiple apps share the audio focus         | enum | /     | /      | yes          |
| indepentMode  | Exclusive (independent) audio focus         | enum | /     | /      | yes          |

### OhosOnAudioFocusChanged (typedef)

Callback signature invoked when an OHOS audio session is deactivated (an audio focus change occurs).

| Name                  | Description                                    | Type    | Input                            | Output | ohos Support |
| --------------------- | ---------------------------------------------- | ------- | -------------------------------- | ------ | ------------ |
| OhosOnAudioFocusChanged | Listener for audio focus / interruption events | typedef | `AudioSessionDeactivatedReason`  | `void` | yes          |

### OhosOnAudioDevicesChanged (typedef)

Callback signature invoked when OHOS audio devices are added or removed.

| Name                    | Description                          | Type    | Input                            | Output | ohos Support |
| ----------------------- | ------------------------------------ | ------- | -------------------------------- | ------ | ------------ |
| OhosOnAudioDevicesChanged | Listener for audio device change   | typedef | `List<OhosAudioDeviceDescriptor>`| `void` | yes          |

## 4. Known Issues

## 5. Others

## 6. License

This project is licensed under [The MIT License (MIT)](./LICENSE).

## Appendix: OHOS vs Android/iOS platform differences

| Capability | Android / iOS | OHOS behavior |
| --- | --- | --- |
| `getSystemVolumeInDb` | Android needs stream/index/device | Dart OHOS API passes only `AudioVolumeType`; native fills current volume + `SPEAKER`, returns rounded `int` |
| `isVolumeUnadjustable` | Android `isVolumeFixed` | Maps to `VolumeGroupManager.isVolumeUnadjustable()` |
| Focus / interruption | AudioFocus / AVAudioSession | `AudioSessionManager.activateAudioSession` / `audioSessionDeactivated` |
| `channelIndexMasks` | Present on Android descriptors | Not on OHOS `AudioDeviceDescriptor`; encoded as empty array |
| `adjustStreamVolume` / `setStreamVolume` / `setRingerMode` | Implemented | Implemented via deprecated-but-callable `AudioManager.setVolume` / `setRingerMode` |
| Communication device APIs | Implemented | Approximated with public `CommunicationDeviceType.SPEAKER` only |
| `setAllowedCapturePolicy` / `setMode` / Bluetooth SCO helpers | Implemented | **No public OHOS API**; no-op + log / null |

