// part of '../forms.dart';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../error_behavior.dart';
import '../form/form_cubit.dart';

/// A widget to provide a [FormCubit] to its children and exposes callbacks for various form events.
class FormCubitProvider<T extends FormCubit> extends StatelessWidget {
  /// A builder function for the subtree which has access to the [FormCubit] provided.
  ///
  /// Gives a [BuildContext] scoped under the provider, and direct access to the [FormCubit] as `form` to avoid a
  /// context lookup.
  final Widget Function(BuildContext context, T form) builder;

  /// A function to create the [FormCubit]
  final T Function(BuildContext context) create;

  /// A callback for when the form is successfully submitted.
  final void Function(T form)? onSubmissionSuccess;

  /// A callback for when the form attempts a submit but there are errors.
  final void Function(T form)? onSubmissionFailed;

  /// A callback for when the validity status changes (both valid=>invalid and invalid=>valid)
  final void Function(T form)? onValidChange;

  /// The behavior of when to show field errors
  final ErrorBehavior errorBehavior;

  /// Creates a widget which provides a [FormCubit] to its children.
  const FormCubitProvider({
    super.key,
    required this.create,
    required this.builder,
    this.onSubmissionSuccess,
    this.onSubmissionFailed,
    this.onValidChange,
    this.errorBehavior = ErrorBehavior.onTouched,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<T>(
      create: create,
      child: Builder(
        builder: (context) {
          final form = context.read<T>();
          return MultiBlocListener(
            listeners: [
              BlocListener<T, FormCubitState>(
                listenWhen: (previous, current) =>
                    previous.valid != current.valid,
                listener: (context, state) {
                  onValidChange?.call(form);
                },
              ),
              BlocListener<T, FormCubitState>(
                listenWhen: (previous, current) =>
                    current is FormCubitSuccessState,
                listener: (context, state) {
                  onSubmissionSuccess?.call(form);
                },
              ),
              BlocListener<T, FormCubitState>(
                listenWhen: (previous, current) =>
                    current is FormCubitFailedState,
                listener: (context, state) {
                  onSubmissionFailed?.call(form);
                },
              ),
            ],
            child: Builder(builder: (context) => builder(context, form)),
          );
        },
      ),
    );
  }
}
