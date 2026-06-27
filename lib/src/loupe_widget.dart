import 'package:flutter/widgets.dart';

/// A highly customizable magnifying glass widget powered by Flutter's
/// built-in [RawMagnifier].
///
/// [Loupe] does not duplicate or re-paint your content. It hooks into the
/// Flutter render tree and physically magnifies whatever pixels are painted
/// beneath it at render time — including images, video frames, glassmorphism
/// effects, text, icons, and any other widget.
///
/// ## Positioning
///
/// Place [Loupe] inside a [Stack] using [Positioned]. The widget is sized
/// exactly to [size].
///
/// The [focalPointOffset] is the **vector from the center of this widget to
/// the point being magnified**. Use `Offset.zero` to magnify whatever is
/// directly under the loupe center, or a non-zero value when the loupe
/// floats away from the focal point (e.g., floating above the user's finger).
///
/// ```dart
/// Stack(
///   children: [
///     Image.asset('assets/photo.jpg'),
///     Positioned(
///       // Loupe center will be at (200, 100); focal point is at (200, 190)
///       left: 140, top: 40,
///       child: Loupe(
///         focalPointOffset: const Offset(0, 90),
///         magnificationScale: 2.5,
///         size: const Size(120, 120),
///       ),
///     ),
///   ],
/// )
/// ```
///
/// For a drag-to-zoom experience without manual positioning, see [DraggableLoupe].
class Loupe extends StatelessWidget {
  /// Creates a [Loupe] magnifier widget.
  const Loupe({
    super.key,
    this.focalPointOffset = Offset.zero,
    this.magnificationScale = 2.0,
    this.size = const Size(120, 120),
    this.shape = const CircleBorder(),
    this.shadows = const <BoxShadow>[
      BoxShadow(
        color: Color(0x55000000),
        blurRadius: 14,
        spreadRadius: 2,
        offset: Offset(0, 4),
      ),
    ],
    this.overlayBuilder,
  }) : assert(magnificationScale > 0.0, 'magnificationScale must be > 0');

  /// The offset from the center of this widget to the point being magnified.
  ///
  /// - `Offset.zero` (default) — magnifies what is directly beneath the
  ///   center of this widget.
  /// - `Offset(0, 90)` — the focal point is 90 px below the loupe center.
  ///   Use this when the loupe floats 90 px above the user's finger.
  ///
  /// Mathematically: `focalPoint = loupeCenter + focalPointOffset`.
  final Offset focalPointOffset;

  /// The scale factor applied to the content beneath the loupe.
  ///
  /// Defaults to `2.0`. Values between `1.5` and `4.0` work well for most
  /// use-cases. Must be greater than zero.
  final double magnificationScale;

  /// The dimensions of the magnifier lens.
  ///
  /// Defaults to `Size(120, 120)`.
  final Size size;

  /// The shape of the magnifier lens.
  ///
  /// Defaults to [CircleBorder] (the classic round loupe). Any [ShapeBorder]
  /// is supported:
  ///
  /// ```dart
  /// // Classic circle (default)
  /// shape: const CircleBorder()
  ///
  /// // Rounded rectangle
  /// shape: const RoundedRectangleBorder(
  ///   borderRadius: BorderRadius.all(Radius.circular(16)),
  /// )
  ///
  /// // Oval / pill
  /// shape: const StadiumBorder()
  ///
  /// // Star (requires Flutter >=3.3.0)
  /// shape: const StarBorder(points: 6)
  ///
  /// // Any custom ShapeBorder
  /// shape: MyCustomShapeBorder()
  /// ```
  final ShapeBorder shape;

  /// Shadows rendered around the magnifier lens for depth.
  ///
  /// Defaults to a soft drop shadow. Pass an empty list `[]` to remove all
  /// shadows.
  final List<BoxShadow> shadows;

  /// Optional builder for a widget rendered **on top of** the magnified
  /// content, clipped to [shape].
  ///
  /// Use this to add crosshairs, a handle indicator, a border ring, or any
  /// custom UI overlay on top of the zoomed view.
  ///
  /// ```dart
  /// overlayBuilder: (context) => Container(
  ///   decoration: BoxDecoration(
  ///     border: Border.all(color: Colors.white54, width: 1.5),
  ///     shape: BoxShape.circle,
  ///   ),
  /// ),
  /// ```
  final WidgetBuilder? overlayBuilder;

  @override
  Widget build(BuildContext context) {
    return RawMagnifier(
      decoration: MagnifierDecoration(
        shape: shape,
        shadows: shadows,
      ),
      focalPointOffset: focalPointOffset,
      magnificationScale: magnificationScale,
      size: size,
      child: overlayBuilder != null ? Builder(builder: overlayBuilder!) : null,
    );
  }
}
