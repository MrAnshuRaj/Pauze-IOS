class DailyAppStats {
  DailyAppStats({
    this.unlocks = 0,
    this.sessions = 0,
    this.secondsSpent = 0,
    this.openedCount = 0,
  });

  final int unlocks;
  final int sessions;
  final int secondsSpent;
  final int openedCount;

  DailyAppStats copyWith({
    int? unlocks,
    int? sessions,
    int? secondsSpent,
    int? openedCount,
  }) {
    return DailyAppStats(
      unlocks: unlocks ?? this.unlocks,
      sessions: sessions ?? this.sessions,
      secondsSpent: secondsSpent ?? this.secondsSpent,
      openedCount: openedCount ?? this.openedCount,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'unlocks': unlocks,
      'sessions': sessions,
      'secondsSpent': secondsSpent,
      'openedCount': openedCount,
    };
  }

  factory DailyAppStats.fromJson(Map<String, dynamic> json) {
    return DailyAppStats(
      unlocks: (json['unlocks'] as num?)?.toInt() ?? 0,
      sessions: (json['sessions'] as num?)?.toInt() ?? 0,
      secondsSpent: (json['secondsSpent'] as num?)?.toInt() ?? 0,
      openedCount: (json['openedCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class DailyAnalytics {
  DailyAnalytics({
    required this.dateKey,
    required Map<String, DailyAppStats> perApp,
  }) : perApp = Map<String, DailyAppStats>.from(perApp);

  final String dateKey;
  final Map<String, DailyAppStats> perApp;

  int get totalUnlocks =>
      perApp.values.fold<int>(0, (int sum, DailyAppStats s) => sum + s.unlocks);

  int get totalSessions =>
      perApp.values.fold<int>(0, (int sum, DailyAppStats s) => sum + s.sessions);

  int get totalSeconds => perApp.values
      .fold<int>(0, (int sum, DailyAppStats s) => sum + s.secondsSpent);

  int get totalOpenedCount => perApp.values
      .fold<int>(0, (int sum, DailyAppStats s) => sum + s.openedCount);

  DailyAnalytics copyWith({
    String? dateKey,
    Map<String, DailyAppStats>? perApp,
  }) {
    return DailyAnalytics(
      dateKey: dateKey ?? this.dateKey,
      perApp: perApp ?? this.perApp,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'dateKey': dateKey,
      'perApp': perApp.map(
        (String key, DailyAppStats value) => MapEntry<String, dynamic>(
          key,
          value.toJson(),
        ),
      ),
    };
  }

  factory DailyAnalytics.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> rawPerApp =
        (json['perApp'] as Map<dynamic, dynamic>? ?? <dynamic, dynamic>{})
            .map<String, dynamic>(
      (dynamic key, dynamic value) => MapEntry<String, dynamic>(
        key.toString(),
        (value as Map).cast<String, dynamic>(),
      ),
    );

    return DailyAnalytics(
      dateKey: json['dateKey']?.toString() ?? '',
      perApp: rawPerApp.map<String, DailyAppStats>(
        (String key, dynamic value) =>
            MapEntry<String, DailyAppStats>(key, DailyAppStats.fromJson(value)),
      ),
    );
  }
}

class TotalStats {
  const TotalStats({
    this.totalUnlocks = 0,
    this.totalSessions = 0,
    this.totalSecondsSpent = 0,
    this.totalAppsOpened = 0,
  });

  final int totalUnlocks;
  final int totalSessions;
  final int totalSecondsSpent;
  final int totalAppsOpened;

  TotalStats copyWith({
    int? totalUnlocks,
    int? totalSessions,
    int? totalSecondsSpent,
    int? totalAppsOpened,
  }) {
    return TotalStats(
      totalUnlocks: totalUnlocks ?? this.totalUnlocks,
      totalSessions: totalSessions ?? this.totalSessions,
      totalSecondsSpent: totalSecondsSpent ?? this.totalSecondsSpent,
      totalAppsOpened: totalAppsOpened ?? this.totalAppsOpened,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'totalUnlocks': totalUnlocks,
      'totalSessions': totalSessions,
      'totalSecondsSpent': totalSecondsSpent,
      'totalAppsOpened': totalAppsOpened,
    };
  }

  factory TotalStats.fromJson(Map<String, dynamic> json) {
    return TotalStats(
      totalUnlocks: (json['totalUnlocks'] as num?)?.toInt() ?? 0,
      totalSessions: (json['totalSessions'] as num?)?.toInt() ?? 0,
      totalSecondsSpent: (json['totalSecondsSpent'] as num?)?.toInt() ?? 0,
      totalAppsOpened: (json['totalAppsOpened'] as num?)?.toInt() ?? 0,
    );
  }
}

