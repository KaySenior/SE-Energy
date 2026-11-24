// This file intentionally only covers pure helpers; widget coverage lives in
// dashboard_screen_test.dart.
import 'package:flutter_test/flutter_test.dart';
import 'package:se_energy_app/core/utils/formatters.dart';

void main() {
  test('formatNumber adds thousands separators', () {
    expect(formatNumber(0), '0');
    expect(formatNumber(999), '999');
    expect(formatNumber(1000), '1,000');
    expect(formatNumber(1234567), '1,234,567');
    expect(formatNumber(1234.56, decimals: 1), '1,234.6');
  });
}
