import 'package:isar/isar.dart';

part 'milestone.g.dart';

@embedded
class Milestone {
  String? description;
  DateTime? targetDate;
  double? percentage;
  bool isCompleted = false;
}
