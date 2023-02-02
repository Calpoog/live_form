import 'package:flutter/material.dart' hide FormFieldState;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_form/live_form.dart';

class LiveCheckboxFormField extends StatelessWidget {
  final ToggleFormControl control;

  // pass-through values
  final MouseCursor? mouseCursor;
  final Color? activeColor;
  final MaterialStateProperty<Color?>? fillColor;
  final Color? checkColor;
  // final bool tristate;
  final MaterialTapTargetSize? materialTapTargetSize;
  final VisualDensity? visualDensity;
  final Color? focusColor;
  final Color? hoverColor;
  final MaterialStateProperty<Color?>? overlayColor;
  final double? splashRadius;
  final FocusNode? focusNode;
  final bool autofocus;
  final OutlinedBorder? shape;
  final BorderSide? side;

  const LiveCheckboxFormField({
    super.key,
    required this.control,
    // this.tristate = false,
    this.mouseCursor,
    this.activeColor,
    this.fillColor,
    this.checkColor,
    this.focusColor,
    this.hoverColor,
    this.overlayColor,
    this.splashRadius,
    this.materialTapTargetSize,
    this.visualDensity,
    this.focusNode,
    this.autofocus = false,
    this.shape,
    this.side,
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
        return Checkbox(
          value: control.value,
          onChanged: (value) => control.update(value ?? false),
          isError: control.invalid && LiveForm().shouldShowError(control.state),
          mouseCursor: mouseCursor,
          activeColor: activeColor,
          fillColor: fillColor,
          checkColor: checkColor,
          focusColor: focusColor,
          hoverColor: hoverColor,
          overlayColor: overlayColor,
          splashRadius: splashRadius,
          materialTapTargetSize: materialTapTargetSize,
          visualDensity: visualDensity,
          focusNode: focusNode,
          autofocus: autofocus,
          shape: shape,
          side: side,
        );
      },
    );
  }
}
