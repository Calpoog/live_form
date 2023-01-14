part of 'form_control.dart';

/// The base state for all form controls
class FormControlState<T> {
  /// The value of the control.
  final T value;

  /// Whether the control is pure (unmodified by the user).
  final bool pure;

  /// Whether the control has been touched (focused and then unfocused).
  final bool touched;

  /// Whether the control has focus.
  final bool focused;

  /// The error message when the control is invalid.
  late final String? error;

  /// A list of [Validator] functions run in order on the `value` to determine the `error` message.
  final Iterable<Validator<T>>? validators;

  /// Whether this is the first error in the parent form.
  final bool isFirstError;

  /// Whether this control has been submitted
  final bool submitted;

  /// Creates the state of a control.
  FormControlState({
    required this.value,
    this.pure = true,
    this.touched = false,
    this.focused = false,
    this.validators,
    this.isFirstError = false,
    this.submitted = false,
  }) {
    if (validators != null) {
      String? firstError;
      for (final validator in validators!) {
        final error = validator(value);
        if (error != null) {
          firstError = error;
          break;
        }
      }
      error = firstError;
    } else {
      error = null;
    }
  }

  /// Whether the control is dirty (modified by the user).
  bool get dirty => !pure;

  /// Whether the control is valid based on `validators`.
  bool get valid => error == null;

  /// Whether the form is invalid.
  bool get invalid => !valid;

  // isFirstError gets reset each time so focus/onChange don't cause scrolling
  FormControlState<T> copyWith({
    T Function()? value,
    bool? pure,
    bool? touched,
    bool? focused,
    bool isFirstError = false,
    bool? submitted,
  }) {
    return FormControlState<T>(
      value: value == null ? this.value : value(),
      pure: pure ?? this.pure,
      touched: touched ?? this.touched,
      focused: focused ?? this.focused,
      validators: validators,
      isFirstError: isFirstError,
      submitted: submitted ?? this.submitted,
    );
  }

  @override
  String toString() => '(value: $value, state: [${[
        pure ? 'pure' : 'dirty',
        if (touched) 'touched',
        if (focused) 'focused',
        valid ? 'valid' : 'invalid',
        if (submitted) 'submitted',
        if (isFirstError) ' is first error'
      ].join(', ')}])';

  @override
  bool operator ==(Object other) {
    bool result = identical(this, other) ||
        other is FormControlState && runtimeType == other.runtimeType;

    if (!result) return false;

    final o = other as FormControlState;

    // if isFirstError is true at all, it's "new" because we want emit() to work
    if (isFirstError || o.isFirstError) {
      return false;
    }

    return value == o.value &&
        pure == o.pure &&
        touched == o.touched &&
        focused == o.focused &&
        error == o.error &&
        valid == o.valid &&
        submitted == o.submitted;
  }

  @override
  int get hashCode =>
      value.hashCode ^
      pure.hashCode ^
      touched.hashCode ^
      focused.hashCode ^
      submitted.hashCode ^
      validators.hashCode;
}

// A state which is the direct result of a submission with submit()
// so it can be ignored by the parent form's listener
class FormControlSubmissionState<T> extends FormControlState<T> {
  FormControlSubmissionState({
    required super.value,
    super.pure = true,
    super.touched = false,
    super.focused = false,
    super.validators,
    super.isFirstError = false,
    super.submitted = false,
  });
}
