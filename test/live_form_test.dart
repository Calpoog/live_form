import 'package:flutter_test/flutter_test.dart';
import 'package:live_form/live_form.dart';

void testControlState({
  required bool result,
  bool valid = false,
  required bool pure,
  required bool focused,
  required bool touched,
  bool submitted = false,
}) {
  test(
      '${result ? '' : 'no '}error when ${valid ? 'valid' : 'invalid'}, ${pure ? 'pure' : 'dirty'}${touched ? ', touched' : ''}${focused ? ', focused' : ''}${focused ? ', submitted' : ''}',
      () {
    final control = TextFormControl(
        initialValue: valid ? 'xxx' : 'x', validators: [minLengthString(3)]);

    if (!pure) control.update(valid ? 'xxxx' : 'xx');
    if (focused) control.focusChanged(true);
    if (touched) control.markTouched();
    if (submitted) control.submit();

    expect(LiveForm().shouldShowError(control.state), result);
  });
}

void testControlStates(List<bool> results) {
  for (final valid in [true, false]) {
    // pure
    testControlState(
      result: valid ? false : results[0],
      valid: valid,
      pure: true,
      focused: false,
      touched: false,
    );
    testControlState(
      result: valid ? false : results[1],
      valid: valid,
      pure: true,
      focused: true,
      touched: false,
    );
    testControlState(
      result: valid ? false : results[2],
      valid: valid,
      pure: true,
      focused: false,
      touched: true,
    );
    testControlState(
      result: valid ? false : results[3],
      valid: valid,
      pure: true,
      focused: true,
      touched: true,
    );

    // dirty
    testControlState(
      result: valid ? false : results[4],
      valid: valid,
      pure: false,
      focused: false,
      touched: false,
    );
    testControlState(
      result: valid ? false : results[5],
      valid: valid,
      pure: false,
      focused: true,
      touched: false,
    );
    testControlState(
      result: valid ? false : results[6],
      valid: valid,
      pure: false,
      focused: false,
      touched: true,
    );
    testControlState(
      result: valid ? false : results[7],
      valid: valid,
      pure: false,
      focused: true,
      touched: true,
    );
  }
}

main() {
  group('Live Form', () {
    group('onChange error behavior: ', () {
      setUpAll(() => LiveForm().setErrorBehavior(ErrorBehavior.onChange));

      testControlStates([
        false, // pure
        false, // pure, focused
        false, // pure, touched,
        false, // pure, touched, focused
        true, // dirty
        true, // dirty, focused
        true, // dirty, touched,
        true, // dirty, touched, focused
      ]);
    });

    group('onTouched error behavior: ', () {
      setUpAll(() => LiveForm().setErrorBehavior(ErrorBehavior.onTouched));

      testControlStates([
        false, // pure
        false, // pure, focused
        true, // pure, touched,
        true, // pure, touched, focused
        false, // dirty
        false, // dirty, focused
        true, // dirty, touched,
        true, // dirty, touched, focused
      ]);
    });

    group('onFinish error behavior: ', () {
      setUpAll(() => LiveForm().setErrorBehavior(ErrorBehavior.onFinish));

      testControlStates([
        false, // pure
        false, // pure, focused
        false, // pure, touched,
        false, // pure, touched, focused
        false, // dirty
        false, // dirty, focused
        true, // dirty, touched,
        true, // dirty, touched, focused
      ]);
    });

    group('onSubmit error behavior: ', () {
      setUpAll(() => LiveForm().setErrorBehavior(ErrorBehavior.onSubmit));

      // all not submitted
      testControlStates([
        false, // pure
        false, // pure, focused
        false, // pure, touched,
        false, // pure, touched, focused
        false, // dirty
        false, // dirty, focused
        false, // dirty, touched,
        false, // dirty, touched, focused
      ]);

      // all submitted
      // submit marks everything dirty/touched, so there are no pure/untouched to test
      // the only variables once submit() is called is valid/focused
      testControlState(
        result: false,
        valid: true,
        pure: false,
        focused: false,
        touched: true,
        submitted: true,
      );
      testControlState(
        result: false,
        valid: true,
        pure: false,
        focused: true,
        touched: true,
        submitted: true,
      );
      testControlState(
        result: true,
        valid: false,
        pure: false,
        focused: false,
        touched: true,
        submitted: true,
      );
      testControlState(
        result: true,
        valid: false,
        pure: false,
        focused: true,
        touched: true,
        submitted: true,
      );
    });

    group('custom error behavior: ', () {
      setUpAll(() => LiveForm()
          .setCustomErrorBehavior((state) => state.focused && state.pure));

      test('shows/hides error based on custom function', () {
        final control = TextFormControl(validators: [minLengthString(3)]);

        expect(LiveForm().shouldShowError(control.state), false);

        control.focusChanged(true);

        expect(LiveForm().shouldShowError(control.state), true);

        control.update('xx');

        expect(LiveForm().shouldShowError(control.state), false);

        control.update('xxxx');

        expect(LiveForm().shouldShowError(control.state), false);
      });
    });
  });
}
