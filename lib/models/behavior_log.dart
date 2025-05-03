class BehaviorLog {
  final String id;
  final DateTime date;
  final String behaviorType;
  final String notes;
  final String? linkedTaskId;
  final int severity; // 1 to 5

  BehaviorLog({
    required this.id,
    required this.date,
    required this.behaviorType,
    required this.notes,
    this.linkedTaskId,
    this.severity = 1,
  });
}
