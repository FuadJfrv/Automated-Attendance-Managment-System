class Session {
  final int? id;
  final String name;
  final double sessionDuration;
  final double lateAfterDuration;
  final double absentAfterDuration;

  final DateTime scheduledStartDate;

  final bool oneTime;
  final bool daily;
  final bool weekly;
  final int dayIndex;
  final int weekIndex;

  final bool onMonday;
  final bool onTuesday;
  final bool onWednesday;
  final bool onThursday;
  final bool onFriday;
  final bool onSaturday;
  final bool onSunday;

  Session({
    this.id,
    required this.name,
    this.sessionDuration = 75.0,
    this.lateAfterDuration = 15.0,
    this.absentAfterDuration = 30.0,
    required this.scheduledStartDate,
    this.oneTime = false,
    this.daily = false,
    this.weekly = false,
    this.dayIndex = 0,
    this.weekIndex = 0,
    this.onMonday = false,
    this.onTuesday = false,
    this.onWednesday = false,
    this.onThursday = false,
    this.onFriday = false,
    this.onSaturday = false,
    this.onSunday = false,
  });


}
