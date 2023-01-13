import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../controls/form_control.dart';
import '../form/form.dart';

/// A widget which conditionally hides its children depending on whether the [control] is currently being validated
/// by its [FormCubit].
class ConditionalFormField<B extends FormCubit> extends StatelessWidget {
  /// The control to rely upon.
  ///
  /// When the control is part of a [FormCubit] and is not in the `validatedControls` of that cubit, it will not be shown
  /// or validated.
  final FormControl control;

  /// The child to optionally show.
  ///
  /// This should probably be at minimum the UI for the control this depends upon...
  final Widget child;

  /// Creates a widget which conditionally hides its children depending on whether the [control] is currently validated.
  const ConditionalFormField({
    super.key,
    required this.control,
    required this.child,
  });
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<B, FormCubitState>(builder: (context, state) {
      return state.controls.contains(control) ? child : const SizedBox.shrink();
    });
  }
}
