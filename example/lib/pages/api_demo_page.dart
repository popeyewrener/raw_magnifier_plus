import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:raw_magnifier_plus/raw_magnifier_plus.dart';

// ─── Page ─────────────────────────────────────────────────────────────────

/// Demonstrates the low-level [Loupe] widget and [LoupeController] directly.
/// Users can move the loupe with sliders and observe the focalPointOffset
/// effect in real time — great for understanding the raw API.
class ApiDemoPage extends StatefulWidget {
  const ApiDemoPage({super.key});

  @override
  State<ApiDemoPage> createState() => _ApiDemoPageState();
}

class _ApiDemoPageState extends State<ApiDemoPage> {
  // Loupe position (left/top of loupe widget in the preview area)
  double _loupeX = 100;
  double _loupeY = 60;

  // focalPointOffset
  double _focalDX = 0;
  double _focalDY = 0;

  double _scale = 2.5;
  int _shapeIndex = 0;

  static const _shapes = <String, ShapeBorder>{
    'Circle': CircleBorder(),
    'Rounded': RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
    'Stadium': StadiumBorder(),
    'Star': StarBorder(points: 5),
  };

  List<MapEntry<String, ShapeBorder>> get _shapeEntries =>
      _shapes.entries.toList();

  ShapeBorder get _shape => _shapeEntries[_shapeIndex].value;

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFFF6B9D);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          _ApiHeader(accent: accent),

          // ── Code snippet ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: _CodeSnippet(
              scale: _scale,
              focalDX: _focalDX,
              focalDY: _focalDY,
              shapeName: _shapeEntries[_shapeIndex].key,
            ),
          ),

          // ── Live preview ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'LIVE PREVIEW',
              style: GoogleFonts.outfit(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.white30,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: _LoupePreview(
              loupeX: _loupeX,
              loupeY: _loupeY,
              focalDX: _focalDX,
              focalDY: _focalDY,
              scale: _scale,
              shape: _shape,
            ),
          ),

          // ── Controls ──────────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _ApiControls(
                loupeX: _loupeX,
                loupeY: _loupeY,
                focalDX: _focalDX,
                focalDY: _focalDY,
                scale: _scale,
                shapeNames: _shapeEntries.map((e) => e.key).toList(),
                shapeIndex: _shapeIndex,
                accent: accent,
                onLoupeXChanged: (v) => setState(() => _loupeX = v),
                onLoupeYChanged: (v) => setState(() => _loupeY = v),
                onFocalDXChanged: (v) => setState(() => _focalDX = v),
                onFocalDYChanged: (v) => setState(() => _focalDY = v),
                onScaleChanged: (v) => setState(() => _scale = v),
                onShapeChanged: (i) => setState(() => _shapeIndex = i),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────

class _ApiHeader extends StatelessWidget {
  const _ApiHeader({required this.accent});
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
                'Raw API',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Loupe + LoupeController — manual control',
                style: GoogleFonts.outfit(fontSize: 13, color: Colors.white54),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Code snippet ─────────────────────────────────────────────────────────

class _CodeSnippet extends StatelessWidget {
  const _CodeSnippet({
    required this.scale,
    required this.focalDX,
    required this.focalDY,
    required this.shapeName,
  });
  final double scale;
  final double focalDX;
  final double focalDY;
  final String shapeName;

  @override
  Widget build(BuildContext context) {
    final code = '''Loupe(
  magnificationScale: ${scale.toStringAsFixed(1)},
  focalPointOffset: Offset(
    ${focalDX.toStringAsFixed(0)}, ${focalDY.toStringAsFixed(0)},
  ),
  shape: ${_shapeCode(shapeName)},
)''';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A14),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFFF6B9D).withAlpha(76),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 5),
                decoration: const BoxDecoration(
                  color: Color(0xFFFF6B9D),
                  shape: BoxShape.circle,
                ),
              ),
              Text(
                'dart',
                style: GoogleFonts.robotoMono(
                  fontSize: 10,
                  color: Colors.white30,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _SyntaxText(code),
        ],
      ),
    );
  }

  String _shapeCode(String name) {
    switch (name) {
      case 'Rounded':
        return 'RoundedRectangleBorder(...)';
      case 'Stadium':
        return 'StadiumBorder()';
      case 'Star':
        return 'StarBorder(points: 5)';
      default:
        return 'CircleBorder()';
    }
  }
}

class _SyntaxText extends StatelessWidget {
  const _SyntaxText(this.code);
  final String code;

  @override
  Widget build(BuildContext context) {
    // Simple syntax highlighting
    return RichText(
      text: TextSpan(
        style: GoogleFonts.robotoMono(fontSize: 12, height: 1.6),
        children: _tokenize(code),
      ),
    );
  }

  List<TextSpan> _tokenize(String code) {
    const num_ = Color(0xFFFFD740);
    const cls = Color(0xFF00E5FF);
    const def = Color(0xFFE0E0E0);


    final result = <TextSpan>[];
    final lines = code.split('\n');
    for (final line in lines) {
      // Very basic tokenizer for demo purposes
      String remaining = line;
      while (remaining.isNotEmpty) {
        if (remaining.startsWith('//')) {
          result.add(TextSpan(
              text: '$remaining\n',
              style: const TextStyle(color: Color(0xFF616161))));
          remaining = '';
        } else if (RegExp(r'^[A-Z]\w*').hasMatch(remaining)) {
          final m = RegExp(r'^[A-Z]\w*').firstMatch(remaining)!;
          result.add(
              TextSpan(text: m.group(0)!, style: const TextStyle(color: cls)));
          remaining = remaining.substring(m.end);
        } else if (RegExp(r'^-?\d+\.?\d*').hasMatch(remaining)) {
          final m = RegExp(r'^-?\d+\.?\d*').firstMatch(remaining)!;
          result.add(
              TextSpan(text: m.group(0)!, style: const TextStyle(color: num_)));
          remaining = remaining.substring(m.end);
        } else {
          result.add(TextSpan(text: remaining[0], style: const TextStyle(color: def)));
          remaining = remaining.substring(1);
        }
      }
      result.add(const TextSpan(text: '\n'));
    }
    return result;
  }
}

// ─── Live preview ─────────────────────────────────────────────────────────

class _LoupePreview extends StatelessWidget {
  const _LoupePreview({
    required this.loupeX,
    required this.loupeY,
    required this.focalDX,
    required this.focalDY,
    required this.scale,
    required this.shape,
  });
  final double loupeX;
  final double loupeY;
  final double focalDX;
  final double focalDY;
  final double scale;
  final ShapeBorder shape;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(20), width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background content
          _PreviewBackground(),

          // Focal point indicator
          Positioned(
            left: loupeX + focalDX - 6,
            top: loupeY + focalDY - 6,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B9D).withAlpha(180),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF6B9D).withAlpha(128),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ),

          // The Loupe widget
          Positioned(
            left: loupeX,
            top: loupeY,
            child: Loupe(
              focalPointOffset: Offset(focalDX, focalDY),
              magnificationScale: scale,
              size: const Size(100, 100),
              shape: shape,
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
        ),
      ),
      child: CustomPaint(painter: _GridPainter()),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(13)
      ..strokeWidth = 0.5;

    const step = 24.0;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw some content to make magnification interesting
    final dotPaint = Paint()..style = PaintingStyle.fill;
    const colors = [
      Color(0xFF7C4DFF),
      Color(0xFF00E5FF),
      Color(0xFFFF6B9D),
    ];
    int ci = 0;
    for (double x = 24; x < size.width; x += 48) {
      for (double y = 24; y < size.height; y += 48) {
        dotPaint.color = colors[ci % colors.length].withAlpha(180);
        canvas.drawCircle(Offset(x, y), 4, dotPaint);
        ci++;
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── Controls ─────────────────────────────────────────────────────────────

class _ApiControls extends StatelessWidget {
  const _ApiControls({
    required this.loupeX,
    required this.loupeY,
    required this.focalDX,
    required this.focalDY,
    required this.scale,
    required this.shapeNames,
    required this.shapeIndex,
    required this.accent,
    required this.onLoupeXChanged,
    required this.onLoupeYChanged,
    required this.onFocalDXChanged,
    required this.onFocalDYChanged,
    required this.onScaleChanged,
    required this.onShapeChanged,
  });

  final double loupeX;
  final double loupeY;
  final double focalDX;
  final double focalDY;
  final double scale;
  final List<String> shapeNames;
  final int shapeIndex;
  final Color accent;
  final ValueChanged<double> onLoupeXChanged;
  final ValueChanged<double> onLoupeYChanged;
  final ValueChanged<double> onFocalDXChanged;
  final ValueChanged<double> onFocalDYChanged;
  final ValueChanged<double> onScaleChanged;
  final ValueChanged<int> onShapeChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(15), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shape chips
          _SectionLabel('Shape'),
          const SizedBox(height: 8),
          Row(
            children: List.generate(shapeNames.length, (i) {
              final sel = i == shapeIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onShapeChanged(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(vertical: 7),
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
                        fontSize: 10,
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

          const SizedBox(height: 14),
          _SectionLabel('Loupe Position (left / top)'),
          const SizedBox(height: 4),
          _Slider2D(
            label1: 'Left',
            value1: loupeX,
            min1: 0,
            max1: 280,
            onChanged1: onLoupeXChanged,
            label2: 'Top',
            value2: loupeY,
            min2: 0,
            max2: 80,
            onChanged2: onLoupeYChanged,
            accent: accent,
          ),

          const SizedBox(height: 10),
          _SectionLabel('focalPointOffset (dx / dy)'),
          const SizedBox(height: 4),
          _Slider2D(
            label1: 'dx',
            value1: focalDX,
            min1: -100,
            max1: 100,
            onChanged1: onFocalDXChanged,
            label2: 'dy',
            value2: focalDY,
            min2: -100,
            max2: 100,
            onChanged2: onFocalDYChanged,
            accent: const Color(0xFF00E5FF),
          ),

          const SizedBox(height: 10),
          _SectionLabel('magnificationScale'),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: const Color(0xFFFFD740),
                    inactiveTrackColor:
                        const Color(0xFFFFD740).withAlpha(38),
                    thumbColor: const Color(0xFFFFD740),
                    overlayColor:
                        const Color(0xFFFFD740).withAlpha(26),
                    trackHeight: 2.5,
                    thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 7),
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
                width: 44,
                child: Text(
                  '${scale.toStringAsFixed(1)}×',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFFFD740),
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.robotoMono(
        fontSize: 10,
        color: Colors.white38,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _Slider2D extends StatelessWidget {
  const _Slider2D({
    required this.label1,
    required this.value1,
    required this.min1,
    required this.max1,
    required this.onChanged1,
    required this.label2,
    required this.value2,
    required this.min2,
    required this.max2,
    required this.onChanged2,
    required this.accent,
  });

  final String label1;
  final double value1;
  final double min1;
  final double max1;
  final ValueChanged<double> onChanged1;

  final String label2;
  final double value2;
  final double min2;
  final double max2;
  final ValueChanged<double> onChanged2;

  final Color accent;

  Widget _row(String label, double value, double min, double max,
      ValueChanged<double> onChanged) {
    return Row(
      children: [
        SizedBox(
          width: 28,
          child: Text(
            label,
            style: GoogleFonts.robotoMono(
                fontSize: 10, color: Colors.white54),
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: accent,
              inactiveTrackColor: accent.withAlpha(38),
              thumbColor: accent,
              overlayColor: accent.withAlpha(26),
              trackHeight: 2,
              thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 6),
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ),
        SizedBox(
          width: 36,
          child: Text(
            value.toStringAsFixed(0),
            textAlign: TextAlign.right,
            style: GoogleFonts.robotoMono(
              fontSize: 10,
              color: accent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _row(label1, value1, min1, max1, onChanged1),
        _row(label2, value2, min2, max2, onChanged2),
      ],
    );
  }
}
