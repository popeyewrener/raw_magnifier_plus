import 'package:flutter/widgets.dart';

/// Controls the visibility and focal position of a [DraggableLoupe].
///
/// [LoupeController] is a [ChangeNotifier] that drives the loupe's
/// show/hide state and position. It can be used in two ways:
///
/// ### 1. Passed to [DraggableLoupe]
/// The controller gives you programmatic access to the loupe driven by
/// built-in gesture handling:
///
/// ```dart
/// final _controller = LoupeController();
///
/// // Read state externally
/// print(_controller.isVisible);
/// print(_controller.position);
///
/// // Force-hide (e.g. on scroll start)
/// scrollController.addListener(() {
///   if (scrollController.position.isScrollingNotifier.value) {
///     _controller.hide();
///   }
/// });
///
/// DraggableLoupe(controller: _controller, child: content)
/// ```
///
/// ### 2. Standalone — drive a [Loupe] manually
/// Manage the loupe from your own [GestureDetector]:
///
/// ```dart
/// final _controller = LoupeController();
///
/// GestureDetector(
///   onPanStart: (d) => _controller.show(position: d.localPosition),
///   onPanUpdate: (d) => _controller.moveTo(d.localPosition),
///   onPanEnd: (_) => _controller.hide(),
///   child: ListenableBuilder(
///     listenable: _controller,
///     builder: (context, child) => Stack(
///       children: [
///         child!,
///         if (_controller.isVisible)
///           Positioned(
///             left: _controller.position.dx - 60,
///             top: _controller.position.dy - 150,
///             child: const Loupe(focalPointOffset: Offset(0, 90)),
///           ),
///       ],
///     ),
///     child: Image.asset('photo.jpg'),
///   ),
/// )
/// ```
///
/// Always call [dispose] when the controller is no longer needed.
class LoupeController extends ChangeNotifier {
  /// Creates a [LoupeController].
  ///
  /// By default the loupe is hidden and positioned at [Offset.zero].
  LoupeController({
    bool initiallyVisible = false,
    Offset initialPosition = Offset.zero,
  })  : _isVisible = initiallyVisible,
        _position = initialPosition;

  bool _isVisible;
  Offset _position;

  /// Whether the loupe is currently visible.
  bool get isVisible => _isVisible;

  /// The current focal position in the local coordinate space of the widget
  /// that owns the loupe.
  Offset get position => _position;

  /// Shows the loupe at [position] in the local coordinate space.
  ///
  /// If the loupe is already visible, this also updates its position.
  /// Calling [show] when already shown at the same position is a no-op.
  void show({required Offset position}) {
    final changed = !_isVisible || _position != position;
    _isVisible = true;
    _position = position;
    if (changed) notifyListeners();
  }

  /// Moves the loupe focal point to [position].
  ///
  /// Has no effect if the loupe is not currently visible.
  /// Calling [moveTo] with the same position is a no-op.
  void moveTo(Offset position) {
    if (!_isVisible || _position == position) return;
    _position = position;
    notifyListeners();
  }

  /// Hides the loupe.
  ///
  /// Calling [hide] when already hidden is a no-op.
  void hide() {
    if (!_isVisible) return;
    _isVisible = false;
    notifyListeners();
  }
}
