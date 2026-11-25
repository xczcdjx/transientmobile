# Harmony background audio patch

These project-local platform implementations are selected by pubspec.yaml dependency_overrides.
Flutter remains on 3.22; no other platforms are changed.

Sources:
- audio_service_ohos: fluttertpc_audio_service commit 43be9f21aa33cde5a7855691a00ce52aa06014a7.
- audioplayers_ohos: flutter_audioplayers commit 5b1f0f972b200b543b5ac27c46f8efba63662e12.

Changes:
- audio_service alone owns AVSession and AUDIO_PLAYBACK tasks. The audioplayers platform implementation is intended for this application together with audio_service, not standalone use.
- Activate AVSession before starting the background task.
- Serialize background task start/stop; set active only after success, retry startup up to three times, and log failures.
- Correct the audioplayers_ohos Dart constraint for this Dart 3.4 project.

Build using the Harmony Flutter SDK: flutter pub get, then flutter build hap --debug.
Test continuous playback while locked, background track transitions, pause/resume from the media panel, and return to foreground. Check AudioService logs for Background audio task started/start failed/stopped.

To revert: remove both local dependency_overrides and run flutter pub get again.

Task lifecycle regression check (mocked Harmony APIs): `node third_party/tests/background_task_test.cjs`. This does not replace device testing.

## just_audio migration

The production player uses just_audio 0.10.5 from CPF-Flutter tag
0.10.5-ohos-1.0.1 (commit e366bb5858812da73b204ac5f071b9d2cdd11ebe).
Its OHOS MediaAvPlayer session creation is disabled because audio_service owns
the system media session and background task. audio_session 0.2.2 is vendored
from CPF-Flutter br_v0.2.2_ohos (commit 62af3718564bca39e8eba77c9cf8a75aeebfd43e);
the local copy avoids Git LFS checkout failures in the dependency cache.

JustAudioPlayback preserves existing handler/UI interfaces while using
LockCachingAudioSource and downloadProgressStream for actual continuous file
download. The bar maps downloaded bytes to track duration (approximate for VBR);
loading animation still follows player buffering state. Cache uses just_audio's
temporary cache directory and is not a permanent offline-download library.
