/// Sound manager for game SFX and background music.
///
/// Manages audio playback using [just_audio], with support for
/// SFX (one-shot), background music (looping), and volume control.
library;

import 'package:just_audio/just_audio.dart';
import 'package:rug/services/logging/app_logger.dart';

class SoundManager {
  SoundManager._();

  static final SoundManager instance = SoundManager._();

  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  bool _soundEnabled = true;
  bool _musicEnabled = true;
  double _musicVolume = 0.5;
  double _sfxVolume = 1.0;

  // === Configuration ===

  bool get isSoundEnabled => _soundEnabled;
  bool get isMusicEnabled => _musicEnabled;

  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
    if (!enabled) _sfxPlayer.stop();
  }

  void setMusicEnabled(bool enabled) {
    _musicEnabled = enabled;
    if (enabled) {
      _musicPlayer.play();
    } else {
      _musicPlayer.pause();
    }
  }

  void setMusicVolume(double volume) {
    _musicVolume = volume.clamp(0.0, 1.0);
    _musicPlayer.setVolume(_musicVolume);
  }

  void setSfxVolume(double volume) {
    _sfxVolume = volume.clamp(0.0, 1.0);
    _sfxPlayer.setVolume(_sfxVolume);
  }

  // === Playback ===

  /// Plays a one-shot sound effect.
  Future<void> playSfx(String assetPath) async {
    if (!_soundEnabled) return;

    try {
      await _sfxPlayer.setAsset(assetPath);
      await _sfxPlayer.setVolume(_sfxVolume);
      await _sfxPlayer.play();
    } catch (e) {
      AppLogger.error('SFX playback error', error: e);
    }
  }

  /// Plays background music (looping).
  Future<void> playMusic(String assetPath) async {
    if (!_musicEnabled) return;

    try {
      await _musicPlayer.setAsset(assetPath);
      await _musicPlayer.setVolume(_musicVolume);
      await _musicPlayer.setLoopMode(LoopMode.one);
      await _musicPlayer.play();
    } catch (e) {
      AppLogger.error('Music playback error', error: e);
    }
  }

  /// Pauses background music.
  void pauseMusic() => _musicPlayer.pause();

  /// Resumes background music.
  void resumeMusic() {
    if (_musicEnabled) _musicPlayer.play();
  }

  /// Stops all audio.
  void stopAll() {
    _musicPlayer.stop();
    _sfxPlayer.stop();
  }

  /// Disposes all audio players.
  void dispose() {
    _musicPlayer.dispose();
    _sfxPlayer.dispose();
  }
}
