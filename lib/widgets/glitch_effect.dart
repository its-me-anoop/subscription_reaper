import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class GlitchEffect extends StatefulWidget {
  final Widget child;
  final bool active;

  const GlitchEffect({super.key, required this.child, this.active = false});

  @override
  State<GlitchEffect> createState() => _GlitchEffectState();
}

class _GlitchEffectState extends State<GlitchEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Timer? _timer;
  final Random _random = Random();

  // Glitch parameters
  double _sliceOffset1 = 0;
  double _sliceOffset2 = 0;
  double _sliceHeight1 = 0;
  double _sliceHeight2 = 0;
  double _sliceTop1 = 0;
  double _sliceTop2 = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    if (widget.active) {
      _startGlitch();
    }
  }

  @override
  void didUpdateWidget(GlitchEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) {
      _startGlitch();
    } else if (!widget.active && oldWidget.active) {
      _stopGlitch();
    }
  }

  void _startGlitch() {
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        _sliceOffset1 = (_random.nextDouble() * 20) - 10;
        _sliceOffset2 = (_random.nextDouble() * 20) - 10;
        _sliceHeight1 = _random.nextDouble() * 0.2; // 20% height
        _sliceHeight2 = _random.nextDouble() * 0.2;
        _sliceTop1 = _random.nextDouble() * (1 - _sliceHeight1);
        _sliceTop2 = _random.nextDouble() * (1 - _sliceHeight2);
      });
    });
  }

  void _stopGlitch() {
    _timer?.cancel();
    setState(() {
      _sliceOffset1 = 0;
      _sliceOffset2 = 0;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) return widget.child;

    return Stack(
      children: [
        widget.child,
        // Red Channel Shift
        Positioned.fill(
          left: 3,
          child: Opacity(
            opacity: 0.7,
            child: ColorFiltered(
              colorFilter: const ColorFilter.mode(
                Colors.red,
                BlendMode.modulate,
              ),
              child: widget.child,
            ),
          ),
        ),
        // Blue Channel Shift
        Positioned.fill(
          left: -3,
          child: Opacity(
            opacity: 0.7,
            child: ColorFiltered(
              colorFilter: const ColorFilter.mode(
                Colors.blue,
                BlendMode.modulate,
              ),
              child: widget.child,
            ),
          ),
        ),
        // Slices
        ClipPath(
          clipper: _SliceClipper(_sliceTop1, _sliceHeight1),
          child: Transform.translate(
            offset: Offset(_sliceOffset1, 0),
            child: widget.child,
          ),
        ),
        ClipPath(
          clipper: _SliceClipper(_sliceTop2, _sliceHeight2),
          child: Transform.translate(
            offset: Offset(_sliceOffset2, 0),
            child: widget.child,
          ),
        ),
      ],
    );
  }
}

class _SliceClipper extends CustomClipper<Path> {
  final double topPercent;
  final double heightPercent;

  _SliceClipper(this.topPercent, this.heightPercent);

  @override
  Path getClip(Size size) {
    final path = Path();
    path.addRect(
      Rect.fromLTWH(
        0,
        size.height * topPercent,
        size.width,
        size.height * heightPercent,
      ),
    );
    return path;
  }

  @override
  bool shouldReclip(_SliceClipper oldClipper) =>
      oldClipper.topPercent != topPercent ||
      oldClipper.heightPercent != heightPercent;
}
