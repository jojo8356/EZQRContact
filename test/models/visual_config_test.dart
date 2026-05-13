import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_code_app/models/qr_layout.dart';
import 'package:qr_code_app/models/visual_config.dart';

void main() {
  group('VisualConfig', () {
    test('default color is black', () {
      const config = VisualConfig();
      expect(config.primaryColor, Colors.black);
    });

    test('default logoBase64 is null', () {
      const config = VisualConfig();
      expect(config.logoBase64, isNull);
    });

    test('round-trip JSON preserves color', () {
      const config = VisualConfig(primaryColor: Color(0xFF1E88E5));
      final json = config.toJson();
      final restored = VisualConfig.fromJson(json);
      expect(restored.primaryColor, const Color(0xFF1E88E5));
    });

    test('toJson produces expected structure', () {
      const config = VisualConfig(primaryColor: Color(0xFF1E88E5));
      expect(config.toJson(), contains('"primaryColor"'));
      expect(config.toJson(), contains('1E88E5'));
    });

    test('toJson omits logoBase64 when null', () {
      const config = VisualConfig();
      expect(config.toJson(), isNot(contains('logoBase64')));
    });

    test('toJson includes logoBase64 when set', () {
      const config = VisualConfig(logoBase64: 'abc123');
      expect(config.toJson(), contains('"logoBase64"'));
      expect(config.toJson(), contains('abc123'));
    });

    test('round-trip JSON preserves logoBase64', () {
      // Any non-empty base64 string suffices — content is not validated here.
      const logo = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJ';
      const config = VisualConfig(logoBase64: logo);
      final restored = VisualConfig.fromJson(config.toJson());
      expect(restored.logoBase64, logo);
    });

    test('fromJson with no logoBase64 key returns null logo', () {
      final config = VisualConfig.fromJson('{"primaryColor":"#000000"}');
      expect(config.logoBase64, isNull);
    });

    test('fromNullableJson with null returns default black', () {
      final config = VisualConfig.fromNullableJson(null);
      expect(config.primaryColor, Colors.black);
    });

    test('fromNullableJson with empty string returns default black', () {
      final config = VisualConfig.fromNullableJson('');
      expect(config.primaryColor, Colors.black);
    });

    test('fromNullableJson with valid JSON restores color', () {
      const original = VisualConfig(primaryColor: Color(0xFFFF5722));
      final config = VisualConfig.fromNullableJson(original.toJson());
      expect(config.primaryColor, const Color(0xFFFF5722));
    });

    test('fromNullableJson preserves logoBase64', () {
      const original = VisualConfig(logoBase64: 'xyz');
      final config = VisualConfig.fromNullableJson(original.toJson());
      expect(config.logoBase64, 'xyz');
    });

    test('white color round-trips correctly', () {
      const config = VisualConfig(primaryColor: Colors.white);
      final json = config.toJson();
      final restored = VisualConfig.fromJson(json);
      expect(restored.primaryColor, Colors.white);
    });

    test('fully opaque red round-trips correctly', () {
      const config = VisualConfig(primaryColor: Color(0xFFFF0000));
      final restored = VisualConfig.fromJson(config.toJson());
      expect(restored.primaryColor, const Color(0xFFFF0000));
    });

    test('fromJson with missing primaryColor falls back to black', () {
      final config = VisualConfig.fromJson('{}');
      expect(config.primaryColor, Colors.black);
    });

    test('fromJson ignores unknown keys', () {
      final config = VisualConfig.fromJson(
        '{"primaryColor":"#1E88E5","unknown":42}',
      );
      expect(config.primaryColor, const Color(0xFF1E88E5));
    });

    test('color + logo round-trip together', () {
      const config = VisualConfig(
        primaryColor: Color(0xFF0EA5E9),
        logoBase64: 'logo_data',
      );
      final restored = VisualConfig.fromJson(config.toJson());
      expect(restored.primaryColor, const Color(0xFF0EA5E9));
      expect(restored.logoBase64, 'logo_data');
    });

    test('toJson is valid JSON', () {
      const config = VisualConfig(
        primaryColor: Color(0xFF123456),
        logoBase64: 'data',
      );
      expect(() => jsonDecode(config.toJson()), returnsNormally);
    });

    test('layout defaults to minimal', () {
      const config = VisualConfig();
      expect(config.layout, QrLayout.minimal);
    });

    test('layout round-trips through JSON', () {
      const config = VisualConfig(layout: QrLayout.modern);
      final restored = VisualConfig.fromJson(config.toJson());
      expect(restored.layout, QrLayout.modern);
    });

    test('unknown layout string falls back to minimal', () {
      final config = VisualConfig.fromJson(
        '{"primaryColor":"#000000","layout":"unknown_value"}',
      );
      expect(config.layout, QrLayout.minimal);
    });

    test('all layouts serialize/deserialize correctly', () {
      for (final layout in QrLayout.values) {
        final config = VisualConfig(layout: layout);
        final restored = VisualConfig.fromJson(config.toJson());
        expect(restored.layout, layout);
      }
    });
  });
}
