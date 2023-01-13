import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_form/live_form.dart';

import '../forms_test.dart';

void main() {
  group('FormCubitProvider', () {
    testWidgets('creates and provides a cubit to the subtree', (tester) async {
      final cubit = TestFormCubit();

      await tester.pumpWidget(
        MaterialApp(
          home: FormCubitProvider(
            create: (context) => cubit,
            builder: (context, form) {
              if (context.read<TestFormCubit>() != form) {
                throw Exception();
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(tester.takeException(), null);
    });

    testWidgets('calls its failed/success/validity callbacks', (tester) async {
      final cubit = TestFormCubit();
      var result = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: FormCubitProvider(
            create: (context) => cubit,
            onSubmissionFailed: (form) => result = 1,
            onSubmissionSuccess: (form) => result = 2,
            onValidChange: (form) => result = 3,
            builder: (context, form) {
              if (context.read<TestFormCubit>() != form) {
                throw Exception();
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(cubit.invalid, true);

      cubit.textControl.update('test');
      await tester.pumpAndSettle();
      expect(result, 3,
          reason: 'onValidChange should be called going to valid');

      result = 0;
      cubit.textControl.update('');
      await tester.pumpAndSettle();
      expect(result, 3,
          reason: 'onValidChange should be called going back to invalid');

      cubit.submit();
      await tester.pumpAndSettle();
      expect(
        result,
        1,
        reason: 'onSubmissionFailed should be called on submit while invalid',
      );

      cubit.textControl.update('test');
      cubit.submit();
      await tester.pumpAndSettle();
      expect(
        result,
        2,
        reason: 'onSubmissionSuccess should be called on submit while valid',
      );
    });
  });
}
