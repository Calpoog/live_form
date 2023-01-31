import 'non_focusable_form_control.dart';

/// A bloc representing a toggleable input like checkbox or switch.
///
/// `initialValue` defaults to false.
class ToggleFormControl extends NonFocusableFormControl<bool> {
  ToggleFormControl({
    super.initialValue = false,
    super.validators,
    super.dependent,
  });

  @override
  String toString() {
    return 'ToggleFormControl${super.toString()}';
  }
}
