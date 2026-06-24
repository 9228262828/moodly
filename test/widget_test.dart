import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:moodly/main.dart';

void main() {
  testWidgets('Moodly shows splash screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MoodlyApp());
    await tester.pump();

    expect(find.text('Moodly'), findsOneWidget);
    expect(find.text('Start Tracking'), findsOneWidget);
  });
}
