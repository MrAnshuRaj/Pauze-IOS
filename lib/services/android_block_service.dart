import 'dart:io';

import 'package:flutter/services.dart';

class AndroidBlockService {
  static const MethodChannel _channel = MethodChannel('scrollrok/android');

  Future<void> setBlockedApps(List<String> packages) async {
    if (!Platform.isAndroid) {
      return;
    }
    await _channel.invokeMethod<void>('setBlockedApps', <String, dynamic>{
      'packages': packages,
    });
  }

  Future<void> unlockApps(int durationMinutes) async {
    if (!Platform.isAndroid) {
      return;
    }
    await _channel.invokeMethod<void>('unlockApps', <String, dynamic>{
      'durationMinutes': durationMinutes,
    });
  }

  Future<Map<String, dynamic>> getStats() async {
    if (!Platform.isAndroid) {
      return <String, dynamic>{};
    }

    final Map<Object?, Object?>? data =
        await _channel.invokeMapMethod<Object?, Object?>('getStats');

    return data?.map<String, dynamic>((Object? key, Object? value) {
          return MapEntry<String, dynamic>(key.toString(), value);
        }) ??
        <String, dynamic>{};
  }

  Future<bool> isBlockedAppActive() async {
    if (!Platform.isAndroid) {
      return false;
    }
    final bool? value =
        await _channel.invokeMethod<bool>('isBlockedAppActive');
    return value ?? false;
  }

  Future<bool> isAccessibilityEnabled() async {
    if (!Platform.isAndroid) {
      return false;
    }
    final bool? value =
        await _channel.invokeMethod<bool>('isAccessibilityEnabled');
    return value ?? false;
  }

  Future<void> openAccessibilitySettings() async {
    if (!Platform.isAndroid) {
      return;
    }
    await _channel.invokeMethod<void>('openAccessibilitySettings');
  }

  Future<String?> consumePendingUnlockAction() async {
    if (!Platform.isAndroid) {
      return null;
    }
    return _channel.invokeMethod<String>('consumePendingUnlockAction');
  }

  Future<void> handleUnlockChallengeCompletion({int durationMinutes = 10}) async {
    await unlockApps(durationMinutes);
  }
}
