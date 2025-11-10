String formatHour(double hour) {
    double h = hour % 24;
    if (h < 0) h += 24;

    int hours = h.floor();
    int minutes = ((h - hours) * 60).round();

    if (minutes == 60) {
      hours = (hours + 1) % 24;
      minutes = 0;
    }

    final String hourStr = hours.toString().padLeft(2, '0');
    final String minStr = minutes.toString().padLeft(2, '0');
    return '$hourStr:$minStr';
  }