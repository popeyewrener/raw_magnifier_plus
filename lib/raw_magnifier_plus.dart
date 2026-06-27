/// A powerful magnifying glass widget for Flutter built on [RawMagnifier].
///
/// Unlike the common hack of overlapping two identical images and syncing
/// their matrices, this package taps directly into the Flutter render tree
/// and physically magnifies whatever pixels are painted beneath the loupe
/// in real-time — images, videos, glassmorphism, text, icons, anything.
///
/// ## Quick start
///
/// ### Plug-and-play (recommended)
/// ```dart
/// import 'package:raw_magnifier_plus/raw_magnifier_plus.dart';
///
/// DraggableLoupe(
///   child: Image.network('https://picsum.photos/800/1200'),
/// )
/// ```
///
/// ### Manual control with the bare widget
/// ```dart
/// Stack(
///   children: [
///     Image.network('https://picsum.photos/800/1200'),
///     Positioned(
///       left: focalX - 60, top: focalY - 150,
///       child: Loupe(
///         focalPointOffset: Offset(0, 90),
///         magnificationScale: 2.5,
///         shape: CircleBorder(),
///       ),
///     ),
///   ],
/// )
/// ```
///
/// ### With a [LoupeController]
/// ```dart
/// final controller = LoupeController();
///
/// GestureDetector(
///   onPanStart: (d) => controller.show(position: d.localPosition),
///   onPanUpdate: (d) => controller.moveTo(d.localPosition),
///   onPanEnd: (_) => controller.hide(),
///   child: DraggableLoupe(
///     controller: controller,
///     child: Image.network('https://picsum.photos/800/1200'),
///   ),
/// )
/// ```
library raw_magnifier_plus;

export 'src/loupe_controller.dart';
export 'src/loupe_widget.dart';
export 'src/draggable_loupe.dart';
