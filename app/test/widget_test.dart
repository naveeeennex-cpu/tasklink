import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lokal/main.dart';

void main() {
  testWidgets('LOKAL app boots', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: LokalApp()));
    await tester.pump(const Duration(milliseconds: 100));
    // Router lands on splash → verify the tagline is on-screen.
    expect(find.text('LOKAL'), findsWidgets);
  });
}
