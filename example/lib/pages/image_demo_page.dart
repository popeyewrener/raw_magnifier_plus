import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:raw_magnifier_plus/raw_magnifier_plus.dart';

// ─── Shape option model ───────────────────────────────────────────────────

class _ShapeOption {
  const _ShapeOption({
    required this.label,
    required this.icon,
    required this.shape,
  });
  final String label;
  final IconData icon;
  final ShapeBorder shape;
}

const _shapeOptions = <_ShapeOption>[
  _ShapeOption(
    label: 'Circle',
    icon: Icons.circle_outlined,
    shape: CircleBorder(),
  ),
  _ShapeOption(
    label: 'Rounded',
    icon: Icons.crop_square_rounded,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),
    ),
  ),
  _ShapeOption(
    label: 'Stadium',
    icon: Icons.panorama_fish_eye_rounded,
    shape: StadiumBorder(),
  ),
  _ShapeOption(
    label: 'Star',
    icon: Icons.star_outline_rounded,
    shape: StarBorder(points: 6, innerRadiusRatio: 0.55),
  ),
];

// ─── Page ─────────────────────────────────────────────────────────────────

class ImageDemoPage extends StatefulWidget {
  const ImageDemoPage({super.key});

  @override
  State<ImageDemoPage> createState() => _ImageDemoPageState();
}

class _ImageDemoPageState extends State<ImageDemoPage> {
  int _shapeIndex = 0;
  double _scale = 2.5;
  double _loupeSize = 130;
  bool _isPressing = false;

  ShapeBorder get _shape => _shapeOptions[_shapeIndex].shape;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────
          _PageHeader(
            title: 'Image Zoom',
            subtitle: 'Press & drag on the photo to magnify',
            accent: cs.primary,
          ),

          // ── Image + Loupe ───────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: _MagnifiableImage(
                  shape: _shape,
                  scale: _scale,
                  loupeSize: _loupeSize,
                  onPressingChanged: (v) => setState(() => _isPressing = v),
                ),
              ),
            ),
          ),

          // ── Settings ────────────────────────────────────────────────────
          _SettingsPanel(
            shapeOptions: _shapeOptions,
            selectedShapeIndex: _shapeIndex,
            scale: _scale,
            loupeSize: _loupeSize,
            onShapeChanged: (i) => setState(() => _shapeIndex = i),
            onScaleChanged: (v) => setState(() => _scale = v),
            onSizeChanged: (v) => setState(() => _loupeSize = v),
          ),

          // ── Hint pill ───────────────────────────────────────────────────
          _HintPill(
            label: _isPressing ? 'Magnifying…' : 'Tap & drag to zoom',
            active: _isPressing,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─── Magnifiable image ────────────────────────────────────────────────────

class _MagnifiableImage extends StatelessWidget {
  const _MagnifiableImage({
    required this.shape,
    required this.scale,
    required this.loupeSize,
    required this.onPressingChanged,
  });
  final ShapeBorder shape;
  final double scale;
  final double loupeSize;
  final ValueChanged<bool> onPressingChanged;

  @override
  Widget build(BuildContext context) {
    return DraggableLoupe(
      loupeSize: Size(loupeSize, loupeSize),
      magnificationScale: scale,
      shape: shape,
      verticalOffset: 95,
      overlayBuilder: (ctx) => Container(
        decoration: ShapeDecoration(
          shape: shape,
          color: Colors.transparent,
        ),
        foregroundDecoration: ShapeDecoration(
          shape: shape,
          color: Colors.transparent,
        ),
        child: DecoratedBox(
          decoration: ShapeDecoration(
            shape: shape,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withAlpha(26),
                Colors.transparent,
                Colors.transparent,
                Colors.black.withAlpha(26),
              ],
              stops: const [0.0, 0.25, 0.75, 1.0],
            ),
          ),
        ),
      ),
      child: GestureDetector(
        onPanStart: (_) => onPressingChanged(true),
        onPanEnd: (_) => onPressingChanged(false),
        onPanCancel: () => onPressingChanged(false),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // High-res product-style photo from picsum
            Image.network(
              'https://picsum.photos/seed/camera/800/1200',
              fit: BoxFit.cover,
              loadingBuilder: (ctx, child, progress) {
                if (progress == null) return child;
                return Container(
                  color: const Color(0xFF1A1A2E),
                  child: Center(
                    child: CircularProgressIndicator(
                      value: progress.expectedTotalBytes != null
                          ? progress.cumulativeBytesLoaded /
                              progress.expectedTotalBytes!
                          : null,
                      color: const Color(0xFF7C4DFF),
                      strokeWidth: 2,
                    ),
                  ),
                );
              },
            ),
            // Subtle corner badge
            Positioned(
              right: 12,
              bottom: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withAlpha(30),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  'picsum.photos',
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    color: Colors.white54,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shared: Page header ──────────────────────────────────────────────────

class _PageHeader extends StatelessWidget {
  const _PageHeader({
    required this.title,
    required this.subtitle,
    required this.accent,
  });
  final String title;
  final String subtitle;
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
                title,
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: Colors.white54,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: accent.withAlpha(26),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: accent.withAlpha(76), width: 0.5),
            ),
            child: Text(
              'RawMagnifier',
              style: GoogleFonts.outfit(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: accent,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared: Settings panel ───────────────────────────────────────────────

class _SettingsPanel extends StatelessWidget {
  const _SettingsPanel({
    required this.shapeOptions,
    required this.selectedShapeIndex,
    required this.scale,
    required this.loupeSize,
    required this.onShapeChanged,
    required this.onScaleChanged,
    required this.onSizeChanged,
  });
  final List<_ShapeOption> shapeOptions;
  final int selectedShapeIndex;
  final double scale;
  final double loupeSize;
  final ValueChanged<int> onShapeChanged;
  final ValueChanged<double> onScaleChanged;
  final ValueChanged<double> onSizeChanged;

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF7C4DFF);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withAlpha(15),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shape chips
          _SettingLabel('Lens Shape'),
          const SizedBox(height: 8),
          Row(
            children: List.generate(shapeOptions.length, (i) {
              final opt = shapeOptions[i];
              final selected = i == selectedShapeIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onShapeChanged(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? accent.withAlpha(51)
                          : Colors.white.withAlpha(10),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected
                            ? accent.withAlpha(179)
                            : Colors.white.withAlpha(20),
                        width: selected ? 1.5 : 0.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          opt.icon,
                          size: 18,
                          color: selected ? accent : Colors.white38,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          opt.label,
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            color: selected ? accent : Colors.white38,
                            fontWeight:
                                selected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 14),

          // Scale slider
          _SliderRow(
            label: 'Zoom',
            value: scale,
            min: 1.5,
            max: 5.0,
            displayText: '${scale.toStringAsFixed(1)}×',
            onChanged: onScaleChanged,
            accent: accent,
          ),

          const SizedBox(height: 8),

          // Size slider
          _SliderRow(
            label: 'Size',
            value: loupeSize,
            min: 80,
            max: 200,
            displayText: '${loupeSize.round()}px',
            onChanged: onSizeChanged,
            accent: const Color(0xFF00E5FF),
          ),
        ],
      ),
    );
  }
}

class _SettingLabel extends StatelessWidget {
  const _SettingLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.outfit(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: Colors.white38,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.displayText,
    required this.onChanged,
    required this.accent,
  });
  final String label;
  final double value;
  final double min;
  final double max;
  final String displayText;
  final ValueChanged<double> onChanged;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 36,
          child: Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white38,
              letterSpacing: 0.5,
            ),
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
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ),
        Container(
          width: 44,
          alignment: Alignment.centerRight,
          child: Text(
            displayText,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Shared: Hint pill ────────────────────────────────────────────────────

class _HintPill extends StatelessWidget {
  const _HintPill({required this.label, required this.active});
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFF7C4DFF).withAlpha(38)
            : Colors.white.withAlpha(10),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: active
              ? const Color(0xFF7C4DFF).withAlpha(128)
              : Colors.white.withAlpha(20),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            active ? Icons.search_rounded : Icons.touch_app_outlined,
            size: 14,
            color: active ? const Color(0xFF7C4DFF) : Colors.white38,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: active ? const Color(0xFF7C4DFF) : Colors.white38,
            ),
          ),
        ],
      ),
    );
  }
}
