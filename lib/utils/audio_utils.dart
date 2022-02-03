import 'package:flame_audio/flame_audio.dart';

abstract class AudioUtils {
  static Future<void> loadAll() async {
    await FlameAudio.audioCache.loadAll([
      'sfx/beep.wav',
      'sfx/place.flac',
      'sfx/restart.wav',
      'sfx/slider-click.wav',
      'sfx/win.wav',
    ]);
  }

  static void playBeep() => FlameAudio.audioCache.play('sfx/beep.wav');

  static void playPlace() => FlameAudio.audioCache.play(
        'sfx/place.flac',
        volume: 0.65,
      );

  static void playRestart() => FlameAudio.audioCache.play('sfx/restart.wav');

  static void playSliderClick() =>
      FlameAudio.audioCache.play('sfx/slider-click.wav');

  static void playWin() => FlameAudio.audioCache.play('sfx/win.wav');
}
