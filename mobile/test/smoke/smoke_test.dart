import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_photo_app/app.dart';
import 'package:ai_photo_app/core/result.dart';

void main() {
  test('Ok 携带值', () {
    const Result<int> r = Ok<int>(42);
    expect(r, isA<Ok<int>>());
    expect((r as Ok<int>).value, 42);
  });

  test('Err 携带消息', () {
    const Result<int> r = Err<int>('boom');
    expect(r, isA<Err<int>>());
    expect((r as Err<int>).message, 'boom');
  });

  testWidgets('宽屏使用 NavigationRail 侧栏', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(AiPhotoApp());
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('窄屏使用 NavigationBar 底栏', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(AiPhotoApp());
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
  });
}
