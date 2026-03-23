class FocusSchedule {
  const FocusSchedule({
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
    this.enabled = true,
  });

  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;
  final bool enabled;

  String get startLabel =>
      '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}';

  String get endLabel =>
      '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'startHour': startHour,
      'startMinute': startMinute,
      'endHour': endHour,
      'endMinute': endMinute,
      'enabled': enabled,
    };
  }

  factory FocusSchedule.fromJson(Map<String, dynamic> json) {
    return FocusSchedule(
      startHour: (json['startHour'] as num?)?.toInt() ?? 9,
      startMinute: (json['startMinute'] as num?)?.toInt() ?? 0,
      endHour: (json['endHour'] as num?)?.toInt() ?? 18,
      endMinute: (json['endMinute'] as num?)?.toInt() ?? 0,
      enabled: json['enabled'] as bool? ?? true,
    );
  }
}

