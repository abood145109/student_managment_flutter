// Basic Flutter widget test for the Academic System app.

import 'package:flutter_test/flutter_test.dart';

import 'package:academic_mobile/main.dart';

void main() {
  testWidgets('App builds and shows login screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AcademicMobileApp());

    // Verify the login screen elements are present (Arabic).
    expect(find.text('بوابة الطالب الأكاديمية'), findsOneWidget);
    expect(find.text('سجّل الدخول لمتابعة مقرراتك ودرجاتك'), findsOneWidget);
    expect(find.text('دخول'), findsOneWidget);
  });
}
