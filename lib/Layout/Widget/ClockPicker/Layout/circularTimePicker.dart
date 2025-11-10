import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'timePickerPainter.dart';

class Circulartimepicker extends StatefulWidget {
  final double startHour;
  final double endHour;
  // PERUBAHAN: Ganti nama 'onHourChanged' -> 'onStartHourChanged', tambahkan 'onEndHourChanged'
  final ValueChanged<double> onStartHourChanged;
  final ValueChanged<double> onEndHourChanged;

  const Circulartimepicker({
    super.key,
    required this.startHour,
    required this.endHour,
    required this.onStartHourChanged,
    required this.onEndHourChanged,});


  @override
  State<Circulartimepicker> createState() => _CirculartimepickerState();
}
enum _ActiveHandle { start, end }

class _CirculartimepickerState extends State<Circulartimepicker> {
  // PERUBAHAN: Tambahkan state untuk melacak penanda yang aktif diseret
  _ActiveHandle? _activeHandle;

  // Helper untuk mendapatkan jam dari posisi sentuhan
  double _getHourFromOffset(Offset touchPosition, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    double angle =
        math.atan2(touchPosition.dy - center.dy, touchPosition.dx - center.dx);
    angle += math.pi / 2; // Geser 0 ke atas

    if (angle < 0) {
      angle += 2 * math.pi;
    }
    return (angle / (2 * math.pi)) * 24;
  }

  // Helper untuk mencari selisih sudut terpendek (menangani wrap-around)
  double _circularDifference(double angle1, double angle2) {
    double diff = (angle1 - angle2).abs();
    return math.min(diff, 2 * math.pi - diff);
  }

  // PERUBAHAN: Logika baru untuk onPanStart
  void _handleDragStart(Offset touchPosition, Size size) {
    final double touchedHour = _getHourFromOffset(touchPosition, size);

    // Konversi semua jam ke sudut (0 - 2*PI) untuk perbandingan
    final double touchedAngle = (touchedHour / 24) * 2 * math.pi;
    final double startAngle = (widget.startHour / 24) * 2 * math.pi;
    final double endAngle = (widget.endHour / 24) * 2 * math.pi;

    // Cari tahu penanda mana yang paling dekat dengan sentuhan
    final double diffStart = _circularDifference(touchedAngle, startAngle);
    final double diffEnd = _circularDifference(touchedAngle, endAngle);

    // PERBAIKAN: Hapus setState. Atur _activeHandle secara langsung
    // agar nilainya langsung tersedia untuk _handleDragUpdate.
    _activeHandle = (diffStart < diffEnd) ? _ActiveHandle.start : _ActiveHandle.end;

    // Langsung update posisi saat pertama kali disentuh
    _handleDragUpdate(touchPosition, size);
  }

  // PERUBAHAN: Logika baru untuk onPanUpdate
  void _handleDragUpdate(Offset touchPosition, Size size) {
    if (_activeHandle == null) return; // Jika tidak ada yang aktif, jangan lakukan apa-apa

    final double newHour = _getHourFromOffset(touchPosition, size);

    // Panggil callback yang benar berdasarkan penanda yang aktif
    // PERBAIKAN: Gunakan 'else if' agar tidak salah memanggil
    // 'onEndHourChanged' saat _activeHandle masih null.
    if (_activeHandle == _ActiveHandle.start) {
      widget.onStartHourChanged(newHour);
    } else if (_activeHandle == _ActiveHandle.end) {
      widget.onEndHourChanged(newHour);
    }
  }
  
  // PERUBAHAN: Reset penanda aktif saat seretan selesai
  void _handleDragEnd() {
    setState(() {
      _activeHandle = null;
    });
  }


  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size =
            Size.square(math.min(constraints.maxWidth, constraints.maxHeight));

        return GestureDetector(
          // PERUBAHAN: Gunakan fungsi-fungsi baru
          onPanStart: (details) => _handleDragStart(details.localPosition, size),
          onPanUpdate: (details) => _handleDragUpdate(details.localPosition, size),
          onPanEnd: (details) => _handleDragEnd(), // Tambahkan ini
          onPanCancel: () => _handleDragEnd(),     // Tambahkan ini

          child: CustomPaint(
            size: size,
            // PERUBAHAN: Berikan kedua jam ke painter
            painter: TimePickerPainter(
              startHour: widget.startHour,
              endHour: widget.endHour,
            ),
          ),
        );
      },
    );
  }
}