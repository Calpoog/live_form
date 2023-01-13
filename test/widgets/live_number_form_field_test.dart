import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_form/live_form.dart';

void main() {
  group('LiveNumberFormField', () {
    testWidgets('has an empty textfield value to start', (tester) async {
      final control = NumberFormControl();

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: LiveNumberFormField(
            control: control,
          ),
        ),
      ));

      expect(find.text('1'), findsNothing);
    });

    testWidgets('takes and displays an initialValue', (tester) async {
      final control = NumberFormControl(initialValue: 1);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: LiveNumberFormField(
            control: control,
          ),
        ),
      ));

      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('displays updated value from the control', (tester) async {
      final control = NumberFormControl();

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: LiveNumberFormField(
            control: control,
          ),
        ),
      ));

      expect(find.text('1'), findsNothing);
      control.update(1);
      await tester.pump();

      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('updates the control when typing and accepts only digits',
        (tester) async {
      final control = NumberFormControl();

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: LiveNumberFormField(
            control: control,
          ),
        ),
      ));

      await tester.enterText(find.byType(EditableText), 'a1x2[3');
      await tester.pump();

      expect(find.text('123'), findsOneWidget);
      expect(control.value, 123);
    });
  });
}
