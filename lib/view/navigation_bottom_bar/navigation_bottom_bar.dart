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
    )..repeat();
    
    // Pulse animation for active state
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _liquidController.dispose();
    _waveController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    _navCtrl.onPageChanged(index);
    _liquidController.forward().then((_) {
      _liquidController.reverse();
    });
  }

  void _onTap(int index) {
    _navCtrl.onTap(index, duration: const Duration(milliseconds: 320), curve: Curves.easeInOutCubic);
    _liquidController.forward().then((_) {
      _liquidController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      extendBody: true,
      backgroundColor: Colors.white, // Changed to white for testing
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white, // White background
        ),
        child: NotificationListener<ScrollNotification>(
          onNotification: (scrollNotification) {
            if (scrollNotification is ScrollUpdateNotification) {
              setState(() {
                _scrollOffset = _navCtrl.pageController.hasClients ? 
                    (_navCtrl.pageController.page ?? 0) : 0;
                _dragVelocity = scrollNotification.scrollDelta?.abs() ?? 0;
                _isDragging = true;
              });
            } else if (scrollNotification is ScrollEndNotification) {
              setState(() {
                _isDragging = false;
                _dragVelocity = 0;
              });
            }
            return false;
          },
          child: PageView.builder(
            controller: _navCtrl.pageController,
            itemCount: _pages.length,
            physics: const BouncingScrollPhysics(),
            allowImplicitScrolling: true,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) => _pages[index],
          ),
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
  final ValueChanged<int> onTap;
  final List<_NavItem> items;

  static const double _itemSize = 64;
  static const double _navBarHeight = 95;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([liquidController, waveController, pulseController]),
      builder: (context, child) {
        // Calculate liquid morphing based on scroll
        final liquidMorph = math.sin(scrollOffset * math.pi) * 0.3;
        final wavePhase = waveController.value * 2 * math.pi;
        final pulseScale = 1.1;
        
        // Calculate scroll-based distortion
        final scrollDistortion = isDragging ? 
            math.min(dragVelocity / 50, 1.0) : 0.0;
        
        return Container(
          height: _navBarHeight + MediaQuery.of(context).padding.bottom,
        
          child: Stack(
            children: [
              // Semi-transparent dark background for better contrast
              
              // Animated background waves
              ..._buildBackgroundWaves(wavePhase, scrollDistortion),
              
              // Main liquid glass navigation
              Positioned.fill(
                child: Transform.scale(
                  scale: pulseScale,
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
                                ..rotateX(liquidMorph * 0.1)
                                ..rotateY(scrollOffset * 0.05),
                              alignment: Alignment.center,
                              child: Container(
                                height: 100,
                                width: 250 + (scrollDistortion * 20),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(36 + liquidMorph * 10),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2 + scrollDistortion * 0.1), // Increased opacity
                                    width: 1 + scrollDistortion,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.cyan.withOpacity(scrollDistortion * 0.4), // Increased opacity
                                      blurRadius: 30,
                                      spreadRadius: scrollDistortion * 5,
                                    ),
                                  ],
                                ),
                                child: LiquidGlass.inLayer(
                                  shape: LiquidRoundedSuperellipse(
                                    borderRadius: Radius.circular(36 + liquidMorph * 10),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    decoration: BoxDecoration(
                                      // Increased opacity for better visibility on white
                                      color: Colors.black.withOpacity(0.15),
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.white.withOpacity(0.15 + scrollDistortion * 0.15), // Increased opacity
                                          Colors.cyan.withOpacity(scrollDistortion * 0.25), // Increased opacity
                                          Colors.blue.withOpacity(scrollDistortion * 0.15), // Increased opacity
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
                                          liquidMorph, 
                                          scrollDistortion
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

  Widget _buildLiquidItem(int index, double wavePhase, double liquidMorph, double scrollDistortion) {
                  final bool isSelected = index == currentIndex;
    final itemWaveOffset = (index - currentIndex) * 0.5;
    final waveHeight = math.sin(wavePhase + itemWaveOffset) * (scrollDistortion * 5);
    
    return Expanded(
      child: GestureDetector(
                    onTap: () => onTap(index),
                    behavior: HitTestBehavior.opaque,
        child: Transform.translate(
          offset: Offset(0, waveHeight),
                      child: AnimatedContainer(
            duration: Duration(milliseconds: isDragging ? 120 : 240),
            curve: Curves.easeInOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateZ(liquidMorph * (isSelected ? 0.1 : -0.05)),
              alignment: Alignment.center,
              child: Container(
                height: _itemSize,
                decoration: isSelected
                    ? BoxDecoration(
                        borderRadius: BorderRadius.circular(32 + liquidMorph * 8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.3 + scrollDistortion * 0.3), // Increased opacity
                            blurRadius: 25 + scrollDistortion * 15,
                            spreadRadius: scrollDistortion * 3,
                          ),
                            BoxShadow(
                            color: Colors.cyan.withOpacity(scrollDistortion * 0.5), // Increased opacity
                            blurRadius: 40,
                            spreadRadius: -5,
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
                            // Increased border opacity for better visibility
                          border: Border.all(
                              color: Colors.white.withOpacity(0.4 + scrollDistortion * 0.15),
                              width: 1 + scrollDistortion,
                            ),
                            // Increased dark tint for better contrast
                            color: Colors.black.withOpacity(0.12),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(0.22 + scrollDistortion * 0.18), // Increased opacity
                                Colors.cyan.withOpacity(scrollDistortion * 0.3), // Increased opacity
                                Colors.blue.withOpacity(scrollDistortion * 0.2), // Increased opacity
                                Colors.white.withOpacity(0.06), // Increased opacity
                              ],
                            ),
                          ),
                          child: _buildIcon(index, isSelected, wavePhase, scrollDistortion),
                        ),
                      )
                    : _buildIcon(index, isSelected, wavePhase, scrollDistortion),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
  }

  Widget _buildIcon(int index, bool isSelected, double wavePhase, double scrollDistortion) {
    final iconWave = math.sin(wavePhase + index * 0.3) * scrollDistortion * 2;
    
    return Center(
      child: Transform.translate(
        offset: Offset(iconWave, 0),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          switchInCurve: Curves.elasticOut,
          switchOutCurve: Curves.easeInBack,
          transitionBuilder: (child, animation) {
            final curved = CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic);
            final turns = Tween<double>(begin: 0, end: 0.06).animate(curved);
            return FadeTransition(
              opacity: curved,
              child: RotationTransition(
                turns: turns,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.995, end: 1.0).animate(curved),
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
                : Colors.white.withOpacity(0.8 - scrollDistortion * 0.1), // Increased opacity
            size: (isSelected ? 28 : 24) + scrollDistortion * 4,
            shadows: [
              Shadow(
                color: Colors.white.withOpacity((isSelected ? 0.5 : 0.15) + scrollDistortion * 0.3), // Increased opacity
                blurRadius: 15 + scrollDistortion * 10,
              ),
              if (scrollDistortion > 0.3)
                Shadow(
                  color: Colors.cyan.withOpacity(0.7), // Increased opacity
                  blurRadius: 25,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildBackgroundWaves(double wavePhase, double scrollDistortion) {
    return List.generate(3, (index) {
      final waveOffset = index * 0.7;
      final waveOpacity = (scrollDistortion * 0.1) * (1 - index * 0.3);
      
      return Positioned.fill(
        child: CustomPaint(
          painter: _WavePainter(
            wavePhase + waveOffset,
            Colors.cyan.withOpacity(waveOpacity),
            index + 1,
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
  
  _WavePainter(this.phase, this.color, this.waveCount);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final waveHeight = 20.0 / waveCount;
    final frequency = 0.02 * waveCount;
    
    path.moveTo(0, size.height);
    
    for (double x = 0; x <= size.width; x += 2) {
      final y = size.height - waveHeight * math.sin(frequency * x + phase);
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