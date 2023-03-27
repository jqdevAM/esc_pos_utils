import 'package:image/image.dart';

/// Draw a single pixel into the image, applying alpha and opacity blending.
Image drawPixel(Image image, int x, int y, int color, [int opacity = 0xff]) {
  if (boundsSafe(x, y, image.width, image.height)) {
    final pi = y * image.width + x;
    // final dst = image.get[pi];
    // image.set[pi] = alphaBlendColors(dst, color, opacity);
  }
  return image;
}

/// Is the given [x], [y] pixel coordinates within the resolution of the image.
bool boundsSafe(int x, int y, int width, int height) =>
    x >= 0 && x < width && y >= 0 && y < height;

/// Returns a new color of [src] alpha-blended onto [dst]. The opacity of [src]
/// is additionally scaled by [fraction] / 255.
int alphaBlendColors(int dst, int src, [int fraction = 0xff]) {
  final srcAlpha = getAlpha(src);
  if (srcAlpha == 255 && fraction == 0xff) {
    // src is fully opaque, nothing to blend
    return src;
  }
  if (srcAlpha == 0 && fraction == 0xff) {
    // src is fully transparent, nothing to blend
    return dst;
  }
  var a = (srcAlpha / 255.0);
  if (fraction != 0xff) {
    a *= (fraction / 255.0);
  }

  final sr = (getRed(src) * a).round();
  final sg = (getGreen(src) * a).round();
  final sb = (getBlue(src) * a).round();
  final sa = (srcAlpha * a).round();

  final dr = (getRed(dst) * (1.0 - a)).round();
  final dg = (getGreen(dst) * (1.0 - a)).round();
  final db = (getBlue(dst) * (1.0 - a)).round();
  final da = (getAlpha(dst) * (1.0 - a)).round();

  return getColor(sr + dr, sg + dg, sb + db, sa + da);
}

/// Get the red channel from the [color].
int getRed(int color) => (color) & 0xff;

/// Returns a new color where the red channel of [color] has been replaced
/// by [value].
int setRed(int color, int value) => (color & 0xffffff00) | (clamp255(value));

/// Get the green channel from the [color].
int getGreen(int color) => (color >> 8) & 0xff;

/// Returns a new color where the green channel of [color] has been replaced
/// by [value].
int setGreen(int color, int value) =>
    (color & 0xffff00ff) | (clamp255(value) << 8);

/// Get the blue channel from the [color].
int getBlue(int color) => (color >> 16) & 0xff;

/// Returns a new color where the blue channel of [color] has been replaced
/// by [value].
int setBlue(int color, int value) =>
    (color & 0xff00ffff) | (clamp255(value) << 16);

/// Get the alpha channel from the [color].
int getAlpha(int color) => (color >> 24) & 0xff;

/// Returns a new color where the alpha channel of [color] has been replaced
/// by [value].
int setAlpha(int color, int value) =>
    (color & 0x00ffffff) | (clamp255(value) << 24);

/// Clamp [x] to [a] [b]
int clamp(int x, int a, int b) => x.clamp(a, b).toInt();

/// Clamp [x] to [0, 255]
int clamp255(int x) => x.clamp(0, 255).toInt();

/// Get the color with the given [r], [g], [b], and [a] components.
///
/// The channel order of a uint32 encoded color is RGBA.
int getColor(int r, int g, int b, [int a = 255]) =>
    // what we're doing here, is creating a 32 bit
// integer by collecting the rgba in one integer.
// we know for certain and we're also assuring that
// all our variables' values are 255 at maximum,
// which means that they can never be bigger than
// 8 bits  so we can safely slide each one by 8 bits
// for adding the other.
(clamp255(a) << 24) |
(clamp255(b) << 16) |
(clamp255(g) << 8) |
(clamp255(r));