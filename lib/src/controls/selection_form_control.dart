import 'focusable_form_control.dart';

/// A bloc representing a selectable and focusable field (dropdowns)
class SelectionFormControl<T> extends FocusableFormControl<T> {
  SelectionFormControl({
    required super.initialValue,
    super.validators,
    super.dependent,
  });

  @override
  String toString() {
    return 'SelectionFormControl${super.toString()}';
  }
}
