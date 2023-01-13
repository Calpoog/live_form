import 'focusable_form_control.dart';

/// A bloc representing an integer-value text input.
class NumberFormControl extends FocusableFormControl<int?> {
  NumberFormControl({super.initialValue, super.validators});

  @override
  String toString() {
    return 'NumberFormControl${super.toString()}';
  }
}
