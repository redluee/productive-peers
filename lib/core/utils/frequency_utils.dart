class FrequencySchedule {
  final bool isCustom;
  final int interval;
  final String unit; // day, week, month, year
  final Set<int> weekdays; // DateTime.monday ... DateTime.sunday

  const FrequencySchedule({
    required this.isCustom,
    required this.interval,
    required this.unit,
    required this.weekdays,
  });
}

class FrequencyUtils {
  static const List<String> units = ['day', 'week', 'month', 'year'];

  static String serializePreset(String unit) {
    return 'preset:$unit';
  }

  static String serializeCustom({
    required int interval,
    required String unit,
    required Set<int> weekdays,
  }) {
    final orderedDays = weekdays.toList()..sort();
    final daysPart = orderedDays.join(',');
    return 'custom:interval=$interval;unit=$unit;days=$daysPart';
  }

  static FrequencySchedule? parse(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final raw = value.trim();

    if (raw.startsWith('preset:')) {
      final unit = raw.substring('preset:'.length).trim().toLowerCase();
      if (units.contains(unit)) {
        return FrequencySchedule(
          isCustom: false,
          interval: 1,
          unit: unit,
          weekdays: const <int>{},
        );
      }
    }

    if (raw.startsWith('custom:')) {
      final payload = raw.substring('custom:'.length);
      final parts = payload.split(';');
      var interval = 1;
      var unit = 'week';
      var weekdays = <int>{};

      for (final part in parts) {
        final keyValue = part.split('=');
        if (keyValue.length != 2) {
          continue;
        }
        final key = keyValue[0].trim();
        final val = keyValue[1].trim();

        if (key == 'interval') {
          final parsed = int.tryParse(val);
          if (parsed != null && parsed > 0) {
            interval = parsed;
          }
        } else if (key == 'unit' && units.contains(val)) {
          unit = val;
        } else if (key == 'days' && val.isNotEmpty) {
          weekdays = val
              .split(',')
              .map((e) => int.tryParse(e.trim()))
              .whereType<int>()
              .where((d) => d >= DateTime.monday && d <= DateTime.sunday)
              .toSet();
        }
      }

      return FrequencySchedule(
        isCustom: true,
        interval: interval,
        unit: unit,
        weekdays: weekdays,
      );
    }

    // Legacy support for plain text values.
    final lower = raw.toLowerCase();
    if (lower == 'every day') {
      return const FrequencySchedule(
        isCustom: false,
        interval: 1,
        unit: 'day',
        weekdays: <int>{},
      );
    }
    if (lower == 'every week') {
      return const FrequencySchedule(
        isCustom: false,
        interval: 1,
        unit: 'week',
        weekdays: <int>{},
      );
    }
    if (lower == 'every month') {
      return const FrequencySchedule(
        isCustom: false,
        interval: 1,
        unit: 'month',
        weekdays: <int>{},
      );
    }
    if (lower == 'every year') {
      return const FrequencySchedule(
        isCustom: false,
        interval: 1,
        unit: 'year',
        weekdays: <int>{},
      );
    }

    return null;
  }

  static String formatLabel(String? value) {
    final parsed = parse(value);
    if (parsed == null) {
      return value ?? '';
    }

    if (!parsed.isCustom) {
      return 'Every ${parsed.unit}';
    }

    final intervalText = parsed.interval == 1
        ? 'Every ${parsed.unit}'
        : 'Every ${parsed.interval} ${parsed.unit}s';

    if (parsed.unit == 'week' && parsed.weekdays.isNotEmpty) {
      final dayLabels = parsed.weekdays.toList()
        ..sort();
      final short = dayLabels.map(_weekdayShort).join(', ');
      return '$intervalText on $short';
    }

    return intervalText;
  }

  static String _weekdayShort(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      case DateTime.sunday:
        return 'Sun';
      default:
        return '';
    }
  }

  static bool isExpectedOnDate({
    required FrequencySchedule schedule,
    required DateTime date,
    required DateTime anchor,
  }) {
    final current = DateTime(date.year, date.month, date.day);
    final start = DateTime(anchor.year, anchor.month, anchor.day);

    if (current.isBefore(start)) {
      return false;
    }

    if (schedule.unit == 'day') {
      final days = current.difference(start).inDays;
      return days % schedule.interval == 0;
    }

    if (schedule.unit == 'week') {
      final days = current.difference(start).inDays;
      final weeks = days ~/ 7;
      if (weeks % schedule.interval != 0) {
        return false;
      }

      if (schedule.weekdays.isNotEmpty) {
        return schedule.weekdays.contains(current.weekday);
      }

      return current.weekday == start.weekday;
    }

    if (schedule.unit == 'month') {
      final months =
          (current.year - start.year) * 12 + (current.month - start.month);
      if (months < 0 || months % schedule.interval != 0) {
        return false;
      }
      return current.day == start.day;
    }

    if (schedule.unit == 'year') {
      final years = current.year - start.year;
      if (years < 0 || years % schedule.interval != 0) {
        return false;
      }
      return current.month == start.month && current.day == start.day;
    }

    return false;
  }
}
