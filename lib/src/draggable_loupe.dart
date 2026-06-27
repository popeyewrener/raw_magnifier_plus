import 'package:flutter/widgets.dart';

import 'loupe_controller.dart';
import 'loupe_widget.dart';

/// A batteries-included magnifying glass that follows the user's finger (or
/// mouse) over any child widget.
///
/// Wrap any widget — an image, a map, a rich UI layout — and the loupe will
/// appear when the user presses or drags, floating above their touch point
/// and magnifying the content below in real-time.
///
/// ```dart
/// // Minimal usage — e-commerce product zoom
/// DraggableLoupe(
///   child: Image.network('https://example.com/product.jpg'),
/// )
///
/// // Custom shape, scale, and size
/// DraggableLoupe(
///   loupeSize: const Size(160, 100),
///   magnificationScale: 3.0,
///   shape: const RoundedRectangleBorder(
///     borderRadius: BorderRadius.all(Radius.circular(16)),
///   ),
///   child: complexWidget,
/// )
///
/// // Long-press activation (instead of immediate pan)
/// DraggableLoupe(
///   showOnLongPress: true,
///   child: textContent,
/// )
/// ```
///
/// For fine-grained control, use [Loupe] and [LoupeController] directly.
class DraggableLoupe extends StatefulWidget {
  /// Creates a [DraggableLoupe].
  const DraggableLoupe({
    super.key,
    required this.child,
    this.loupeSize = const Size(130, 130),
    this.magnificationScale = 2.5,
    this.shape = const CircleBorder(),
    this.verticalOffset = 90.0,
    this.shadows = const <BoxShadow>[
      BoxShadow(
        color: Color(0x55000000),
        blurRadius: 14,
        spreadRadius: 3,
        offset: Offset(0, 6),
      ),
    ],
    this.overlayBuilder,
    this.controller,
    this.showOnLongPress = false,
    this.animationDuration = const Duration(milliseconds: 160),
  });

  /// The widget to wrap with the magnifier.
  ///
  /// This widget is the "source of truth" — the loupe magnifies whatever this
  /// widget renders at the focal point.
  final Widget child;

  /// The size of the magnifier lens. Defaults to `Size(130, 130)`.
  final Size loupeSize;

  /// The scale factor applied to the content. Defaults to `2.5`.
  final double magnificationScale;

  /// The shape of the magnifier lens. Defaults to [CircleBorder].
  ///
  /// Any [ShapeBorder] is supported — see [Loupe.shape] for examples.
  final ShapeBorder shape;

  /// How far (in logical pixels) the loupe center floats **above** the touch
  /// point. Defaults to `90.0`.
  ///
  /// A positive value moves the loupe up so it is not occluded by the user's
  /// hand. Set to `0` to center the loupe directly on the touch point.
  final double verticalOffset;

  /// Shadows rendered around the lens. Defaults to a soft drop shadow.
  final List<BoxShadow> shadows;

  /// Optional overlay rendered on top of the magnified area.
  /// See [Loupe.overlayBuilder].
  final WidgetBuilder? overlayBuilder;

  /// An optional external [LoupeController] to drive this widget.
  ///
  /// If provided, you can read [LoupeController.isVisible] and
  /// [LoupeController.position] from outside, or force-hide the loupe via
  /// [LoupeController.hide]. The built-in gesture handling still works.
  ///
  /// If `null`, an internal controller is created and managed automatically.
  final LoupeController? controller;

  /// If `true`, the loupe activates only after a long press, then follows the
  /// drag. If `false` (default), the loupe appears immediately on any pan.
  final bool showOnLongPress;

  /// Duration of the appear/disappear scale animation.
  /// Defaults to `Duration(milliseconds: 160)`.
  final Duration animationDuration;

  @override
  State<DraggableLoupe> createState() => _DraggableLoupeState();
}

class _DraggableLoupeState extends State<DraggableLoupe>
    with SingleTickerProviderStateMixin {
  late LoupeController _controller;
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  bool _ownsController = false;
  bool _wasVisible = false;

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _setupController();
    _animController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _scaleAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeIn,
    );
    _controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(DraggableLoupe oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _controller.removeListener(_onControllerChanged);
      if (_ownsController) _controller.dispose();
      _setupController();
      _controller.addListener(_onControllerChanged);
    }
    if (oldWidget.animationDuration != widget.animationDuration) {
      _animController.duration = widget.animationDuration;
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    if (_ownsController) _controller.dispose();
    _animController.dispose();
    super.dispose();
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  void _setupController() {
    if (widget.controller != null) {
      _controller = widget.controller!;
      _ownsController = false;
    } else {
      _controller = LoupeController();
      _ownsController = true;
    }
    _wasVisible = _controller.isVisible;
  }

  /// Only trigger the animation when visibility actually *changes*, not on
  /// every position update.
  void _onControllerChanged() {
    if (_controller.isVisible == _wasVisible) return;
    _wasVisible = _controller.isVisible;
    if (_controller.isVisible) {
      _animController.forward();
    } else {
      _animController.reverse();
    }
  }

  // ─── Gesture handlers ─────────────────────────────────────────────────────

  void _onPanStart(DragStartDetails d) {
    if (!widget.showOnLongPress) _controller.show(position: d.localPosition);
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (!widget.showOnLongPress) _controller.moveTo(d.localPosition);
  }

  void _onPanEnd(DragEndDetails _) => _controller.hide();
  void _onPanCancel() => _controller.hide();

  void _onLongPressStart(LongPressStartDetails d) {
    if (widget.showOnLongPress) _controller.show(position: d.localPosition);
  }

  void _onLongPressMoveUpdate(LongPressMoveUpdateDetails d) {
    if (widget.showOnLongPress) _controller.moveTo(d.localPosition);
  }

  void _onLongPressEnd(LongPressEndDetails _) {
    if (widget.showOnLongPress) _controller.hide();
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Standard pan (immediate activation)
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      onPanCancel: _onPanCancel,
      // Long-press activation
      onLongPressStart: _onLongPressStart,
      onLongPressMoveUpdate: _onLongPressMoveUpdate,
      onLongPressEnd: _onLongPressEnd,
      child: ListenableBuilder(
        // Listen to both controller (for position) and animation controller
        // (for per-frame rebuilds during the appear/disappear animation).
        listenable: Listenable.merge([_controller, _animController]),
        builder: (context, child) {
          // Once the exit animation fully completes, drop the Stack and
          // render the child alone (zero overhead).
          if (!_controller.isVisible && _animController.isDismissed) {
            return child!;
          }

          final touchPos = _controller.position;
          // Loupe center floats [verticalOffset] pixels above the finger.
          final loupeCenterX = touchPos.dx;
          final loupeCenterY = touchPos.dy - widget.verticalOffset;

          // focalPointOffset = vector from loupe center to focal point
          //   = touchPos - loupeCenter = Offset(0, verticalOffset)
          return Stack(
            children: [
              child!,
              Positioned(
                left: loupeCenterX - widget.loupeSize.width / 2,
                top: loupeCenterY - widget.loupeSize.height / 2,
                child: ScaleTransition(
                  scale: _scaleAnim,
                  child: Loupe(
                    focalPointOffset: Offset(0, widget.verticalOffset),
                    magnificationScale: widget.magnificationScale,
                    size: widget.loupeSize,
                    shape: widget.shape,
                    shadows: widget.shadows,
                    overlayBuilder: widget.overlayBuilder,
                  ),
                ),
              ),
            ],
          );
        },
        // The child is cached by ListenableBuilder — it won't be rebuilt
        // on controller/animation changes, only the Stack positioning will.
        child: widget.child,
      ),
    );
  }
}
