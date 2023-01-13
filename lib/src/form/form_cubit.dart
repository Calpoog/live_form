import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../controls/form_control.dart';

part 'form_cubit_state.dart';

/// A bloc representing a generic form.
///
/// Subclasses should create final fields for each of the form controls it contains and override [controls] and
/// [validatedControls].
abstract class FormCubit extends Cubit<FormCubitState> {
  FormCubit() : super(const FormCubitState()) {
    _init();
  }

  /// All of the controls in the form.
  List<FormControl> get controls;

  List<StreamSubscription> _listeners = [];

  /// Only the controls that are currently being validated.
  ///
  /// Use conditional logic to exclude controls.
  /// This is used by the [ConditionalFormField] widget to determine whether to display its subtree.
  List<FormControl> get validatedControls => controls;

  /// Whether the entire form is valid.
  bool get valid => state.valid;

  /// Whether any controls in the form are invalid.
  bool get invalid => state.invalid;

  // Initialize by listening to member controls and validating/emitting the first state
  void _init() {
    _listeners = controls
        .map((control) => control.stream.listen(_controlUpdated))
        .toList();

    emit(state.copyWith(
      valid: validatedControls.every((control) => control.valid),
      controls: validatedControls,
    ));
  }

  @override
  Future<void> close() {
    for (var listener in _listeners) {
      listener.cancel();
    }

    for (var control in controls) {
      control.close();
    }

    return super.close();
  }

  // Called when a control changes state in the form.
  void _controlUpdated(FormControlState controlState) {
    // Submission states never change validity because it does not update value
    if (controlState is FormControlSubmissionState) return;

    emit(state.copyWith(
      valid: validatedControls.every((control) => control.valid),
      controls: validatedControls,
    ));
  }

  /// Submits the form, maybe emitting a new state, and returns the form's validity.
  ///
  /// A [FormCubitSuccessState] will be emitted if all controls are valid.
  /// Otherwise, a [FormCubitFailedState] will be emitted.
  ///
  /// In any case, the `submitted` property of all future states will be true, indicating
  /// that the form has had a submission attempt.
  ///
  /// Returns the validity of the form.
  bool submit() {
    bool hasError = false;

    for (final control in controls) {
      // Mark all controls (validated or not) as submitted, since after submit all validation is real-time
      control.submit();
      if (control.state.invalid && validatedControls.contains(control)) {
        hasError = true;
      }
    }

    emit(!hasError ? state._toSuccess() : state._toFailure());

    return !hasError;
  }

  /// Marks the first invalid control in the form as needing scrolled into view.
  ///
  /// The FormControl variation widgets listen to their [FormControl]s and handle the UI scrolling.
  void viewFirstError() {
    try {
      final firstError =
          validatedControls.firstWhere((control) => control.state.invalid);
      firstError.submit(isFirstError: true);
      // ignore: empty_catches
    } catch (e) {}
  }
}
