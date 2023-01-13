import 'package:flutter/material.dart' hide FormFieldState;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../controls/controls.dart';
import '../live_form.dart';

/// A generic widget which hooks up a `FormControl` to a `TextField` and allows
/// for value transformation between the two.
class LiveDropdownButtonFormField<T> extends StatefulWidget {
  /// A `SelectionFormControl` or subclass which controls the field's state and value.
  final SelectionFormControl<T> control;

  // Passthrough values
  final List<DropdownMenuItem<T>>? items;
  final T? value;
  final Widget? hint;
  final Widget? disabledHint;
  final VoidCallback? onTap;
  final DropdownButtonBuilder? selectedItemBuilder;
  final int elevation;
  final TextStyle? style;
  final Widget? underline;
  final Widget? icon;
  final Color? iconDisabledColor;
  final Color? iconEnabledColor;
  final double iconSize;
  final bool isDense;
  final bool isExpanded;
  final double? itemHeight;
  final Color? focusColor;
  final FocusNode? focusNode;
  final bool autofocus;
  final Color? dropdownColor;
  final double? menuMaxHeight;
  final bool? enableFeedback;
  final AlignmentGeometry alignment;
  final BorderRadius? borderRadius;

  LiveDropdownButtonFormField({
    super.key,
    required this.control,

    // Passthrough values
    required this.items,
    this.selectedItemBuilder,
    this.value,
    this.hint,
    this.disabledHint,
    this.onTap,
    this.elevation = 8,
    this.style,
    this.underline,
    this.icon,
    this.iconDisabledColor,
    this.iconEnabledColor,
    this.iconSize = 24.0,
    this.isDense = false,
    this.isExpanded = false,
    this.itemHeight = kMinInteractiveDimension,
    this.focusColor,
    this.focusNode,
    this.autofocus = false,
    this.dropdownColor,
    this.menuMaxHeight,
    this.enableFeedback,
    this.alignment = AlignmentDirectional.centerStart,
    this.borderRadius,
  }) {
    assert(
      items != null && Null is! T && items!.every((item) => item.value != null),
      'LiveDropdownButtonFormField type T must be nullable if any of the items have a null value',
    );
  }

  @override
  State<LiveDropdownButtonFormField> createState() =>
      _LiveDropdownButtonFormFieldState<T>();
}

class _LiveDropdownButtonFormFieldState<T>
    extends State<LiveDropdownButtonFormField<T>> {
  FocusNode? _focusNode;
  FocusNode get _effectiveFocusNode =>
      widget.focusNode ?? (_focusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _effectiveFocusNode.addListener(_handleFocusChanged);
  }

  @override
  void didUpdateWidget(covariant LiveDropdownButtonFormField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.focusNode != oldWidget.focusNode) {
      (oldWidget.focusNode ?? _focusNode)?.removeListener(_handleFocusChanged);
      (widget.focusNode ?? _focusNode)?.addListener(_handleFocusChanged);
    }
  }

  @override
  void dispose() {
    _effectiveFocusNode.removeListener(_handleFocusChanged);
    _focusNode?.dispose();
    super.dispose();
  }

  void _handleFocusChanged() {
    widget.control.focusChanged(_effectiveFocusNode.hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SelectionFormControl<T>, FormControlState<T>>(
      bloc: widget.control,
      listenWhen: (previous, current) => current.isFirstError,
      listener: (context, state) {
        Scrollable.ensureVisible(context,
            duration: const Duration(milliseconds: 300));
      },
      builder: (context, state) {
        return DropdownButton(
          // TODO: how is onChanged ever called with null in a non-nullable T scenario?
          onChanged: (value) => widget.control.update(value as T),
          value: state.value,
          focusNode: _effectiveFocusNode,
          items: widget.items,
          hint: widget.hint,
          disabledHint: widget.disabledHint,
          onTap: widget.onTap,
          selectedItemBuilder: widget.selectedItemBuilder,
          elevation: widget.elevation,
          style: widget.style,
          underline: widget.underline,
          icon: widget.icon,
          iconDisabledColor: widget.iconDisabledColor,
          iconEnabledColor: widget.iconEnabledColor,
          iconSize: widget.iconSize,
          isDense: widget.isDense,
          isExpanded: widget.isExpanded,
          itemHeight: widget.itemHeight,
          focusColor: widget.focusColor,
          autofocus: widget.autofocus,
          dropdownColor: widget.dropdownColor,
          menuMaxHeight: widget.menuMaxHeight,
          enableFeedback: widget.enableFeedback,
          alignment: widget.alignment,
          borderRadius: widget.borderRadius,
        );
      },
    );
  }
}
