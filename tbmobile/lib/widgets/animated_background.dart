import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({
    super.key,
    required this.child,
    this.scrollController,
    this.enableParticles = true,
    this.enableGradientMotion = true,
    this.parallaxMultiplier = 0.35,
  });

  final Widget child;
  final ScrollController? scrollController;
  final bool enableParticles;
  final bool enableGradientMotion;
  final double parallaxMultiplier;

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late CurvedAnimation _curve;
  late List<_ParticleSeed> _particles;
  double _parallaxOffset = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
    )..repeat();

    _curve = CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine);
    _particles = _generateParticles();

    widget.scrollController?.addListener(_handleParallaxScroll);
  }

  @override
  void didUpdateWidget(covariant AnimatedBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      oldWidget.scrollController?.removeListener(_handleParallaxScroll);
      widget.scrollController?.addListener(_handleParallaxScroll);
      _handleParallaxScroll();
    }
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_handleParallaxScroll);
    _controller.dispose();
    super.dispose();
  }

  void _handleParallaxScroll() {
    if (!widget.enableGradientMotion || widget.scrollController == null) return;
    final offset = widget.scrollController!.offset.clamp(-600, 600);
    final normalized = offset / 600;
    if (_parallaxOffset != normalized) {
      setState(() => _parallaxOffset = normalized);
    }
  }

  List<_ParticleSeed> _generateParticles() {
    const baseSeeds = [
      Offset(0.15, 0.18),
      Offset(0.78, 0.22),
      Offset(0.62, 0.68),
      Offset(0.28, 0.72),
      Offset(0.5, 0.42),
      Offset(0.88, 0.58),
    ];

    const radii = [0.18, 0.12, 0.15, 0.1, 0.08, 0.2];

    return List.generate(baseSeeds.length, (index) {
      final seed = baseSeeds[index];
      final radius = radii[index];
      final phase = index * 0.23;
      final speed = 0.4 + (index % 3) * 0.12;
      return _ParticleSeed(
        origin: seed,
        radiusFactor: radius,
        speed: speed,
        phase: phase,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final gradient = AppTheme.getBackgroundGradient(context);
    final isDark = AppTheme.isDarkMode(context);

    return ClipRect(
      child: AnimatedBuilder(
        animation: _curve,
        builder: (context, _) {
          final progress = _curve.value;
          final dynamicGradient = widget.enableGradientMotion
              ? _buildAnimatedGradient(gradient, progress, widget.parallaxMultiplier)
              : gradient;

          return Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(gradient: dynamicGradient),
              ),
              if (widget.enableParticles)
                CustomPaint(
                  painter: _FloatingShapesPainter(
                    progress: progress,
                    parallax: _parallaxOffset * widget.parallaxMultiplier,
                    particles: _particles,
                    isDark: isDark,
                  ),
                ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        (isDark ? Colors.black : Colors.white).withValues(alpha: isDark ? 0.03 : 0.04),
                        Colors.transparent,
                        (isDark ? Colors.black : Colors.white).withValues(alpha: isDark ? 0.04 : 0.05),
                      ],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      stops: const [0.0, 0.55, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: AnimatedOpacity(
                  opacity: 1,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  child: widget.child,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  LinearGradient _buildAnimatedGradient(
    LinearGradient base,
    double progress,
    double multiplier,
  ) {
    final wave = math.sin(progress * math.pi * 2);
    final dx = lerpDouble(-1.1, 1.1, (wave + 1) / 2)! + _parallaxOffset * multiplier;
    final dy = lerpDouble(-0.8, 0.8, (math.cos(progress * math.pi * 2) + 1) / 2)!;

    return LinearGradient(
      colors: base.colors,
      stops: base.stops,
      begin: Alignment(-dx.clamp(-1.3, 1.3), -dy.clamp(-1.2, 1.2)),
      end: Alignment(dx.clamp(-1.3, 1.3), dy.clamp(-1.2, 1.2)),
    );
  }
}

class _ParticleSeed {
  const _ParticleSeed({
    required this.origin,
    required this.radiusFactor,
    required this.speed,
    required this.phase,
  });

  final Offset origin;
  final double radiusFactor;
  final double speed;
  final double phase;
}

class _FloatingShapesPainter extends CustomPainter {
  _FloatingShapesPainter({
    required this.progress,
    required this.parallax,
    required this.particles,
    required this.isDark,
  });

  final double progress;
  final double parallax;
  final List<_ParticleSeed> particles;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final primary = isDark ? AppTheme.primaryDark : AppTheme.primaryLight;
    final accent = isDark ? AppTheme.accentDark : AppTheme.accentLight;

    for (final particle in particles) {
      final time = progress * particle.speed + particle.phase;
      final sinX = math.sin(time * math.pi * 2);
      final cosY = math.cos((time + 0.25) * math.pi * 2);

      final dx = (particle.origin.dx + sinX * 0.08 + parallax * 0.05) * size.width;
      final dy = (particle.origin.dy + cosY * 0.12) * size.height;
      final radius = particle.radiusFactor * size.shortestSide;

      final gradient = RadialGradient(
        colors: [
          Color.lerp(primary, accent, (sinX + 1) / 2)!.withValues(alpha: isDark ? 0.16 : 0.18),
          Colors.transparent,
        ],
      );

      final paint = Paint()
        ..shader = gradient.createShader(
          Rect.fromCircle(center: Offset(dx, dy), radius: radius),
        );

      canvas.drawCircle(Offset(dx, dy), radius, paint);

      final borderPaint = Paint()
        ..color = primary.withValues(alpha: isDark ? 0.12 : 0.09)
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.05;

      canvas.drawCircle(Offset(dx, dy), radius * 0.62, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _FloatingShapesPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.parallax != parallax ||
        oldDelegate.isDark != isDark;
  }
}
