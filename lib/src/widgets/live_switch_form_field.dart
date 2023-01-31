import 'package:flutter/material.dart' hide FormFieldState;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_form/live_form.dart';

class LiveSwitchFormField extends StatelessWidget {
  final ToggleFormControl control;

  const LiveSwitchFormField({
    super.key,
    required this.control,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ToggleFormControl, FormControlState<bool>>(
      bloc: control,
      listenWhen: (previous, current) => current.isFirstError,
      listener: (context, state) {
        Scrollable.ensureVisible(context,
            duration: const Duration(milliseconds: 300));
      },
      builder: (context, state) {
        return Switch(
          value: control.value,
          onChanged: (value) => control.update(value),
        );
      },
    );
  }
}
