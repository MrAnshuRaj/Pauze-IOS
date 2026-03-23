import 'dart:io';

import 'package:flutter/services.dart';

import '../models/focus_schedule.dart';

class AppSelectionResult {
  const AppSelectionResult({
    required this.selectedCount,
    required this.selectedLabels,
  });

  final int selectedCount;
  final List<String> selectedLabels;
}

class IOSBlockService {
  static const MethodChannel _channel =
      MethodChannel('scrollrok/ios_blocking');

  Future<bool> requestAuthorization() async {
    if (!Platform.isIOS) {
      return false;
    }

    final bool? granted =
        await _channel.invokeMethod<bool>('requestAuthorization');
    return granted ?? false;
  }

  Future<AppSelectionResult> selectApps() async {
    if (!Platform.isIOS) {
      return const AppSelectionResult(selectedCount: 0, selectedLabels: <String>[]);
    }

    final Map<Object?, Object?>? result =
        await _channel.invokeMapMethod<Object?, Object?>('selectApps');

    final int count = (result?['selectedCount'] as num?)?.toInt() ?? 0;
    final List<String> labels = (result?['selectedLabels'] as List<dynamic>? ?? <dynamic>[])
        .map((dynamic value) => value.toString())
        .toList(growable: false);

    return AppSelectionResult(selectedCount: count, selectedLabels: labels);
  }

  Future<void> blockApps() async {
    if (!Platform.isIOS) {
      return;
    }

    await _channel.invokeMethod<void>('blockApps');
  }

  Future<void> unblockApps({required int durationMinutes}) async {
    if (!Platform.isIOS) {
      return;
    }

    await _channel.invokeMethod<void>('unblockApps', <String, dynamic>{
      'durationMinutes': durationMinutes,
    });
  }

  Future<void> scheduleBlocking(FocusSchedule schedule) async {
    if (!Platform.isIOS) {
      return;
    }

    await _channel.invokeMethod<void>('scheduleBlocking', <String, dynamic>{
      'startHour': schedule.startHour,
      'startMinute': schedule.startMinute,
      'endHour': schedule.endHour,
      'endMinute': schedule.endMinute,
      'enabled': schedule.enabled,
    });
  }

  Future<Map<String, dynamic>> getUsageData() async {
    if (!Platform.isIOS) {
      return <String, dynamic>{};
    }

    final Map<Object?, Object?>? data =
        await _channel.invokeMapMethod<Object?, Object?>('getUsageData');
    return data?.map<String, dynamic>((Object? key, Object? value) {
          return MapEntry<String, dynamic>(key.toString(), value);
        }) ??
        <String, dynamic>{};
  }
}

