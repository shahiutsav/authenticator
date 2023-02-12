import 'dart:async';
import 'dart:math';

import 'package:authenticator/totp/services/totp_generator.dart';
import 'package:flutter/material.dart';

class TOTPCodeCard extends StatefulWidget {
  const TOTPCodeCard({super.key});

  @override
  State<TOTPCodeCard> createState() => _TOTPCodeCardState();
}

class _TOTPCodeCardState extends State<TOTPCodeCard> with SingleTickerProviderStateMixin {
  String totpCode = '';
  final int _totpDuration = 30;
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: _totpDuration),
    );
    _getTOTP();
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  void _getTOTP() {
    final currentTimestamp = DateTime.now().millisecondsSinceEpoch;
    var oneTimePin = OTP.generateTOTPCode('I53TGMCUK5CW2VTO', currentTimestamp, 'SHA1', 30);
    var oneTimePinLength = oneTimePin.toString().length;
    var numberOfZeroRequired = 6 - oneTimePinLength;
    var oneTimePinStr = oneTimePin.toString();

    while (numberOfZeroRequired != 0) {
      oneTimePinStr = '0$oneTimePinStr';
      numberOfZeroRequired--;
    }
    setState(() {
      totpCode = oneTimePinStr;
    });

    int timeUntilNextTOTP = 30 - DateTime.now().second % 30;

    Timer(Duration(seconds: timeUntilNextTOTP), () {
      _getTOTP();
    });
    _controller!.reset();
    _controller!.duration = const Duration(seconds: 30);
    _controller!.forward(from: (30 - timeUntilNextTOTP) / 30);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(totpCode),
        const SizedBox(width: 20),
        SizedBox(
          height: MediaQuery.of(context).size.width / 15,
          width: MediaQuery.of(context).size.width / 15,
          child: AnimatedBuilder(
            animation: _controller!,
            builder: (context, child) {
              return CustomPaint(
                painter: TimerPainter(
                  animation: _controller!,
                  backgroundColor: Colors.grey[200]!,
                  color: Colors.blue,
                ),
                child: Center(
                  child: Text(
                    '${30 - (30 * _controller!.value).floor()}',
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }
}

class TimerPainter extends CustomPainter {
  final Animation<double> animation;
  final Color backgroundColor;
  final Color color;

  TimerPainter({
    required this.animation,
    required this.backgroundColor,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.butt
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(size.center(Offset.zero), size.width / 2.0, paint);
    paint.color = color;
    double progress = (1.0 - animation.value) * 2 * pi;
    canvas.drawArc(Offset.zero & size, pi * 1.5, -progress, false, paint);
  }

  @override
  bool shouldRepaint(TimerPainter oldDelegate) {
    return animation.value != oldDelegate.animation.value ||
        color != oldDelegate.color ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}
