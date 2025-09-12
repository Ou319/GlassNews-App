import 'package:flutter/material.dart';
import 'package:app_flutter_news/view/home/home_page.dart';
import 'package:app_flutter_news/view/search/search_page.dart';
import 'package:app_flutter_news/view/save/save_page.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:get/get.dart';
import 'package:app_flutter_news/controler/navigation_bottom_bar_controler.dart';
import 'dart:math' as math;

class NavigationBottomBar extends StatefulWidget {
  const NavigationBottomBar({super.key});

  @override
  State<NavigationBottomBar> createState() => _NavigationBottomBarState();
}

class _NavigationBottomBarState extends State<NavigationBottomBar> 
    with TickerProviderStateMixin {
  final NavigationBottomBarController _navCtrl = Get.put(NavigationBottomBarController());
  late final AnimationController _liquidController;
  late final AnimationController _waveController;
  late final AnimationController _pulseController;
  late final AnimationController _pageTransitionController;
  late final AnimationController _liquidFlowController;
  
  double _scrollOffset = 0.0;
  double _dragVelocity = 0.0;
  bool _isDragging = false;

  final List<Widget> _pages = const <Widget>[
    HomePage(),
    SearchPage(),
    SavePage(),
  ];

  @override
  void initState() {
    super.initState();
    
    // Liquid morphing animation
    _liquidController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Wave ripple effect
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    // Pulse animation for active state
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // Page transition animation
    _pageTransitionController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Liquid flow animation for smooth transitions
    _liquidFlowController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..addStatusListener((status) {
        final active = status == AnimationStatus.forward || status == AnimationStatus.reverse;
        if (active) {
          if (!_waveController.isAnimating) _waveController.repeat();
          if (!_pulseController.isAnimating) _pulseController.repeat(reverse: true);
        } else {
          if (_waveController.isAnimating) _waveController.stop();
          if (_pulseController.isAnimating) _pulseController.stop();
        }
      });
  }

  @override
  void dispose() {
    _liquidController.dispose();
    _waveController.dispose();
    _pulseController.dispose();
    _pageTransitionController.dispose();
    _liquidFlowController.dispose();
    super.dispose();
  }

  void _onTap(int index) {
    if (index == _navCtrl.currentIndex.value) return;

    // Start the liquid flow animation
    _liquidFlowController.reset();
    _liquidFlowController.forward();
    
    // Start page transition
    _pageTransitionController.forward().then((_) {
      // Just change the index directly, no PageController needed
      _navCtrl.currentIndex.value = index;
      _pageTransitionController.reverse();
    });
    
    // Trigger liquid animation
    _liquidController.forward().then((_) {
      _liquidController.reverse();
    });
    
    // Create flowing wave effect
    setState(() {
      _dragVelocity = 30.0; // Simulate flow
      _isDragging = true;
    });
    
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() {
          _isDragging = false;
          _dragVelocity = 0.0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: AnimatedBuilder(
          animation: _pageTransitionController,
          builder: (context, child) {
            return Stack(
              children: [
                // Current page with slide animation
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 600),
                  switchInCurve: Curves.easeInOutCubic,
                  switchOutCurve: Curves.easeInOutCubic,
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    final slideAnimation = Tween<Offset>(
                      begin: const Offset(0.3, 0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeInOutCubic,
                    ));

                    final fadeAnimation = Tween<double>(
                      begin: 0.0,
                      end: 1.0,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
                    ));

                    return SlideTransition(
                      position: slideAnimation,
                      child: FadeTransition(
                        opacity: fadeAnimation,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    key: ValueKey<int>(_navCtrl.currentIndex.value),
                    child: _pages[_navCtrl.currentIndex.value],
                  ),
                ),
                
                // Liquid transition overlay
                if (_liquidFlowController.isAnimating)
                  AnimatedBuilder(
                    animation: _liquidFlowController,
                    builder: (context, child) {
                      return Positioned.fill(
                        child: IgnorePointer(
                          child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
            colors: [
                                  Colors.transparent,
                                  Colors.cyan.withOpacity(0.1 * _liquidFlowController.value),
                                  Colors.blue.withOpacity(0.05 * _liquidFlowController.value),
                                  Colors.transparent,
                                ],
                                stops: [
                                  0.0,
                                  _liquidFlowController.value * 0.7,
                                  _liquidFlowController.value * 0.9,
                                  1.0,
            ],
          ),
        ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: _LiquidScrollNavBar(
        currentIndex: _navCtrl.currentIndex.value,
        scrollOffset: _scrollOffset,
        dragVelocity: _dragVelocity,
        isDragging: _isDragging,
        liquidController: _liquidController,
        waveController: _waveController,
        pulseController: _pulseController,
        liquidFlowController: _liquidFlowController,
        onTap: _onTap,
        items: const [
          _NavItem(icon: Icons.home_outlined, selectedIcon: Icons.home),
          _NavItem(icon: Icons.search_outlined, selectedIcon: Icons.search),
          _NavItem(icon: Icons.bookmark_outline, selectedIcon: Icons.bookmark),
        ],
      ),
    ));
  }
}

class _LiquidScrollNavBar extends StatelessWidget {
  const _LiquidScrollNavBar({
    required this.currentIndex,
    required this.scrollOffset,
    required this.dragVelocity,
    required this.isDragging,
    required this.liquidController,
    required this.waveController,
    required this.pulseController,
    required this.liquidFlowController,
    required this.onTap,
    required this.items,
  });

  final int currentIndex;
  final double scrollOffset;
  final double dragVelocity;
  final bool isDragging;
  final AnimationController liquidController;
  final AnimationController waveController;
  final AnimationController pulseController;
  final AnimationController liquidFlowController;
  final ValueChanged<int> onTap;
  final List<_NavItem> items;

  static const double _itemSize = 64;
  static const double _navBarHeight = 95;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        liquidController, 
        waveController, 
        pulseController, 
        liquidFlowController
      ]),
      builder: (context, child) {
        // Calculate liquid morphing based on scroll
        final liquidMorph = math.sin(scrollOffset * math.pi) * 0.3;
        final wavePhase = waveController.value * 2 * math.pi;
        final pulseScale = 1.1;
        final flowIntensity = liquidFlowController.value;
        
        // Calculate scroll-based distortion
        final scrollDistortion = isDragging ? 
            math.min(dragVelocity / 50, 1.0) : 0.0;
        
        // Enhanced liquid flow effect
        final liquidFlowMorph = math.sin(flowIntensity * math.pi * 2) * 0.4;
        final liquidFlowWave = math.sin(flowIntensity * math.pi * 4) * 0.2;
        
        return Container(
          margin: const EdgeInsets.only(top: 17),
          height: _navBarHeight + MediaQuery.of(context).padding.bottom,
          child: Stack(
            children: [
              // Enhanced animated background waves shown only during interaction
              if (isDragging || flowIntensity > 0.0)
                ..._buildBackgroundWaves(wavePhase, scrollDistortion, flowIntensity),
              
              // Main liquid glass navigation
              Positioned.fill(
                child: Transform.scale(
                  scale: pulseScale + (flowIntensity * 0.05),
                  child: LiquidGlassLayer(
                    child: Container(
                    child: SafeArea(
                      top: false,
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          child: Center(
                        child: Transform(
                          transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.001)
                                ..rotateX((liquidMorph + liquidFlowMorph) * 0.1)
                                ..rotateY(scrollOffset * 0.05)
                                ..rotateZ(liquidFlowWave * 0.02),
                          alignment: Alignment.center,
                          child: Container(
                                height: 100,
                                width: 250 + (scrollDistortion * 20) + (flowIntensity * 15),
                            decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    36 + liquidMorph * 10 + liquidFlowMorph * 8
                                  ),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(
                                      0.2 + scrollDistortion * 0.1 + flowIntensity * 0.15
                                    ),
                                    width: 1 + scrollDistortion + (flowIntensity * 0.5),
                                  ),
                              boxShadow: [
                                BoxShadow(
                                      color: Colors.cyan.withOpacity(
                                        (scrollDistortion * 0.25 + flowIntensity * 0.18).clamp(0.0, 0.35)
                                      ),
                                      blurRadius: 18 + (flowIntensity * 12),
                                      spreadRadius: scrollDistortion * 3 + (flowIntensity * 5),
                                ),
                              ],
                            ),
                            child: LiquidGlass.inLayer(
                              shape: LiquidRoundedSuperellipse(
                                    borderRadius: Radius.circular(
                                      36 + liquidMorph * 10 + liquidFlowMorph * 8
                                    ),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.15 + flowIntensity * 0.1),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                          Colors.white.withOpacity(
                                            0.15 + scrollDistortion * 0.15 + flowIntensity * 0.2
                                          ),
                                          Colors.cyan.withOpacity(
                                            scrollDistortion * 0.25 + flowIntensity * 0.35
                                          ),
                                          Colors.blue.withOpacity(
                                            scrollDistortion * 0.15 + flowIntensity * 0.25
                                          ),
                                          Colors.purple.withOpacity(flowIntensity * 0.15),
                                          Colors.transparent,
                                        ],
                                      ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: List.generate(items.length, (index) {
                                          return _buildLiquidItem(
                                            index, 
                                            wavePhase, 
                                          liquidMorph + liquidFlowMorph, 
                                          scrollDistortion,
                                          flowIntensity,
                                          );
                                        }),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLiquidItem(int index, double wavePhase, double liquidMorph, 
                         double scrollDistortion, double flowIntensity) {
    final bool isSelected = index == currentIndex;
    final itemWaveOffset = (index - currentIndex) * 0.5;
    final waveHeight = math.sin(wavePhase + itemWaveOffset) * (scrollDistortion * 5 + flowIntensity * 8);
    final flowWave = math.sin(flowIntensity * math.pi * 3 + index * 0.8) * 6;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Transform.translate(
          offset: Offset(flowWave * 0.3, waveHeight + flowWave * 0.5),
          child: AnimatedContainer(
            duration: Duration(milliseconds: isDragging ? 120 : 240),
            curve: Curves.easeInOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateZ(liquidMorph * (isSelected ? 0.1 : -0.05) + flowIntensity * 0.08),
              alignment: Alignment.center,
              child: Container(
                height: _itemSize,
                decoration: isSelected
                    ? BoxDecoration(
                        borderRadius: BorderRadius.circular(32 + liquidMorph * 8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(
                              (0.22 + scrollDistortion * 0.22 + flowIntensity * 0.28).clamp(0.0, 0.5)
                            ),
                            blurRadius: 18 + scrollDistortion * 10 + flowIntensity * 12,
                            spreadRadius: scrollDistortion * 2 + flowIntensity * 3,
                          ),
                          BoxShadow(
                            color: Colors.cyan.withOpacity(
                              (scrollDistortion * 0.28 + flowIntensity * 0.35).clamp(0.0, 0.45)
                            ),
                            blurRadius: 26 + flowIntensity * 16,
                            spreadRadius: -6,
                          ),
                        ],
                      )
                    : null,
                child: isSelected
                    ? LiquidGlass.inLayer(
                        shape: LiquidRoundedSuperellipse(
                          borderRadius: Radius.circular(32 + liquidMorph * 8),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32 + liquidMorph * 8),
                            border: Border.all(
                              color: Colors.white.withOpacity(
                                0.4 + scrollDistortion * 0.15 + flowIntensity * 0.25
                              ),
                              width: 1 + scrollDistortion + flowIntensity,
                            ),
                            color: Colors.black.withOpacity(0.12 + flowIntensity * 0.08),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(
                                  0.22 + scrollDistortion * 0.18 + flowIntensity * 0.25
                                ),
                                Colors.cyan.withOpacity(
                                  scrollDistortion * 0.3 + flowIntensity * 0.4
                                ),
                                Colors.blue.withOpacity(
                                  scrollDistortion * 0.2 + flowIntensity * 0.3
                                ),
                                Colors.purple.withOpacity(flowIntensity * 0.2),
                                Colors.white.withOpacity(
                                  0.06 + flowIntensity * 0.1
                                ),
                              ],
                            ),
                          ),
                          child: _buildIcon(index, isSelected, wavePhase, scrollDistortion, flowIntensity),
                        ),
                      )
                    : _buildIcon(index, isSelected, wavePhase, scrollDistortion, flowIntensity),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(int index, bool isSelected, double wavePhase, 
                   double scrollDistortion, double flowIntensity) {
    final iconWave = math.sin(wavePhase + index * 0.3) * scrollDistortion * 2;
    final flowIconWave = math.sin(flowIntensity * math.pi * 2 + index * 0.5) * 3;
    
    return Center(
      child: Transform.translate(
        offset: Offset(iconWave + flowIconWave * 0.5, flowIconWave * 0.3),
        child: Transform.scale(
          scale: 1.0 + (flowIntensity * (isSelected ? 0.15 : 0.05)),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
              switchInCurve: Curves.elasticOut,
              switchOutCurve: Curves.easeInBack,
              transitionBuilder: (child, animation) {
              final curved = CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic);
              final turns = Tween<double>(begin: 0, end: 0.06 + flowIntensity * 0.04).animate(curved);
                return FadeTransition(
                  opacity: curved,
                child: RotationTransition(
                  turns: turns,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.995, end: 1.0 + flowIntensity * 0.1).animate(curved),
                      child: child,
                    ),
                  ),
                );
              },
              child: Icon(
                isSelected ? items[index].selectedIcon : items[index].icon,
                key: ValueKey<bool>(isSelected),
                color: isSelected 
                  ? Colors.white.withOpacity(0.95 + scrollDistortion * 0.05)
                  : Colors.white.withOpacity(0.8 - scrollDistortion * 0.1),
              size: (isSelected ? 28 : 24) + scrollDistortion * 4 + flowIntensity * 6,
              shadows: [
                  Shadow(
                  color: Colors.white.withOpacity(
                    ((isSelected ? 0.4 : 0.12) + scrollDistortion * 0.22 + flowIntensity * 0.3).clamp(0.0, 0.6)
                  ),
                  blurRadius: 12 + scrollDistortion * 7 + flowIntensity * 12,
                ),
                if (scrollDistortion > 0.3 || flowIntensity > 0.3)
                  Shadow(
                    color: Colors.cyan.withOpacity((0.5 + flowIntensity * 0.25).clamp(0.0, 0.6)),
                    blurRadius: 18 + flowIntensity * 14,
                  ),
                if (flowIntensity > 0.6)
                  Shadow(
                    color: Colors.purple.withOpacity((flowIntensity * 0.35).clamp(0.0, 0.4)),
                    blurRadius: 22,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildBackgroundWaves(double wavePhase, double scrollDistortion, double flowIntensity) {
    return List.generate(4, (index) {
      final waveOffset = index * 0.7;
      final waveOpacity = (scrollDistortion * 0.1 + flowIntensity * 0.15) * (1 - index * 0.25);
      final flowWaveOffset = math.sin(flowIntensity * math.pi * 2 + index * 0.5) * 0.5;
      
      return Positioned.fill(
        child: CustomPaint(
          painter: _WavePainter(
            wavePhase + waveOffset + flowWaveOffset,
            [
              Colors.cyan.withOpacity(waveOpacity),
              Colors.blue.withOpacity(waveOpacity * 0.8),
              Colors.purple.withOpacity(waveOpacity * 0.6),
              Colors.indigo.withOpacity(waveOpacity * 0.4),
            ][index],
            index + 1,
            flowIntensity,
          ),
        ),
      );
    });
  }
}

class _WavePainter extends CustomPainter {
  final double phase;
  final Color color;
  final int waveCount;
  final double flowIntensity;
  
  _WavePainter(this.phase, this.color, this.waveCount, this.flowIntensity);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final waveHeight = (20.0 / waveCount) + (flowIntensity * 15);
    final frequency = (0.02 * waveCount) + (flowIntensity * 0.01);
    
    path.moveTo(0, size.height);
    
    for (double x = 0; x <= size.width; x += 2) {
      final primaryWave = waveHeight * math.sin(frequency * x + phase);
      final flowWave = (waveHeight * 0.3) * math.sin(frequency * 1.5 * x + phase * 1.2);
      final y = size.height - (primaryWave + flowWave);
      path.lineTo(x, y);
    }
    
    path.lineTo(size.width, size.height);
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _NavItem {
  const _NavItem({required this.icon, required this.selectedIcon});
  final IconData icon;
  final IconData selectedIcon;
}