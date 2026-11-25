import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';

void main() {
  test('cache keeps downloading to EOF after the initial playback range ends', () async {
    final directory = await Directory.systemTemp.createTemp('just-cache-');
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final continueDownload = Completer<void>();
    var hits = 0;
    server.listen((request) async {
      hits++;
      request.response.headers.contentType = ContentType('audio', 'mpeg');
      request.response.headers.set(HttpHeaders.acceptRangesHeader, 'bytes');
      request.response.bufferOutput = false;
      request.response.contentLength = 32768;
      request.response.add(List<int>.filled(16384, 1));
      await request.response.flush();
      await continueDownload.future;
      request.response.add(List<int>.filled(16384, 2));
      await request.response.close();
    });
    final file = File('${directory.path}/song.mp3');
    final uri = Uri.parse('http://127.0.0.1:${server.port}/song.mp3');
    final source = LockCachingAudioSource(uri, cacheFile: file);
    final fractions = <double>[];
    final subscription = source.downloadProgressStream.listen(fractions.add);
    addTearDown(() async {
      await subscription.cancel(); await server.close(force: true);
      await directory.delete(recursive: true);
    });
    final response = await source.request(0, 512);
    final bytes = await response.stream.fold<int>(0, (count, chunk) => count + chunk.length);
    expect(bytes, 512);
    // No further player requests: downloading must continue on its own.
    continueDownload.complete();
    for (var i = 0; i < 200 && !await file.exists(); i++) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    expect(await file.length(), 32768);
    expect(fractions.last, 1);
    expect(fractions.any((value) => value > 0 && value < 1), isTrue);
    expect(hits, 1);
    final cached = LockCachingAudioSource(uri, cacheFile: file);
    expect(await cached.resolve(), isA<UriAudioSource>());
    expect(hits, 1);
  });
}
