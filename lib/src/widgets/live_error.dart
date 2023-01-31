import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../controls/form_control.dart';

/// A widget to display the error from any [FormControl].
///
/// For input widgets which don't have a `decoration`/`errorText` available. This allows the error to be placed
/// any anywhere. However, if creating a new custom widget and making it work much like the other live_form widgets,
/// you'll likely already have the whole build wrapped in a `BlocBuilder`/`BlocConsumer`. It's simpler then include the
/// error in that tree instead of using this widget which itself relies on a separate `BlocBuilder`.
class LiveError extends StatelessWidget {
  /// A custom `TextStyle` for the error message.
  ///
  /// This will be merged with the `caption` Material theme and `ThemeData` `errorColor`.
  final TextStyle? errorStyle;

  /// The `FormControl` to watch for error changes to display.
  final FormControl control;

  /// Creates a widget to display a `FormControl` error message.
  const LiveError({
    super.key,
    required this.control,
    this.errorStyle,
  });

  // Mimics the error style of Material
  TextStyle _getErrorStyle(ThemeData themeData) {
    final Color color = themeData.errorColor;
    return themeData.textTheme.caption!
        .copyWith(color: color)
        .merge(errorStyle);
  }

  @override
  Widget build(BuildContext context) {
    final style = _getErrorStyle(Theme.of(context));

    return BlocBuilder<FormControl<dynamic>, FormControlState<dynamic>>(
      bloc: control,
      buildWhen: (previous, current) => current.error != previous.error,
      builder: (context, state) => control.error == null
          ? const SizedBox.shrink()
          : Text(
              control.error!,
              style: style,
            ),
    );
  }
}
