import 'package:flutter/material.dart' hide FormFieldState;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_form/live_form.dart';

import '../controls/controls.dart';

class LiveRadio<T> {
  final T value;
  final Color? activeColor;
  final Widget? title;
  final Widget? subtitle;
  final Widget? secondary;
  final bool isThreeLine;
  final bool? dense;
  final ListTileControlAffinity controlAffinity;
  final bool autofocus;
  final EdgeInsetsGeometry? contentPadding;
  final ShapeBorder? shape;
  final Color? tileColor;
  final Color? selectedTileColor;
  final VisualDensity? visualDensity;
  final FocusNode? focusNode;
  final bool? enableFeedback;

  const LiveRadio({
    required this.value,
    this.activeColor,
    this.title,
    this.subtitle,
    this.isThreeLine = false,
    this.dense,
    this.secondary,
    this.controlAffinity = ListTileControlAffinity.platform,
    this.autofocus = false,
    this.contentPadding,
    this.shape,
    this.tileColor,
    this.selectedTileColor,
    this.visualDensity,
    this.focusNode,
    this.enableFeedback,
  });
}

class LiveRadioGroupFormField<T> extends StatelessWidget {
  final RadioFormControl<T> control;
  final List<LiveRadio<T>> items;
  final void Function(T?)? onChanged;
  final bool toggleable;

  const LiveRadioGroupFormField({
    super.key,
    required this.control,
    required this.items,
    this.onChanged,
    this.toggleable = false,
  }) : assert(null is T || toggleable == false,
            'If a radio group is toggleable it must use a nullable type T');

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RadioFormControl<T>, FormControlState<T>>(
      bloc: control,
      listenWhen: (previous, current) => current.isFirstError,
      listener: (context, state) {
        Scrollable.ensureVisible(context,
            duration: const Duration(milliseconds: 300));
      },
      builder: (context, state) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: items
              .map(
                (item) => RadioListTile(
                  value: item.value,
                  groupValue: state.value,
                  activeColor: item.activeColor,
                  autofocus: item.autofocus,
                  contentPadding: item.contentPadding,
                  controlAffinity: item.controlAffinity,
                  dense: item.dense,
                  enableFeedback: item.enableFeedback,
                  focusNode: item.focusNode,
                  isThreeLine: item.isThreeLine,
                  secondary: item.secondary,
                  selected: item.value == control.value,
                  selectedTileColor: item.selectedTileColor,
                  shape: item.shape,
                  subtitle: item.subtitle,
                  tileColor: item.tileColor,
                  title: item.title,
                  toggleable: toggleable,
                  visualDensity: item.visualDensity,
                  // cast value to T as we know it's either nullable and toggleable can be true/false
                  // or that toggleable is false and T is non-nullable (due to constructor assertion)
                  onChanged: (value) => control.update(value as T),
                ),
              )
              .toList(),
        );
      },
    );
  }
}
