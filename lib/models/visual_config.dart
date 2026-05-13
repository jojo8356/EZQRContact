import 'dart:convert';
import 'dart:ui';

/// Persisted visual customisation for a VCard entry.
/// Stored as JSON in the `visual_config` DB column.
class VisualConfig {
  /// Creates a [VisualConfig] with optional visual fields.
  const VisualConfig({
    this.primaryColor = const Color(0xFF000000),
    this.logoBase64,
  });

  /// Creates a [VisualConfig] from a JSON string.
  factory VisualConfig.fromJson(String json) {
    final map = jsonDecode(json) as Map<String, dynamic>;
    final hex = map['primaryColor'] as String? ?? '#000000';
    return VisualConfig(
      primaryColor: _hexToColor(hex),
      logoBase64: map['logoBase64'] as String?,
    );
  }

  /// Creates a [VisualConfig] with defaults when [json] is null or empty.
  factory VisualConfig.fromNullableJson(String? json) {
    if (json == null || json.isEmpty) return const VisualConfig();
    try {
      return VisualConfig.fromJson(json);
    } on Object catch (_) {
      return const VisualConfig();
    }
  }

  /// The primary accent color used for the QR modules and card highlights.
  final Color primaryColor;

  /// Base64-encoded logo image (PNG/JPEG) embedded at the center of the QR.
  /// Null means no logo.
  final String? logoBase64;

  /// Serialises this config to a JSON string for DB storage.
  String toJson() {
    final map = <String, dynamic>{'primaryColor': _colorToHex(primaryColor)};
    if (logoBase64 != null) map['logoBase64'] = logoBase64;
    return jsonEncode(map);
  }

  static Color _hexToColor(String hex) {
    final h = hex.replaceFirst('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  static String _colorToHex(Color c) {
    final argb =
        c.toARGB32().toRadixString(16).padLeft(8, '0');
    return '#${argb.substring(2).toUpperCase()}';
  }
}
