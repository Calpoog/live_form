import 'focusable_form_control.dart';

/// A bloc representing a string-value text input.
class TextFormControl extends FocusableFormControl<String> {
  TextFormControl({super.initialValue = '', super.validators});

  @override
  String toString() {
    return 'TextFormControl${super.toString()}';
  }
}
