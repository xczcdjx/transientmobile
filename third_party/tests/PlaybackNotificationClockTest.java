package com.ryanheise.audioservice;

/** Runs on a regular JVM: no device clock or sleeping is required. */
public final class PlaybackNotificationClockTest {
    private static void expect(long expected, long anchor, long updated, long now,
                               float speed, boolean advancing, long duration) {
        long actual = PlaybackNotificationClock.position(anchor, updated, now,
                speed, advancing, duration);
        if (actual != expected) {
            throw new AssertionError("Expected " + expected + ", received " + actual);
        }
    }
    public static void main(String[] args) {
        expect(8000, 5000, 10000, 13000, 1f, true, 20000);
        expect(11000, 5000, 10000, 13000, 2f, true, 20000);
        expect(5000, 5000, 10000, 13000, 1f, false, 20000); // paused/buffering
        expect(20000, 19000, 10000, 13000, 1f, true, 20000); // duration cap
        expect(3000, 2000, 20000, 21000, 1f, true, 20000); // fresh seek anchor
        expect(5000, 5000, 15000, 13000, 1f, true, 20000); // future timestamp
        expect(5000, 5000, 0, 13000, 1f, true, 20000); // missing timestamp
        expect(8000, 5000, 10000, 13000, 1f, true, 0); // unknown duration
        expect(0, -1000, 10000, 13000, 0f, true, 20000);
        System.out.println("9 notification clock checks passed");
    }
}
