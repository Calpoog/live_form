import 'non_focusable_form_control.dart';

/// A bloc representing a group of radios which can hold any value type.
class RadioFormControl<T> extends NonFocusableFormControl<T> {
  RadioFormControl({required super.initialValue, super.validators});

  @override
  String toString() {
    return 'RadioFormControl${super.toString()}';
  }
}
