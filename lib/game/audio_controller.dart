import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';

class AudioController {
  static final AudioController _instance = AudioController._internal();
  factory AudioController() => _instance;
  AudioController._internal();

  AudioPlayer? _bgmPlayer;
  bool _isMuted = false;
  final math.Random _random = math.Random();

  // Local audio assets (located under assets/audio/ folder)
  static const String sfxHitAsset = "audio/sfx_hit.wav";
  static const String sfxCoinAsset = "audio/sfx_coin.wav";
  static const String sfxBuffAsset = "audio/sfx_buff.wav";
  static const String sfxWinAsset = "audio/sfx_win.wav";
  static const String sfxLoseAsset = "audio/sfx_lose.wav";

  Future<void> init() async {
    try {
      _bgmPlayer = AudioPlayer();
      await _bgmPlayer?.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer?.setVolume(0.12); // Keep background music subtle
    } catch (e) {
      // Fail silently if audio is unavailable
    }
  }

  Future<void> playBGM() async {
    if (_isMuted) return;
    try {
      if (_bgmPlayer == null) {
        await init();
      }
      
      // Randomly select one of the 8 BGM tracks (neon_bgm_1.mp3 to neon_bgm_8.mp3)
      int trackNumber = _random.nextInt(8) + 1;
      String bgmAsset = "audio/neon_bgm_$trackNumber.mp3";
      
      await _bgmPlayer?.play(AssetSource(bgmAsset));
    } catch (e) {
      // Fail silently
    }
  }

  Future<void> stopBGM() async {
    try {
      await _bgmPlayer?.stop();
    } catch (e) {
      // Fail silently
    }
  }

  Future<void> pauseBGM() async {
    try {
      await _bgmPlayer?.pause();
    } catch (e) {
      // Fail silently
    }
  }

  Future<void> resumeBGM() async {
    if (_isMuted) return;
    try {
      await _bgmPlayer?.resume();
    } catch (e) {
      // Fail silently
    }
  }

  /// Plays short SFX in a decoupled, fire-and-forget way that supports overlapping using AssetSource
  void playSFX(String type) {
    if (_isMuted) return;
    
    String assetPath = sfxHitAsset;
    double volume = 0.5;

    switch (type) {
      case 'coin':
        assetPath = sfxCoinAsset;
        volume = 0.45;
        break;
      case 'buff':
        assetPath = sfxBuffAsset;
        volume = 0.55;
        break;
      case 'win':
        assetPath = sfxWinAsset;
        volume = 0.60;
        break;
      case 'lose':
        assetPath = sfxLoseAsset;
        volume = 0.60;
        break;
      case 'hit':
      default:
        assetPath = sfxHitAsset;
        volume = 0.35;
    }

    try {
      final player = AudioPlayer();
      player.setVolume(volume).then((_) {
        player.play(AssetSource(assetPath)).then((_) {
          // Auto dispose player after reproduction finishes to avoid memory leaks
          player.onPlayerComplete.listen((_) {
            player.dispose();
          });
        });
      });
    } catch (e) {
      // Fail silently
    }
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    if (_isMuted) {
      _bgmPlayer?.setVolume(0.0);
    } else {
      _bgmPlayer?.setVolume(0.12);
    }
  }

  bool get isMuted => _isMuted;

  void dispose() {
    _bgmPlayer?.dispose();
  }
}
