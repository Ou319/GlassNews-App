import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:app_flutter_news/constants/app_strings.dart';
import 'package:app_flutter_news/constants/app_sizes.dart';

class ModernLoading extends StatefulWidget {
  const ModernLoading({
    super.key,
    this.size = AppSizes.containerM,
    this.color = Colors.blue,
    this.message = AppStrings.defaultLoadingMessage,
  });

  final double size;
  final Color color;
  final String message;

  @override
  State<ModernLoading> createState() => _ModernLoadingState();
}

class _ModernLoadingState extends State<ModernLoading>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late AnimationController _waveController;
  
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: AppSizes.animationSlow),
      vsync: this,
    )..repeat(reverse: true);
    
    _rotateController = AnimationController(
      duration: const Duration(milliseconds: AppSizes.animationVerySlow),
      vsync: this,
    )..repeat();
    
    _waveController = AnimationController(
      duration: const Duration(milliseconds: AppSizes.animationVerySlow),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotateController,
      curve: Curves.linear,
    ));

    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Modern animated loading indicator
          AnimatedBuilder(
            animation: Listenable.merge([
              _pulseAnimation,
              _rotateAnimation,
              _waveAnimation,
            ]),
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        widget.color.withValues(alpha: 0.1),
                        widget.color.withValues(alpha: 0.3),
                        widget.color.withValues(alpha: 0.6),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Rotating outer ring
                      Transform.rotate(
                        angle: _rotateAnimation.value,
                        child: Container(
                          width: widget.size,
                          height: widget.size,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: widget.color.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: CustomPaint(
                            painter: _LoadingRingPainter(
                              progress: _rotateAnimation.value,
                              color: widget.color,
                            ),
                          ),
                        ),
                      ),
                      // Pulsing center dot
                      Center(
                        child: Container(
                          width: widget.size * 0.3,
                          height: widget.size * 0.3,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: widget.color,
                            boxShadow: [
                              BoxShadow(
                                color: widget.color.withValues(alpha: 0.5),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Wave effect
                      ...List.generate(3, (index) {
                        final delay = index * 0.3;
                        final waveProgress = (_waveAnimation.value + delay) % 1.0;
                        final opacity = (1.0 - waveProgress) * 0.6;
                        final scale = 0.5 + (waveProgress * 1.5);
                        
                        return Center(
                          child: Transform.scale(
                            scale: scale,
                            child: Container(
                              width: widget.size,
                              height: widget.size,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: widget.color.withValues(alpha: opacity),
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          // Loading message with typing animation
          _TypingText(
            text: widget.message,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ],
      ),
    );
  }
}

class _LoadingRingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _LoadingRingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 5;

    // Draw the progress arc
    final startAngle = -math.pi / 2;
    final sweepAngle = progress * 2 * math.pi * 0.7; // 70% of full circle

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _TypingText extends StatefulWidget {
  const _TypingText({
    required this.text,
    required this.color,
  });

  final String text;
  final Color color;

  @override
  State<_TypingText> createState() => _TypingTextState();
}

class _TypingTextState extends State<_TypingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: widget.text.length * 100),
      vsync: this,
    );
    _animation = IntTween(
      begin: 0,
      end: widget.text.length,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final visibleText = widget.text.substring(0, _animation.value);
        return Text(
          visibleText,
          style: TextStyle(
            color: widget.color,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        );
      },
    );
  }
}

// Skeleton loading cards for better UX
class NewsSkeletonCard extends StatefulWidget {
  const NewsSkeletonCard({super.key});

  @override
  State<NewsSkeletonCard> createState() => _NewsSkeletonCardState();
}

class _NewsSkeletonCardState extends State<NewsSkeletonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 24,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Skeleton badge
                Container(
                  width: 60,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: _animation.value * 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Skeleton title lines
                Container(
                  width: double.infinity,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: _animation.value * 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: _animation.value * 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: _animation.value * 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Skeleton description
                Container(
                  width: double.infinity,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: _animation.value * 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: _animation.value * 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: _animation.value * 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const Spacer(),
                
                // Skeleton action buttons
                Row(
                  children: [
                    _SkeletonButton(),
                    const SizedBox(width: 16),
                    _SkeletonButton(),
                    const Spacer(),
                    _SkeletonButton(),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SkeletonButton extends StatefulWidget {
  @override
  State<_SkeletonButton> createState() => _SkeletonButtonState();
}

class _SkeletonButtonState extends State<_SkeletonButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(
      begin: 0.2,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: _animation.value * 0.1),
            borderRadius: BorderRadius.circular(22),
          ),
        );
      },
    );
  }
}
