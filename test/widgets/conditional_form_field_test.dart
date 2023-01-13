import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_form/live_form.dart';

import '../forms_test.dart';

void main() {
  group('ConditionalFormField', () {
    testWidgets('shows and hides as its field is validated or not',
        (tester) async {
      final cubit = TestFormCubit();

      await tester.pumpWidget(
        MaterialApp(
          home: FormCubitProvider(
            create: (context) => cubit,
            builder: (context, form) {
              return ConditionalFormField<TestFormCubit>(
                control: form.conditionalControl,
                child: const Text('Conditional'),
              );
            },
          ),
        ),
      );

      final finder = find.text('Conditional');

      expect(finder, findsNothing);

      cubit.radioControl.update(1);
      await tester.pumpAndSettle();
      expect(finder, findsOneWidget);

      cubit.radioControl.update(0);
      await tester.pumpAndSettle();
      expect(finder, findsNothing);
    });
  });
}
