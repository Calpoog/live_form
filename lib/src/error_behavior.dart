import 'controls/form_control.dart';

bool _onChange(FormControlState state) => state.dirty;
bool _onTouched(FormControlState state) => state.touched;
bool _onFinish(FormControlState state) => state.dirty && state.touched;
bool _onSubmit(FormControlState state) => state.submitted;

/// The behavior forms will use to validate individual controls based on their state.
///
/// Validation is always occuring on state changes, but when errors are shown depends on
/// the `ErrorBehavior`. A control must be `invalid` and the conditions described per
/// behavior must be met for an error to display.
enum ErrorBehavior {
  /// Real-time validation. When a control is dirtied (a user makes a change)
  onChange(_onChange),

  /// When a control becomes touched.
  ///
  /// For fields with focus, when user has focused and unfocused the control.
  /// For other fields (like radios or checkboxes), they are marked touched when they are updated.
  onTouched(_onTouched),

  /// When a control becomes touched and dirtied.
  ///
  /// If a user focuses and unfocuses the control, but does not make a change, an error won't show.
  /// Only once a user has modified the control *and* unfocused the control will a potential error display.
  onFinish(_onFinish),

  /// When a control is submitted.
  ///
  /// A form `submit()` call submits all controls in the form. Submit marks all controls as dirty and
  /// touched, but still must be `submitted` to display an error. i.e. if a user focuses, modified (dirties),
  /// and then uncfocuses a control but the form has not been submitted, no error will show yet.
  onSubmit(_onSubmit);

  final bool Function(FormControlState state) predicate;

  const ErrorBehavior(this.predicate);
}
