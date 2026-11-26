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

## Android media notification layout

`audio_service` is vendored from fluttertpc_audio_service commit
43be9f21aa33cde5a7855691a00ce52aa06014a7 (same version as the previous Git dependency).
Only Android notification rendering is changed: compact and expanded RemoteViews,
larger expanded artwork/title, lyric subtitle, and existing media-button intents.
DecoratedMediaCustomViewStyle retains the media session and standard transport actions
for lock-screen, Bluetooth and SystemUI consumers. The foreground notification ID is unchanged.
SystemUI may use its own media template, especially on Android 13+, ignoring custom views.
The application uses the vendored music-note drawable as its notification small icon.
Gradle scripts remain in Groovy. The separate audio_service_ohos override is unchanged.
To revert, remove only the audio_service dependency override and the custom
androidNotificationIcon setting, then run flutter pub get.

The custom card uses a pale gradient, dark transport icons and elapsed/total time.
Its progress bar is display-only (RemoteViews does not offer an interactive SeekBar);
SystemUI's own media panel retains seeking through the MediaSession action bits.
NotificationCompat actions are intentionally omitted to avoid a second control row
on decorated notifications. The three RemoteViews buttons reuse media-button intents.
Progress is refreshed on incoming position changes at one-second boundaries.

Notification colors are defined in values/transient_notification_colors.xml and
values-night/transient_notification_colors.xml. Custom roots disable Force Dark;
night mode uses a dark background and light text/icons rather than relying on OEM
color inversion. Configuration changes refresh the notification even while paused.

Custom progress uses PlaybackState's elapsed-realtime anchor and playback speed,
with a native one-second refresh while playing. Pausing/buffering freezes the
estimate; seek and track changes replace the anchor. Notification updates from
lyrics, artwork and positions are coalesced to at most one per second. Refresh
callbacks are removed on stop/destruction. Clicking the progress area opens the
existing app player via AudioService.notificationClicked, where seeking is available.
