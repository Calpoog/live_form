import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:live_form/live_form.dart';
import 'package:live_form/src/form/form_cubit.dart';

void main() {
  group('FormControlState', () {
    test('can be created with default values', () {
      final state = FormControlState<int>(value: 0);
      expect(state.pure, true);
      expect(state.dirty, false);
      expect(state.touched, false);
      expect(state.focused, false);
      expect(state.isFirstError, false);
      expect(state.error, null);
      expect(state.valid, true);
      expect(state.invalid, false);
      expect(state.submitted, false);
    });

    test('has same hash except for isFirstError', () {
      final state = FormControlState<int>(value: 0);
      var other = FormControlState<int>(value: 0);
      expect(state.hashCode, other.hashCode);

      other = FormControlState<int>(value: 0, isFirstError: true);
      expect(state.hashCode, other.hashCode);

      other = FormControlState<int>(value: 1);
      expect(state.hashCode, isNot(other.hashCode));

      other = FormControlState<int>(value: 0, focused: true);
      expect(state.hashCode, isNot(other.hashCode));

      other = FormControlState<int>(value: 0, touched: true);
      expect(state.hashCode, isNot(other.hashCode));

      other = FormControlState<int>(value: 0, pure: false);
      expect(state.hashCode, isNot(other.hashCode));

      other = FormControlState<int>(value: 0, submitted: true);
      expect(state.hashCode, isNot(other.hashCode));

      other = FormControlState<int>(value: 0, validators: [(v) => null]);
      expect(state.hashCode, isNot(other.hashCode));
    });

    test('can be created with custom values', () {
      final state = FormControlState<int>(
        value: 0,
        pure: false,
        touched: true,
        focused: true,
        submitted: true,
        isFirstError: true,
      );
      expect(state.pure, false);
      expect(state.dirty, true);
      expect(state.touched, true);
      expect(state.focused, true);
      expect(state.isFirstError, true);
      expect(state.error, null);
      expect(state.valid, true);
      expect(state.invalid, false);
      expect(state.submitted, true);
    });

    test('can be created with a valid validator', () {
      final state = FormControlState<int>(
          value: 0, validators: [(value) => value < 10 ? null : 'error']);

      expect(state.error, null);
      expect(state.valid, true);
      expect(state.invalid, false);
    });

    test('can be created with an invalid validator', () {
      final state = FormControlState<int>(
          value: 11, validators: [(value) => value < 10 ? null : 'error']);

      expect(state.error, 'error');
      expect(state.valid, false);
      expect(state.invalid, true);
    });

    test('has an error corresponding to the first invalid validator', () {
      final state = FormControlState<int>(value: 3, validators: [
        (value) => value > 2 ? null : 'first',
        (value) => value > 5 ? null : 'second',
        (value) => value > 10 ? null : 'third',
      ]);

      expect(state.error, 'second');
      expect(state.valid, false);
      expect(state.invalid, true);
    });

    test('can be copied', () {
      final oldState = FormControlState<int>(
        value: 0,
        validators: [(value) => value == 0 ? null : 'error'],
        isFirstError: true,
      );
      final state = oldState.copyWith(
        value: () => 1,
        pure: false,
        touched: true,
        focused: true,
        submitted: true,
      );

      expect(state.pure, false);
      expect(state.dirty, true);
      expect(state.touched, true);
      expect(state.focused, true);
      // isFirstError defaults to false when not explicitly provided
      expect(state.isFirstError, false);
      expect(state.valid, false);
      expect(state.invalid, true);
      expect(state.submitted, true);
      expect(oldState.error, null);
      expect(state.error, 'error');
    });

    test('can be compared', () {
      final state = FormControlState<int>(value: 0);
      var other = FormControlState<int>(value: 0);

      expect(state, other);

      other = FormControlState<int>(value: 1);
      expect(state, isNot(other));

      other = FormControlState<int>(value: 0, pure: false);
      expect(state, isNot(other));

      other = FormControlState<int>(value: 0, touched: true);
      expect(state, isNot(other));

      other = FormControlState<int>(value: 0, focused: true);
      expect(state, isNot(other));

      other = FormControlState<int>(value: 0, validators: [(v) => null]);
      expect(state, other);
    });

    test('are considered != when either isFirstError is true', () {
      final state = FormControlState<int>(value: 0, isFirstError: true);
      final other = FormControlState<int>(value: 0, isFirstError: true);
      final other2 = FormControlState<int>(value: 0);

      expect(state, isNot(other));
      expect(state, isNot(other2));
    });
  });

  group('FocusableFormControl', () {
    test('has the provided initial value', () {
      final state = FocusableFormControl(initialValue: 0).state;
      expect(state.value, 0);
      expect(state.pure, true);
    });

    blocTest(
      'can update its value',
      build: () => FocusableFormControl(initialValue: 0),
      act: (bloc) => bloc.update(1),
      expect: () => [
        FormControlState(
          value: 1,
          pure: false,
        ),
      ],
    );

    blocTest(
      'can be focused and touched',
      build: () => FocusableFormControl(initialValue: 0),
      act: (bloc) {
        bloc.focusChanged(true);
        bloc.focusChanged(false);
      },
      expect: () => [
        FormControlState(value: 0, focused: true),
        FormControlState(value: 0, touched: true),
      ],
    );

    blocTest(
      'can be made dirty',
      build: () => FocusableFormControl(initialValue: 0),
      act: (bloc) => bloc.markDirty(),
      expect: () => [FormControlState(value: 0, pure: false)],
    );

    blocTest(
      'can be made touched',
      build: () => FocusableFormControl(initialValue: 0),
      act: (bloc) => bloc.markTouched(),
      expect: () => [FormControlState(value: 0, touched: true)],
    );

    test('can be submitted', () {
      final control = FocusableFormControl(initialValue: 0)..submit();

      expect(control.pure, false);
      expect(control.touched, true);
      expect(control.submitted, true);
    });
  });

  group('NonFocusableFormControl', () {
    test('has the provided initial value', () {
      final state = NonFocusableFormControl(initialValue: 0).state;
      expect(state.value, 0);
      expect(state.pure, true);
    });

    blocTest(
      'can update its value',
      build: () => NonFocusableFormControl(initialValue: 0),
      act: (bloc) => bloc.update(1),
      expect: () => [
        FormControlState(
          value: 1,
          pure: false,
          touched: true,
        ),
      ],
    );

    blocTest(
      'can\'t be focused',
      build: () => NonFocusableFormControl(initialValue: 0),
      act: (bloc) => bloc.focusChanged(true),
      errors: () => [isA<UnimplementedError>()],
    );

    blocTest(
      'can\'t be touched',
      build: () => NonFocusableFormControl(initialValue: 0),
      act: (bloc) => bloc.markTouched(),
      errors: () => [isA<UnimplementedError>()],
    );

    blocTest(
      'can be made dirty',
      build: () => NonFocusableFormControl(initialValue: 0),
      act: (bloc) => bloc.markDirty(),
      expect: () => [FormControlState(value: 0, pure: false, touched: true)],
    );

    test('can be submitted', () {
      final control = NonFocusableFormControl(initialValue: 0)..submit();

      expect(control.pure, false);
      expect(control.touched, true);
      expect(control.submitted, true);
    });
  });

  group('TextFormControl', () {
    test('has the provided initial value', () {
      final control = TextFormControl(initialValue: '');
      expect(control.value, '');
      expect(control.valid, true);
      expect(control.invalid, false);
      expect(control.pure, true);
      expect(control.dirty, false);
      expect(control.touched, false);
      expect(control.focused, false);
      expect(control.error, null);
    });

    blocTest(
      'can update its value',
      build: () => TextFormControl(initialValue: ''),
      act: (bloc) => bloc.update('test'),
      expect: () => [
        FormControlState(
          value: 'test',
          pure: false,
        ),
      ],
    );

    blocTest(
      'can be focused',
      build: () => TextFormControl(initialValue: ''),
      act: (bloc) {
        bloc.focusChanged(true);
      },
      expect: () => [
        FormControlState(value: '', focused: true),
      ],
      verify: (bloc) {
        expect(bloc.focused, true);
      },
    );

    blocTest(
      'can be focused and touched',
      build: () => TextFormControl(initialValue: ''),
      act: (bloc) {
        bloc.focusChanged(true);
        bloc.focusChanged(false);
      },
      expect: () => [
        FormControlState(value: '', focused: true),
        FormControlState(value: '', touched: true),
      ],
      verify: (bloc) {
        expect(bloc.touched, true);
        expect(bloc.focused, false);
      },
    );

    blocTest(
      'can be made dirty',
      build: () => TextFormControl(initialValue: ''),
      act: (bloc) => bloc.markDirty(),
      expect: () => [FormControlState(value: '', pure: false)],
    );

    blocTest(
      'can be made touched',
      build: () => TextFormControl(initialValue: ''),
      act: (bloc) => bloc.markTouched(),
      expect: () => [FormControlState(value: '', touched: true)],
    );
  });

  group('SelectionFormControl', () {
    test('stringifies', () {
      final control = SelectionFormControl(initialValue: '');
      expect(control.toString(),
          'SelectionFormControl(value: ' ', state: [pure, valid])');
    });
  });

  group('NumberFormControl', () {
    test('stringifies', () {
      final control = NumberFormControl(initialValue: 1);
      expect(control.toString(),
          'NumberFormControl(value: 1, state: [pure, valid])');
    });
  });

  group('RadioFormControl', () {
    test('has the provided initial value', () {
      final state = RadioFormControl<int?>(initialValue: null).state;
      expect(state.value, null);
      expect(state.pure, true);
    });

    blocTest(
      'can update its value',
      build: () => RadioFormControl<int?>(initialValue: null),
      act: (bloc) => bloc.update(1),
      expect: () => [
        FormControlState<int?>(
          value: 1,
          pure: false,
          touched: true,
        ),
      ],
    );

    blocTest(
      'can\'t be focused',
      build: () => RadioFormControl<int?>(initialValue: 0),
      act: (bloc) => bloc.focusChanged(true),
      errors: () => [isA<UnimplementedError>()],
    );

    blocTest(
      'can\'t be touched',
      build: () => RadioFormControl<int?>(initialValue: 0),
      act: (bloc) => bloc.markTouched(),
      errors: () => [isA<UnimplementedError>()],
    );

    blocTest(
      'can be made dirty',
      build: () => RadioFormControl<int?>(initialValue: 1),
      act: (bloc) => bloc.markDirty(),
      expect: () => [
        FormControlState<int?>(value: 1, pure: false, touched: true),
      ],
    );
  });

  group('FormCubitState', () {
    test('can be created with default values', () {
      const state = FormCubitState();

      expect(state.controls, []);
      expect(state.valid, true);
      expect(state.invalid, false);
      expect(state.submitted, false);
    });

    test('can be created with custom values', () {
      final textControl = TextFormControl(initialValue: 'test');
      final state = FormCubitState(
        valid: true,
        submitted: true,
        controls: [textControl],
      );

      expect(state.controls, [textControl]);
      expect(state.valid, true);
      expect(state.invalid, false);
      expect(state.submitted, true);
    });

    test('can be copied', () {
      final textControl = TextFormControl(initialValue: 'test');
      var state = const FormCubitState().copyWith(
        valid: true,
        submitted: true,
        controls: [textControl],
      );

      expect(state.controls, [textControl]);
      expect(state.valid, true);
      expect(state.invalid, false);
      expect(state.submitted, true);

      state = const FormCubitState().copyWith();

      expect(state.valid, true);
      expect(state.submitted, false);
    });
  });

  group('FormCubit', () {
    blocTest(
      'is initially invalid',
      build: () => TestFormCubit(),
      verify: (bloc) {
        expect(
          bloc.state,
          FormCubitState(valid: false, controls: bloc.validatedControls),
        );
      },
    );

    blocTest(
      'emits a failure state on submit',
      build: () => TestFormCubit(),
      act: (bloc) => bloc.submit(),
      expect: () => [isA<FormCubitFailedState>()],
      verify: (bloc) {
        expect(bloc.valid, false);
        expect(bloc.invalid, true);
        expect(bloc.state.submitted, true);
      },
    );

    blocTest(
      'does not emit a new state when a field changes but no validity or controls change',
      build: () => TestFormCubit(),
      act: (bloc) async {
        bloc.radioControl.update(2);
      },
      expect: () => [],
    );

    blocTest(
      'emits a new state when a field changes the form validity',
      build: () => TestFormCubit(),
      act: (bloc) async {
        bloc.textControl.update('test');
      },
      verify: (bloc) {
        expect(bloc.state.valid, true);
        expect(bloc.state.controls.length, 2);
      },
    );

    blocTest(
      'emits a new state when a field changes the validated fields',
      build: () => TestFormCubit(),
      act: (bloc) async {
        bloc.radioControl.update(1);
      },
      verify: (bloc) {
        expect(bloc.state.invalid, true);
        expect(bloc.state.controls.length, 3);
        expect(bloc.validatedControls.length, 3);
      },
    );

    blocTest(
      'emits a success state on submit',
      build: () => TestFormCubit(),
      act: (bloc) async {
        bloc.textControl.update('test');
        await Future.delayed(const Duration());
        bloc.submit();
      },
      skip: 1,
      expect: () => [isA<FormCubitSuccessState>()],
      verify: (bloc) {
        expect(bloc.valid, true);
        expect(bloc.invalid, false);
        expect(bloc.state.submitted, true);
      },
    );

    blocTest(
      'can mark the first error',
      build: () => TestFormCubit(),
      act: (bloc) {
        bloc.submit();
        bloc.viewFirstError();
      },
      expect: () => [isA<FormCubitFailedState>()],
      verify: (bloc) {
        expect(bloc.textControl.isFirstError, true);
      },
    );

    test(
      'validated controls defaults to all controls',
      () {
        final form = SimpleFormCubit();
        expect(form.validatedControls, form.controls);
      },
    );
  });
}

class SimpleFormCubit extends FormCubit {
  @override
  List<FormControl> get controls => [];
}

class TestFormCubit extends FormCubit {
  final textControl =
      TextFormControl(initialValue: '', validators: [requiredString]);
  final radioControl = RadioFormControl<int?>(initialValue: null);
  final conditionalControl = TextFormControl(initialValue: '');

  @override
  List<FormControl> get controls =>
      [textControl, radioControl, conditionalControl];

  @override
  List<FormControl> get validatedControls => [
        textControl,
        radioControl,
        if (radioControl.value == 1) conditionalControl,
      ];
}
