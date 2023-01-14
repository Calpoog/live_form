import 'form_control.dart';

/// A base cubit for form controls which can take focus (e.g. text inputs)
///
/// Marked `dirty` when a user changes its value
/// Marked `touched` when a user has focused and then unfocused (blur) the control.
class FocusableFormControl<T> extends FormControl<T> {
  FocusableFormControl({
    required super.initialValue,
    super.validators,
    super.dependent,
  });

  @override
  void update(T value) {
    emit(state.copyWith(value: () => value, pure: false));
  }

  @override
  void markDirty() {
    emit(state.copyWith(pure: false));
  }

  @override
  void markTouched() {
    emit(state.copyWith(touched: true));
  }

  @override
  void focusChanged(bool focused) {
    emit(state.copyWith(focused: focused, touched: state.touched || !focused));
  }
}
