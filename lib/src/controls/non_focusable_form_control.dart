import 'form_control.dart';

/// A base cubit for form controls which don't have a "focus" (e.g checkboxes and radio groups)
///
/// It is marked as `touched` and `dirty` on any user interaction.
class NonFocusableFormControl<T> extends FormControl<T> {
  NonFocusableFormControl({
    required super.initialValue,
    super.validators,
    super.dependent,
  });

  @override
  void update(T value) {
    emit(state.copyWith(value: () => value, pure: false, touched: true));
  }

  @override
  void markDirty() {
    emit(state.copyWith(pure: false, touched: true));
  }

  // Radios don't have the concept of focused or touched
  @override
  void markTouched() {
    throw UnimplementedError();
  }

  @override
  void focusChanged(bool focused) {
    throw UnimplementedError();
  }
}
