import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:raw_magnifier_plus/raw_magnifier_plus.dart';

// ─── Page ─────────────────────────────────────────────────────────────────

class UIDemoPage extends StatefulWidget {
  const UIDemoPage({super.key});

  @override
  State<UIDemoPage> createState() => _UIDemoPageState();
}

class _UIDemoPageState extends State<UIDemoPage>
    with SingleTickerProviderStateMixin {
  int _shapeIndex = 0;
  double _scale = 2.5;

  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  static const _shapes = <String, ShapeBorder>{
    'Circle': CircleBorder(),
    'Rounded': RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),
    ),
    'Stadium': StadiumBorder(),
    'Star': StarBorder(points: 5, innerRadiusRatio: 0.5),
  };

  List<MapEntry<String, ShapeBorder>> get _shapeEntries =>
      _shapes.entries.toList();

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final entry = _shapeEntries[_shapeIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────
          _Header(accent: cs.secondary),

          // ── Main magnifiable area ────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: DraggableLoupe(
                  loupeSize: const Size(140, 140),
                  magnificationScale: _scale,
                  shape: entry.value,
                  verticalOffset: 100,
                  child: _UICanvas(pulseAnim: _pulse),
                ),
              ),
            ),
          ),

          // ── Controls ────────────────────────────────────────────────────
          _Controls(
            shapeNames: _shapeEntries.map((e) => e.key).toList(),
            selectedIndex: _shapeIndex,
            scale: _scale,
            onShapeChanged: (i) => setState(() => _shapeIndex = i),
            onScaleChanged: (v) => setState(() => _scale = v),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.accent});
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 16,
        20,
        12,
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [accent, accent.withAlpha(76)],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'UI Magnifier',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Magnify any Flutter widget — not just images',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Rich UI canvas (the "content" to magnify) ────────────────────────────

class _UICanvas extends StatelessWidget {
  const _UICanvas({required this.pulseAnim});
  final Animation<double> pulseAnim;

  static const _swatches = <Color>[
    Color(0xFF7C4DFF),
    Color(0xFF00E5FF),
    Color(0xFFFF6B9D),
    Color(0xFFFFD740),
    Color(0xFF00E676),
    Color(0xFFFF6D00),
    Color(0xFF82B1FF),
    Color(0xFFEA80FC),
    Color(0xFFCCFF90),
    Color(0xFFFF9E80),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0D0D1A), Color(0xFF16213E), Color(0xFF1A1A2E)],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title ─────────────────────────────────────────────────────
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF7C4DFF), Color(0xFF00E5FF)],
              ).createShader(bounds),
              child: Text(
                'raw_magnifier_plus',
                style: GoogleFonts.outfit(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Powered by RawMagnifier — zero dependencies',
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: Colors.white54,
              ),
            ),

            const SizedBox(height: 20),

            // ── Color swatches ────────────────────────────────────────────
            Text(
              'COLOR PALETTE',
              style: GoogleFonts.outfit(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.white30,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _swatches.map((c) {
                return Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: c,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: c.withAlpha(128),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // ── Typography samples ────────────────────────────────────────
            Text(
              'TYPOGRAPHY',
              style: GoogleFonts.outfit(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.white30,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aa Bb Cc Dd Ee Ff',
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -1,
              ),
            ),
            Text(
              'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
              style: GoogleFonts.robotoMono(
                fontSize: 12,
                color: const Color(0xFF00E5FF),
                letterSpacing: 1.5,
              ),
            ),
            Text(
              '0123456789 !@#\$%^&*()',
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: Colors.white54,
              ),
            ),

            const SizedBox(height: 20),

            // ── Icon grid ─────────────────────────────────────────────────
            Text(
              'ICONS',
              style: GoogleFonts.outfit(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.white30,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: const [
                Icons.star_rounded,
                Icons.favorite_rounded,
                Icons.bolt_rounded,
                Icons.diamond_rounded,
                Icons.rocket_launch_rounded,
                Icons.auto_awesome_rounded,
                Icons.gradient_rounded,
                Icons.blur_on_rounded,
                Icons.lens_rounded,
                Icons.center_focus_strong_rounded,
              ]
                  .map(
                    (icon) => Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(10),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withAlpha(20),
                          width: 0.5,
                        ),
                      ),
                      child: Icon(icon, color: Colors.white70, size: 22),
                    ),
                  )
                  .toList(),
            ),

            const SizedBox(height: 20),

            // ── Glassmorphism cards ───────────────────────────────────────
            Text(
              'GLASSMORPHISM',
              style: GoogleFonts.outfit(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.white30,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _GlassCard(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C4DFF), Color(0xFF00E5FF)],
                  ),
                  icon: Icons.lens_rounded,
                  label: 'Loupe',
                  value: '2.5×',
                ),
                const SizedBox(width: 10),
                _GlassCard(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B9D), Color(0xFFFFD740)],
                  ),
                  icon: Icons.center_focus_strong_rounded,
                  label: 'Focus',
                  value: '∞',
                ),
                const SizedBox(width: 10),
                _GlassCard(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00E676), Color(0xFF00E5FF)],
                  ),
                  icon: Icons.bolt_rounded,
                  label: 'Speed',
                  value: '60fps',
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Gradient strips ───────────────────────────────────────────
            Text(
              'GRADIENTS',
              style: GoogleFonts.outfit(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.white30,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            ...[
              [const Color(0xFF7C4DFF), const Color(0xFF00E5FF)],
              [const Color(0xFFFF6B9D), const Color(0xFFFFD740)],
              [const Color(0xFF00E676), const Color(0xFF7C4DFF)],
            ].map(
              (colors) => Container(
                height: 16,
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: colors),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            // Animate circles
            const SizedBox(height: 16),
            ScaleTransition(
              scale: pulseAnim,
              child: Center(
                child: CustomPaint(
                  size: const Size(120, 60),
                  painter: _CirclePatternPainter(),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({
    required this.gradient,
    required this.icon,
    required this.label,
    required this.value,
  });
  final Gradient gradient;
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withAlpha(15),
              Colors.white.withAlpha(5),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withAlpha(30),
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShaderMask(
              shaderCallback: (b) => gradient.createShader(b),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 10,
                color: Colors.white38,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CirclePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const colors = [
      Color(0xFF7C4DFF),
      Color(0xFF00E5FF),
      Color(0xFFFF6B9D),
      Color(0xFFFFD740),
    ];
    final radius = size.height / 2;
    for (int i = 0; i < colors.length; i++) {
      final paint = Paint()
        ..color = colors[i].withAlpha(204)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(
        Offset(radius + (size.width / colors.length) * i, radius),
        radius * 0.85,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── Controls ─────────────────────────────────────────────────────────────

class _Controls extends StatelessWidget {
  const _Controls({
    required this.shapeNames,
    required this.selectedIndex,
    required this.scale,
    required this.onShapeChanged,
    required this.onScaleChanged,
  });
  final List<String> shapeNames;
  final int selectedIndex;
  final double scale;
  final ValueChanged<int> onShapeChanged;
  final ValueChanged<double> onScaleChanged;

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF00E5FF);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(15), width: 0.5),
      ),
      child: Column(
        children: [
          // Shape chips
          Row(
            children: List.generate(shapeNames.length, (i) {
              final sel = i == selectedIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onShapeChanged(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: sel
                          ? accent.withAlpha(38)
                          : Colors.white.withAlpha(10),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: sel
                            ? accent.withAlpha(179)
                            : Colors.white.withAlpha(20),
                        width: sel ? 1.5 : 0.5,
                      ),
                    ),
                    child: Text(
                      shapeNames[i],
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight:
                            sel ? FontWeight.w600 : FontWeight.w400,
                        color: sel ? accent : Colors.white38,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 12),

          // Scale slider
          Row(
            children: [
              Text(
                'Zoom',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white38,
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: accent,
                    inactiveTrackColor: accent.withAlpha(38),
                    thumbColor: accent,
                    overlayColor: accent.withAlpha(26),
                    trackHeight: 2.5,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 7),
                  ),
                  child: Slider(
                    value: scale,
                    min: 1.5,
                    max: 5.0,
                    onChanged: onScaleChanged,
                  ),
                ),
              ),
              SizedBox(
                width: 40,
                child: Text(
                  '${scale.toStringAsFixed(1)}×',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
