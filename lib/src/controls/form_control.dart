import 'package:flutter_bloc/flutter_bloc.dart';

import '../validators.dart';

part 'form_control_state.dart';

/// The base bloc containing states representing a form control.
abstract class FormControl<T> extends Cubit<FormControlState<T>> {
  FormControl({required T initialValue, Iterable<Validator<T>>? validators})
      : super(FormControlState(value: initialValue, validators: validators));

  /// Updates the value of the control's state.
  void update(T value);

  /// Marks this control state as dirty.
  void markDirty();

  /// Marks this control state has having been touched.
  void markTouched();

  /// Called when the control changes focus
  void focusChanged(bool focused);

  /// Marks the control as dirty, touched, and submitted
  void submit({bool isFirstError = false}) {
    emit(
      FormControlSubmissionState(
        value: state.value,
        focused: state.focused,
        pure: false,
        submitted: true,
        touched: true,
        isFirstError: isFirstError,
        validators: state.validators,
      ),
    );
  }

  @override
  String toString() {
    return state.toString();
  }

  // Passthrough getters so you don't have to do form.username.state.value, etc.

  /// The value of the control.
  T get value => state.value;

  /// The validity of the control.
  bool get valid => state.valid;

  /// Whether the control state is invalid.
  bool get invalid => state.invalid;

  /// Whether the control state is pure (no user interaction).
  bool get pure => state.pure;

  /// Whether the control state is dirty (has been modified by the user).
  bool get dirty => state.dirty;

  /// Whether control is focused.
  bool get focused => state.focused;

  /// Whether the control has been touched (focused and then unfocused).
  bool get touched => state.touched;

  /// The error message when the control is invalid.
  String? get error => state.error;

  /// Whether this is the first error in the form.
  bool get isFirstError => state.isFirstError;

  /// Whether this control has been submitted.
  bool get submitted => state.submitted;
}
