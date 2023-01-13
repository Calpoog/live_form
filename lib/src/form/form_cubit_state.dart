part of 'form_cubit.dart';

/// The state of a form.
///
/// Details the form's validity, the controls being validated, and whether it has been submitted.
class FormCubitState extends Equatable {
  /// The validity of the entire form
  final bool valid;

  /// The controls currently being validated
  final List<FormControl> controls;

  /// Whether the form has ever had a submit attempt
  final bool submitted;

  /// Creates the state of a form
  const FormCubitState({
    this.valid = true,
    this.submitted = false,
    this.controls = const [],
  });

  /// Whether *any* control in the form is invalid
  bool get invalid => !valid;

  FormCubitState copyWith({
    bool? valid,
    bool? submitted,
    List<FormControl>? controls,
  }) {
    return FormCubitState(
      valid: valid ?? this.valid,
      submitted: submitted ?? this.submitted,
      controls: controls ?? this.controls,
    );
  }

  FormCubitSuccessState _toSuccess() {
    return FormCubitSuccessState._(controls: controls);
  }

  FormCubitFailedState _toFailure() {
    return FormCubitFailedState._(controls: controls);
  }

  @override
  List<Object?> get props => [valid, submitted, controls];
}

/// The success state of a form, emitted only when all controls are valid and `submit` is called.
class FormCubitSuccessState extends FormCubitState {
  const FormCubitSuccessState._({required List<FormControl> controls})
      : super(valid: true, submitted: true, controls: controls);
}

/// The failed submission state of a form, emitted only when `submit` is called but the form has errors.
class FormCubitFailedState extends FormCubitState {
  const FormCubitFailedState._({required List<FormControl> controls})
      : super(valid: false, submitted: true, controls: controls);

  // Allows new failed states with the same params to trigger onSubmissionFailure
  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) => identical(this, other);
}
