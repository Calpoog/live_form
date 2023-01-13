import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_form/live_form.dart';

import '../forms_test.dart';

String aToB(value) => value.replaceAll('a', 'b');
String bToA(value) => value.replaceAll('b', 'a');

// Contrived field to demonstrate bi-directional value transformation
class TestConverterField extends LiveFormField<String, TextFormControl> {
  const TestConverterField({super.key, required TextFormControl control})
      : super(
          control: control,
          stringToValue: aToB,
          valueToString: bToA,
        );
}

void main() {
  group('LiveFormField', () {
    testWidgets('can transform value to and from the field and control',
        (tester) async {
      final control = TextFormControl(initialValue: 'ababa');

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TestConverterField(
            control: control,
          ),
        ),
      ));

      final field = find.byType(EditableText);
      await tester.enterText(field, 'abccba');
      await tester.pump();

      expect(control.value, 'bbccbb');
      control.update('bcaacb');
      await tester.pump();
      expect(find.text('acaaca'), findsOneWidget);
    });

    testWidgets('is scrolled to when isFirstError is set', (tester) async {
      final form = TestFormCubit();
      final scrollController = ScrollController();

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: [
                TestConverterField(
                  control: form.textControl,
                ),
                const SizedBox(height: 5000),
                const Text('end'),
              ],
            ),
          ),
        ),
      ));

      expect(scrollController.offset, 0);

      scrollController.jumpTo(2000);
      await tester.pumpAndSettle();
      expect(scrollController.offset, 2000);

      form.viewFirstError();
      await tester.pumpAndSettle();

      expect(scrollController.offset, 0);

      scrollController.dispose();
    });
  });
}
