import 'dart:math' as math;
import 'package:flutter/material.dart';

// REKOMENDASI: Nama class menggunakan UpperCamelCase (T besar)
class TimePickerPainter extends CustomPainter {
  // PERUBAHAN: Terima 'startHour' dan 'endHour'
  final double startHour;
  final double endHour;
  final Color primary;
  final Color secondary;
  final Color bg;

  TimePickerPainter({
    this.primary = const Color.fromARGB(255, 255, 255, 255),
    this.secondary = const Color.fromARGB(255, 153, 153, 153),
    this.bg = const Color.fromARGB(155, 153, 153, 153),
    required this.startHour,
    required this.endHour,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2.5;

    // ... (Semua setup Paint sama)
    final paintOuterCircle = Paint()
      ..color = secondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final paintOuterCircleFade = Paint()
      ..color = secondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final paintOuterCircleSecond = Paint()
      ..color = secondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    
    final paintOuterCircleBG = Paint()
      ..color = bg
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    // PERUBAHAN: Ganti nama dan gaya 'selector' menjadi 'hand' (jarum)
    final paintHandEnd = Paint()
      ..color = Colors.redAccent
      ..style = PaintingStyle.stroke // Ganti ke stroke
      ..strokeWidth = 6 // Atur ketebalan jarum
      ..strokeCap = StrokeCap.round; // Buat ujungnya bulat
    final paintHandEndFill = Paint()
      ..color = Colors.redAccent
      ..style = PaintingStyle.fill // Ganti ke stroke
      ..strokeWidth = 6 // Atur ketebalan jarum
      ..strokeCap = StrokeCap.round; 

    final paintHandStart = Paint()
      ..color = Colors.tealAccent
      ..style = PaintingStyle.stroke // Ganti ke stroke
      ..strokeWidth = 6 // Atur ketebalan jarum
      ..strokeCap = StrokeCap.round; // Buat ujungnya bulat
    final paintHandStartFill = Paint()
      ..color = Colors.tealAccent
      ..style = PaintingStyle.fill // Ganti ke stroke
      ..strokeWidth = 6 // Atur ketebalan jarum
      ..strokeCap = StrokeCap.round;

    // HAPUS: paintSelectorStroke tidak diperlukan lagi
    // final paintSelectorStroke = Paint()
    //   ..color = Colors.black
    //   ..style = PaintingStyle.stroke
    //   ..strokeWidth = 3;

    // 1. Gambar lingkaran dalam dan luar
    canvas.drawCircle(center, radius, paintOuterCircleSecond);
    canvas.drawCircle(center, radius * 0.85, paintOuterCircle);
    canvas.drawCircle(center * 0.52, radius * 0.3 , paintOuterCircleBG);
    canvas.drawCircle(center * 1.08, radius * 0.68 , paintOuterCircleBG);
    canvas.drawCircle(center * 1, radius * 0.01 , paintOuterCircleBG);
    canvas.drawCircle(center * 1, radius * 1.32 , paintOuterCircleFade);
    canvas.drawCircle(center * 1, radius * 1.25 , paintOuterCircle);





    // 2. Gambar label angka (0, 6, 12, 18)
    _paintText(canvas, size, "0", 0);
    _paintText(canvas, size, "6", 6);
    _paintText(canvas, size, "12", 12);
    _paintText(canvas, size, "18", 18);

    // 3. Hitung posisi penanda (selector)
    // --- PENANDA MULAI (START) ---
    final angleStart = (startHour / 24) * 2 * math.pi - (math.pi / 2);
    final angleEnd = (endHour / 24) * 2 * math.pi - (math.pi / 2);
    final selectorPosStart = Offset(
      center.dx + radius * math.cos(angleStart),
      center.dy + radius * math.sin(angleStart),
    );

    // --- PERUBAHAN: PENANDA SELESAI (END) ---
    final selectorPosEnd = Offset(
      center.dy + radius * math.cos(angleEnd),
      center.dy + radius * math.sin(angleEnd),
    );

    // 4. Gambar penanda (Jarum Jam)
    // PERUBAHAN: Ganti drawCircle menjadi drawLine
    
    // Gambar jarum SELESAI (merah)
    canvas.drawLine(center, selectorPosEnd, paintHandEnd);
    // 4. Gambar penanda
    // Gambar penanda SELESAI (merah) terlebih dahulu
    canvas.drawCircle(selectorPosEnd, 20, paintHandEndFill);
    canvas.drawCircle(selectorPosEnd, 20, paintHandEndFill);
    
    // Gambar penanda MULAI (teal) di atasnya (jika tumpang tindih)
    canvas.drawCircle(selectorPosStart, 20, paintHandStartFill);
    canvas.drawCircle(selectorPosStart, 20, paintHandStartFill);
    // Gambar jarum MULAI (teal)
    canvas.drawLine(center, selectorPosStart, paintHandStart);

    // TAMBAHAN: Gambar lingkaran di tengah agar rapi
    final paintCenterDot = Paint()
      ..color = primary // Ambil dari warna primer
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 8, paintCenterDot); // Lingkaran di tengah
    final paintCenterDotStroke = Paint()
      ..color = secondary // Ambil dari warna sekunder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, 8, paintCenterDotStroke); // Stroke lingkaran
  }

  // ... (Helper _paintText tidak berubah)
  void _paintText(Canvas canvas, Size size, String text, double hour) {
    final radius = size.width / 2;
    final center = Offset(size.width / 2, size.height / 2);

    final radiusBG = size.width / 15;

    final angle = (hour / 24) * 2 * math.pi - (math.pi / 2);
    final paintOuterCircle = Paint()
      ..color = secondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
      

    final paintInnerCircle = Paint()
      ..color = primary
      ..style = PaintingStyle.fill;
    


    final textPos = Offset(
      center.dx + (radius * 0.65) * math.cos(angle),
      center.dy + (radius * 0.65) * math.sin(angle),
    );
    canvas.drawCircle(textPos, radiusBG, paintOuterCircle);
    canvas.drawCircle(textPos, radiusBG, paintInnerCircle);


    final textSpan = TextSpan(
      text: text,
      style: const TextStyle(
        color: Color.fromARGB(255, 0, 0, 0),
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    
    final textOffset = Offset(
      textPos.dx - (textPainter.width / 2),
      textPos.dy - (textPainter.height / 2),
    );
    
    textPainter.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(covariant TimePickerPainter oldDelegate) {
    // PERUBAHAN: Gambar ulang jika SALAH SATU jam berubah
    return oldDelegate.startHour != startHour || oldDelegate.endHour != endHour;
  }
}