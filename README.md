# raw_magnifier_plus

[![pub.dev](https://img.shields.io/pub/v/raw_magnifier_plus.svg)](https://pub.dev/packages/raw_magnifier_plus)
[![license: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-%E2%89%A53.3.0-54C5F8?logo=flutter)](https://flutter.dev)

A powerful, composable Flutter magnifier widget built directly on [`RawMagnifier`](https://api.flutter.dev/flutter/widgets/RawMagnifier-class.html) — Flutter's native, render-tree-level zoom primitive.

> 🚫 No double image hacks. No matrix syncing. No jank.  
> ✅ Real-time. Zero dependencies. Works on **any** widget.

---

## Why `RawMagnifier`?

Most "zoom loupe" implementations hack it together by overlapping two identical images, wrapping one in an `InteractiveViewer`, and synchronising them with `Matrix4` translations. It's heavy, janky, and fragile.

`RawMagnifier` is different. It **physically magnifies whatever pixels are painted beneath it** in the Flutter render tree — in real time. It works on images, video frames, glassmorphism, text, icons, live widgets — anything.

This package wraps it into a clean, documented, composable API.

---

## Features

- 🔬 **True pixel magnification** via `RawMagnifier` — no hacks
- 🎨 **Any `ShapeBorder`** — circle, rounded rect, stadium, star, or custom
- 🔌 **Plug-and-play** with `DraggableLoupe` — one widget, done
- 🎮 **Fine-grained control** with the bare `Loupe` + `LoupeController`
- ✨ **Smooth pop animation** on show/hide (configurable)
- 📦 **Zero runtime dependencies** — only `flutter` SDK
- 🎯 **Flutter ≥ 3.3.0** support (when `RawMagnifier` was introduced)

---

## Installation

```yaml
dependencies:
  raw_magnifier_plus: ^0.1.0
```

```dart
import 'package:raw_magnifier_plus/raw_magnifier_plus.dart';
```

---

## Quick start

### 1. Plug-and-play — `DraggableLoupe`

Wrap any widget. Press and drag to magnify.

```dart
DraggableLoupe(
  child: Image.network('https://example.com/product.jpg'),
)
```

### 2. Custom shape and scale

```dart
DraggableLoupe(
  loupeSize: const Size(160, 100),
  magnificationScale: 3.0,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(16)),
  ),
  child: Image.asset('assets/map.png'),
)
```

### 3. Long-press activation (e.g. text selection style)

```dart
DraggableLoupe(
  showOnLongPress: true,
  child: const Text('Press and hold me, then drag'),
)
```

### 4. Star-shaped loupe (Flutter 3.3+)

```dart
DraggableLoupe(
  shape: const StarBorder(points: 6, innerRadiusRatio: 0.55),
  magnificationScale: 2.0,
  child: myWidget,
)
```

### 5. Bare `Loupe` widget (manual positioning)

```dart
Stack(
  children: [
    Image.asset('assets/photo.jpg'),
    Positioned(
      left: loupeLeft,
      top: loupeTop,
      child: Loupe(
        // Vector from loupe center → focal point
        focalPointOffset: const Offset(0, 90),
        magnificationScale: 2.5,
        shape: const CircleBorder(),
      ),
    ),
  ],
)
```

### 6. With `LoupeController` — programmatic show/hide

```dart
final _controller = LoupeController();

@override
void dispose() {
  _controller.dispose();
  super.dispose();
}

// Force-hide on scroll
_scrollController.addListener(() {
  if (_scrollController.position.isScrollingNotifier.value) {
    _controller.hide();
  }
});

// Pass to DraggableLoupe — it reads gestures, you can override
DraggableLoupe(
  controller: _controller,
  child: myContent,
)
```

---

## API Reference

### `Loupe`

The bare magnifier widget. Place it in a `Stack` + `Positioned`.

| Property | Type | Default | Description |
|---|---|---|---|
| `focalPointOffset` | `Offset` | `Offset.zero` | Vector from loupe center to focal point |
| `magnificationScale` | `double` | `2.0` | Zoom factor (must be > 0) |
| `size` | `Size` | `Size(120, 120)` | Size of the lens |
| `shape` | `ShapeBorder` | `CircleBorder()` | Lens shape — any `ShapeBorder` |
| `shadows` | `List<BoxShadow>` | soft shadow | Drop shadows around the lens |
| `overlayBuilder` | `WidgetBuilder?` | `null` | Widget rendered on top of the magnified area |

### `DraggableLoupe`

Batteries-included widget. Handles gestures, animation, and positioning.

| Property | Type | Default | Description |
|---|---|---|---|
| `child` | `Widget` | required | The widget to wrap |
| `loupeSize` | `Size` | `Size(130, 130)` | Size of the lens |
| `magnificationScale` | `double` | `2.5` | Zoom factor |
| `shape` | `ShapeBorder` | `CircleBorder()` | Lens shape |
| `verticalOffset` | `double` | `90.0` | How far above the touch the loupe floats |
| `shadows` | `List<BoxShadow>` | soft shadow | Drop shadows |
| `overlayBuilder` | `WidgetBuilder?` | `null` | Overlay on top of magnified area |
| `controller` | `LoupeController?` | `null` | External controller for programmatic control |
| `showOnLongPress` | `bool` | `false` | Require long press instead of immediate pan |
| `animationDuration` | `Duration` | `160ms` | Appear/disappear animation duration |

### `LoupeController`

A `ChangeNotifier` that drives loupe visibility and position.

| Method / Property | Description |
|---|---|
| `isVisible` | Whether the loupe is currently shown |
| `position` | Current focal position in local coordinates |
| `show({required Offset position})` | Show the loupe at `position` |
| `moveTo(Offset position)` | Move the focal point (no-op if hidden) |
| `hide()` | Hide the loupe |

---

## How `focalPointOffset` works

`focalPointOffset` is the vector **from the center of the loupe widget to the point being magnified**.

```
loupeCenter + focalPointOffset = focalPoint
```

- **`Offset.zero`** (default): magnifies what's directly beneath the loupe center.
- **`Offset(0, 90)`**: the loupe "looks at" a point 90 px below its own center.
  This is how `DraggableLoupe` works — the loupe floats above the finger,
  with `focalPointOffset.dy = verticalOffset` pointing back down.

---

## Running the example

```bash
cd example
flutter create .          # create platform dirs
flutter pub get
flutter run
```

The example app has three demo screens:
1. **Image Zoom** — product photo with configurable shape & scale
2. **UI Magnifier** — magnify a rich Flutter widget layout
3. **Raw API** — manually position the loupe and tweak `focalPointOffset` live

---

## License

MIT — see [LICENSE](LICENSE)
