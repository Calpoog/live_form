import 'controls/form_control.dart';
import 'error_behavior.dart';

class LiveForm {
  static final LiveForm instance = LiveForm._internal();

  factory LiveForm() {
    return instance;
  }

  LiveForm._internal();

  bool Function(FormControlState state) _errorBehavior =
      ErrorBehavior.onTouched.predicate;

  bool shouldShowError(FormControlState control) {
    return control.invalid && _errorBehavior.call(control);
  }

  void setErrorBehavior(ErrorBehavior behavior) {
    _errorBehavior = behavior.predicate;
  }

  void setCustomErrorBehavior(bool Function(FormControlState state) logic) {
    _errorBehavior = logic;
  }
}
