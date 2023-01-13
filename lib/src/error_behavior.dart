import 'controls/form_control.dart';

bool _onChange(FormControlState state) => state.dirty;
bool _onTouched(FormControlState state) => state.touched;
bool _onFinish(FormControlState state) => state.dirty && state.touched;
bool _onSubmit(FormControlState state) => state.submitted;

enum ErrorBehavior {
  onChange(_onChange),
  onTouched(_onTouched),
  onFinish(_onFinish),
  onSubmit(_onSubmit);

  final bool Function(FormControlState state) predicate;

  const ErrorBehavior(this.predicate);
}
