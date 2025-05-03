import '../models/behavior_log.dart';

class BehaviorController {
  final List<BehaviorLog> _logs = [];

  List<BehaviorLog> get logs => _logs;

  void addLog(BehaviorLog log) {
    _logs.add(log);
  }

  List<BehaviorLog> getLogsForDay(DateTime day) {
    return _logs
        .where(
          (log) =>
              log.date.year == day.year &&
              log.date.month == day.month &&
              log.date.day == day.day,
        )
        .toList();
  }

  Map<DateTime, List<BehaviorLog>> getAllLogsGroupedByDay() {
    Map<DateTime, List<BehaviorLog>> grouped = {};
    for (var log in _logs) {
      DateTime day = DateTime(log.date.year, log.date.month, log.date.day);
      if (!grouped.containsKey(day)) {
        grouped[day] = [];
      }
      grouped[day]!.add(log);
    }
    return grouped;
  }
}
