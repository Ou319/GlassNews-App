import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_flutter_news/controler/search_controller.dart' as search_ctrl;
import 'package:app_flutter_news/controler/category_news_controller.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

class NewsFilterButton extends StatelessWidget {
  const NewsFilterButton({super.key, required this.builder});

  // Convenience: Search preset
  factory NewsFilterButton.search({
    required String language,
    required String country,
    required String sortBy,
    required void Function({required String language, required String country, required String sortBy}) onApply,
    required VoidCallback onReset,
  }) {
    return NewsFilterButton(
      builder: (ctx) => _SearchFiltersContent(
        language: language,
        country: country,
        sortBy: sortBy,
        onApply: onApply,
        onReset: onReset,
      ),
    );
  }

  // Convenience: Home preset (country only)
  factory NewsFilterButton.home({
    required String country,
    required void Function(String country) onApply,
    required VoidCallback onReset,
  }) {
    return NewsFilterButton(
      builder: (ctx) => _HomeFiltersContent(
        country: country,
        onApply: onApply,
        onReset: onReset,
      ),
    );
  }

  final Widget Function(BuildContext context) builder;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.tune, color: Colors.white, size: 22),
      tooltip: 'Filters',
      onPressed: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (_) => AnimatedPadding(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: DraggableScrollableSheet(
              initialChildSize: 0.5,
              minChildSize: 0.3,
              maxChildSize: 0.95,
              builder: (context, scrollController) {
                return ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: Stack(
                    children: [
                      // Background under glass (required for effect)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.blueGrey.shade900.withOpacity(0.6),
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Liquid glass layer + content
                      Positioned.fill(
                        child: LiquidGlassLayer(
                          child: LiquidGlass.inLayer(
                            shape: LiquidRoundedSuperellipse(
                              borderRadius: const Radius.circular(24),
                            ),
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.95, end: 1.0),
                              duration: const Duration(milliseconds: 280),
                              curve: Curves.easeOutCubic,
                              builder: (context, scale, child) {
                                return AnimatedOpacity(
                                  duration: const Duration(milliseconds: 240),
                                  curve: Curves.easeOut,
                                  opacity: scale == 1.0 ? 1.0 : 0.0,
                                  child: Transform.scale(
                                    scale: scale,
                                    child: child,
                                  ),
                                );
                              },
                              child: SingleChildScrollView(
                                controller: scrollController,
                                physics: const BouncingScrollPhysics(),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Handle bar
                                      Center(
                                        child: Container(
                                          width: 44,
                                          height: 5,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.28),
                                            borderRadius: BorderRadius.circular(3),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      // Stagger container wraps provided content
                                      _Stagger(child: builder(context)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Subtle shimmer overlay
                      Positioned.fill(
                        child: IgnorePointer(
                          child: _ShimmerOverlay(),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _SearchFiltersContent extends StatefulWidget {
  const _SearchFiltersContent({
    required this.language,
    required this.country,
    required this.sortBy,
    required this.onApply,
    required this.onReset,
  });

  final String language;
  final String country;
  final String sortBy;
  final void Function({required String language, required String country, required String sortBy}) onApply;
  final VoidCallback onReset;

  @override
  State<_SearchFiltersContent> createState() => _SearchFiltersContentState();
}

class _SearchFiltersContentState extends State<_SearchFiltersContent> {
  late String _lang = widget.language;
  late String _country = widget.country;
  late String _sort = widget.sortBy;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _dropdown('Language', _lang, const ['en','ar','fr','es','de','it','ru','zh'], (v){ setState(()=> _lang = v!); }),
        const SizedBox(height: 12),
        _dropdown('Country', _country, const ['us','gb','fr','de','in','ca','au','jp'], (v){ setState(()=> _country = v!); }),
        const SizedBox(height: 12),
        _dropdown('Sort by', _sort, const ['publishedAt','relevancy','popularity'], (v){ setState(()=> _sort = v!); }),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _GlassButton(
                label: 'Apply',
                onPressed: () async {
                  await _persistDefaults(language: _lang, country: _country);
                  _applyToControllers(language: _lang, country: _country);
                  widget.onApply(language: _lang, country: _country, sortBy: _sort);
                  if (mounted) Navigator.of(context).pop();
                },
              ),
            ),
            const SizedBox(width: 12),
            _GlassOutlineButton(
              label: 'Reset',
              onPressed: () async {
                setState(() { _lang = 'en'; _country = 'us'; _sort = 'publishedAt'; });
                await _persistDefaults(language: _lang, country: _country);
                _applyToControllers(language: _lang, country: _country);
                widget.onReset();
                if (mounted) Navigator.of(context).pop();
              },
            ),
          ],
        )
      ],
    );
  }

  Widget _dropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return _Stagger(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
            ),
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: const Color(0xFF101012),
              underline: const SizedBox.shrink(),
              iconEnabledColor: Colors.white,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              items: items.map((e) => DropdownMenuItem<String>(value: e, child: Text(e.toUpperCase()))).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeFiltersContent extends StatefulWidget {
  const _HomeFiltersContent({required this.country, required this.onApply, required this.onReset});

  final String country;
  final void Function(String country) onApply;
  final VoidCallback onReset;

  @override
  State<_HomeFiltersContent> createState() => _HomeFiltersContentState();
}

class _HomeFiltersContentState extends State<_HomeFiltersContent> {
  late String _country = widget.country;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _dropdown('Country', _country, const ['us','gb','fr','de','in','ca','au','jp'], (v){ setState(()=> _country = v ?? 'us'); }),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _GlassButton(
                label: 'Apply',
                onPressed: () async {
                  await _persistDefaults(language: null, country: _country);
                  _applyToControllers(language: null, country: _country);
                  widget.onApply(_country);
                  if (mounted) Navigator.of(context).pop();
                },
              ),
            ),
            const SizedBox(width: 12),
            _GlassOutlineButton(
              label: 'Reset',
              onPressed: () async {
                setState(() { _country = 'us'; });
                await _persistDefaults(language: null, country: _country);
                _applyToControllers(language: null, country: _country);
                widget.onReset();
                if (mounted) Navigator.of(context).pop();
              },
            ),
          ],
        )
      ],
    );
  }

  Widget _dropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return _Stagger(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
            ),
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: const Color(0xFF101012),
              underline: const SizedBox.shrink(),
              iconEnabledColor: Colors.white,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              items: items.map((e) => DropdownMenuItem<String>(value: e, child: Text(e.toUpperCase()))).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

// Helpers shared by filter sheets
Future<void> _persistDefaults({String? language, String? country}) async {
  final prefs = await SharedPreferences.getInstance();
  if (language != null) {
    await prefs.setString('settings_language', language);
  }
  if (country != null) {
    await prefs.setString('settings_country', country);
  }
}

void _applyToControllers({String? language, String? country}) {
  if (Get.isRegistered<search_ctrl.SearchController>()) {
    final s = Get.find<search_ctrl.SearchController>();
    if (language != null) s.updateLanguage(language);
    if (country != null) s.updateCountry(country);
    if (s.searchQuery.value.trim().isNotEmpty) {
      // ignore: discarded_futures
      s.searchNews(s.searchQuery.value);
    } else {
      // ignore: discarded_futures
      s.fetchInitialNews();
    }
  }
  if (Get.isRegistered<CategoryNewsController>() && country != null) {
    final c = Get.find<CategoryNewsController>();
    c.updateCountry(country);
  }
}


// UI helpers
class _GlassButton extends StatefulWidget {
  const _GlassButton({required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;

  @override
  State<_GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<_GlassButton> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.22), width: 1),
          ),
          child: Text(
            widget.label,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

class _GlassOutlineButton extends StatefulWidget {
  const _GlassOutlineButton({required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;

  @override
  State<_GlassOutlineButton> createState() => _GlassOutlineButtonState();
}

class _GlassOutlineButtonState extends State<_GlassOutlineButton> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.18), width: 1),
          ),
          child: Text(
            widget.label,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

class _Stagger extends StatelessWidget {
  const _Stagger({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.95, end: 1.0),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Transform.translate(
          offset: Offset(0, (1 - value) * 14),
          child: Transform.scale(
            scale: value,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 220),
              opacity: value == 1.0 ? 1.0 : 0.0,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

class _ShimmerOverlay extends StatefulWidget {
  @override
  State<_ShimmerOverlay> createState() => _ShimmerOverlayState();
}

class _ShimmerOverlayState extends State<_ShimmerOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _a;
  @override
  void initState() {
    super.initState();
    _a = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
  }
  @override
  void dispose() { _a.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _a,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.transparent, Colors.white.withOpacity(0.05), Colors.transparent],
              stops: [
                (_a.value - 0.2).clamp(0.0, 1.0),
                _a.value,
                (_a.value + 0.2).clamp(0.0, 1.0),
              ],
              begin: const Alignment(-1.0, -1.0),
              end: const Alignment(1.0, 1.0),
            ),
          ),
        );
      },
    );
  }
}
