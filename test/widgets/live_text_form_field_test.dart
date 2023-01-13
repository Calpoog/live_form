import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_form/live_form.dart';

void main() {
  group('LiveTextFormField', () {
    testWidgets('builds a material text input', (tester) async {
      final control = TextFormControl(initialValue: '');

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: LiveTextFormField(
            control: control,
          ),
        ),
      ));

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('shows the initial value from its control', (tester) async {
      final control = TextFormControl(initialValue: 'test');

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: LiveTextFormField(
            control: control,
          ),
        ),
      ));

      expect(find.text('test'), findsOneWidget);
    });

    testWidgets('can update its value from the control', (tester) async {
      final control = TextFormControl(initialValue: '');

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: LiveTextFormField(
            control: control,
          ),
        ),
      ));

      expect(find.text('test'), findsNothing);
      control.update('test');
      await tester.pumpAndSettle();
      expect(find.text('test'), findsOneWidget);
    });

    testWidgets('can update the control value', (tester) async {
      final control = TextFormControl(initialValue: '');

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: LiveTextFormField(
            control: control,
          ),
        ),
      ));

      expect(control.value, '');

      await tester.enterText(find.byType(EditableText), 'test');
      await tester.pumpAndSettle();

      expect(control.value, 'test');
    });

    testWidgets('can focus and touch', (tester) async {
      final control = TextFormControl(initialValue: '');
      const field = ValueKey('field');
      const other = ValueKey('other');

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              LiveTextFormField(
                key: field,
                control: control,
              ),
              const TextField(key: other),
            ],
          ),
        ),
      ));

      expect(control.focused, false);

      await tester.tap(find.byKey(field));
      await tester.pumpAndSettle();

      expect(control.focused, true);

      await tester.tap(find.byKey(other));
      await tester.pumpAndSettle();

      expect(control.focused, false);
      expect(control.touched, true);
    });

    testWidgets('can swap focus nodes', (tester) async {
      final control = TextFormControl(initialValue: '');
      final focusNode = FocusNode();
      final value = ValueNotifier<FocusNode?>(null);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ValueListenableBuilder(
            valueListenable: value,
            builder: (context, focusNode, __) {
              return LiveTextFormField(
                focusNode: focusNode,
                control: control,
              );
            },
          ),
        ),
      ));

      await tester.tap(find.byType(EditableText));
      await tester.pump();
      expect(focusNode.hasFocus, false);

      value.value = focusNode;
      await tester.pump();
      expect(focusNode.hasFocus, false);
      await tester.tap(find.byType(EditableText));
      await tester.pump();
      expect(focusNode.hasFocus, true);
    });
  });
}
