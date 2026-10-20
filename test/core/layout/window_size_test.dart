import 'package:battuta/core/layout/window_size.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('window size class boundaries follow FR-PLT-02', () {
    expect(WindowSizeClass.fromWidth(0), WindowSizeClass.compact);
    expect(WindowSizeClass.fromWidth(599.9), WindowSizeClass.compact);
    expect(WindowSizeClass.fromWidth(600), WindowSizeClass.medium);
    expect(WindowSizeClass.fromWidth(839.9), WindowSizeClass.medium);
    expect(WindowSizeClass.fromWidth(840), WindowSizeClass.expanded);
    expect(WindowSizeClass.fromWidth(1440), WindowSizeClass.expanded);
  });
}
