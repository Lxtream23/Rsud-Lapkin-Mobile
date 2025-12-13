import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:rsud_lapkin_mobile/config/app_colors.dart';

class PremiumMenuCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final String? heroTag;
  final double? maxWidth;
  final double? maxHeight;

  const PremiumMenuCard({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.heroTag,
    this.maxWidth,
    this.maxHeight,
  });

  @override
  State<PremiumMenuCard> createState() => _PremiumMenuCardState();
}

class _PremiumMenuCardState extends State<PremiumMenuCard> {
  bool _hovered = false;
  bool _pressed = false;

  void _onEnter(bool v) => setState(() => _hovered = v);
  void _onPress(bool v) => setState(() => _pressed = v);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final size = MediaQuery.of(context).size;

    // Width card responsif + mendukung maxWidth dari parameter
    final cardWidth =
        widget.maxWidth ?? ((size.width >= 420) ? 360.0 : size.width * 0.9);

    // Height card responsif + mendukung maxHeight dari parameter
    final cardHeight =
        widget.maxHeight ?? ((size.height >= 700) ? 180.0 : 150.0);

    // Animasi depth & transform
    final elevation = _pressed ? 1.0 : (_hovered ? 10.0 : 4.0);

    final transform = _pressed
        ? (Matrix4.identity()..scale(0.995))
        : (_hovered
              ? (Matrix4.identity()..translate(0, -6, 0))
              : Matrix4.identity());

    // Widget utama
    return Center(
      child: MouseRegion(
        onEnter: (_) => _onEnter(true),
        onExit: (_) => _onEnter(false),
        child: GestureDetector(
          onTapDown: (_) => _onPress(true),
          onTapCancel: () => _onPress(false),
          onTapUp: (_) {
            _onPress(false);
            widget.onTap();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            transform: transform,
            width: cardWidth,
            height: cardHeight,
            // Card style
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: cs.outline.withOpacity(0.12), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(_hovered ? 0.08 : 0.04),
                  blurRadius: elevation,
                  offset: Offset(0, elevation / 3),
                ),
              ],
            ),
            // Card content
            child: Material(
              color: Colors.transparent,
              child: Stack(
                children: [
                  // Frosted glass effect
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: _hovered ? 6 : 2,
                        sigmaY: _hovered ? 6 : 2,
                      ),
                      child: Container(color: cs.surface.withOpacity(0.6)),
                    ),
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Icon + Hero Animation
                        if (widget.heroTag != null)
                          Hero(
                            tag: widget.heroTag!,
                            // child: _buildIconCircle(cs),
                            child: Icon(
                              widget.icon,
                              size: 80,
                              color: Colors.blueAccent,
                            ),
                          )
                        else
                          // _buildIconCircle(cs),
                          Icon(widget.icon, size: 55, color: Colors.blueAccent),

                        const SizedBox(width: 18),

                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                  color: cs.onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Tombol "Buka"
                              Align(
                                alignment: Alignment.centerLeft,
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 200),
                                  opacity: _hovered || _pressed ? 1.0 : 0.98,
                                  child: ElevatedButton(
                                    onPressed: widget.onTap,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      elevation: _hovered ? 8 : 2,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 40,
                                        vertical: 14,
                                      ),
                                    ),
                                    child: const Text(
                                      "BUKA",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Ink Ripple overlay
                  Positioned.fill(
                    child: Material(
                      type: MaterialType.transparency,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: widget.onTap,
                        splashColor: cs.primary.withOpacity(0.12),
                        highlightColor: cs.primary.withOpacity(0.06),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
