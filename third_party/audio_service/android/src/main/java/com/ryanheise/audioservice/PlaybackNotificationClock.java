package com.ryanheise.audioservice;

/** Derives the displayed position from the session's monotonic clock anchor. */
final class PlaybackNotificationClock {
    private PlaybackNotificationClock() {}

    static long position(long anchor, long updatedAt, long now, float speed,
                         boolean advancing, long duration) {
        double position = Math.max(0, anchor);
        if (advancing && updatedAt > 0 && now > updatedAt && speed > 0) {
            position += (now - updatedAt) * (double)speed;
        }
        if (duration > 0) position = Math.min(position, duration);
        return (long)position;
    }
}
