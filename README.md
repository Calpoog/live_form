# live_form

A Flutter + BLoC package for simply managing forms.

Keep your forms and business logic out of the UI with minimal boilerplate and maintain type safety. Use real-time, on-touched, or customized validation logic for when errors are presented. Scroll your users to their first error for best UX. `live_form` makes managing forms a breeze.

### Motivation

Form inputs have state. Forms as a whole have state as well. Defining these inputs and hooking them up to UI shouldn't require unique wrapper widgets and repeated code. `live_form` attempts to solve this problem by using the BLoC pattern for controlling inputs, their parent form, and reusable widgets which only need a control reference.

- [live\_form](#live_form)
    - [Motivation](#motivation)
  - [Installation](#installation)
  - [Define a form](#define-a-form)
  - [Providing a form](#providing-a-form)
    - [Providing](#providing)
    - [Callbacks](#callbacks)
    - [UI](#ui)
    - [Showing the first error](#showing-the-first-error)
  - [Controls](#controls)
    - [State](#state)
    - [Definition](#definition)
    - [Validation](#validation)
  - [Dynamic forms](#dynamic-forms)
  - [Error behavior](#error-behavior)
  - [Make your own widgets](#make-your-own-widgets)
  - [Roadmap](#roadmap)


## Installation

Add `live_form` to your list of package dependencies in `pubspec.yaml`

```dart
dependencies:
  live_form: ^0.0.1
```

## Define a form

Forms in `live_form` are just specialized cubits from the `flutter_bloc` package. All you need to do is extend the `FormCubit` class and define your form input controls.

```dart
// Define a cubit which extends FormCubit
class MyFormCubit extends FormCubit {
  // Define final fields which are all the controls the form can have
  final username = TextFormControl(
    initialValue: '',
    validators: [requiredString],
  );
  final password = TextFormControl(
    initialValue: 'password',
    validators: [requiredString, minLengthString(5)],
  );
  final radio = RadioFormControl<bool?>(
    validators: [requiredField],
  );
  final fruit = SelectionFormControl<String>(
    initialValue: 'Banana',
  );
  final age = NumberFormControl(
    validators: [requiredField],
  );

  // Define a list of all fields defined above.
  @override
  List<FormControl> get controls => [username, password, radio, age, fruit];

  // Optionally define a list of controls which are currently being validated. This *can* change
  // over the life of the cubit to deal with conditional fields. The ConditionalFormField widget
  // can show/hide sections of the widget tree based on these, or you can control that yourself.
  // If not overridden, this will default to the list defined by controls.
  @override
  List<FormControl> get validatedControls => [
        username,
        password,
        radio,
        // Use collection ifs to optionally validate particular fields depending on others
        if (radio.value == true) age,
        fruit,
      ];

  // It may be useful to turn your form into JSON or some other model for use with APIs
  Map<String, dynamic> toJSON() {
    return {
      'username': username.value,
      'password': password.value,
      'radio': radio.value,
      'age': age.value,
      'fruit': fruit.value,
    };
  }
}
```

Notice how all the form's fields are represented within the cubit. They are explicit in their definition of type, value, and validation. This makes managing form logic incredibly simple and independent of the widget tree. See more about controls in TODO.

The `controls` getter override specifies all the form's controls. This allows the cubit to set up listeners to each control and re-evaluate its overall validity as fields are modified.

The `validatedControls` getter override independently specifies which of the form's controls are *currently* being validated. This allows for the possibility of switching up the form's validity at runtime depending on outside factors. The form's `valid` property will reflect the total validity of the controls in this list. Later you'll see how you can use the `ConditionalFormField` widget to show/hide sections of the widget tree with respect to the `validatedControls` list. If not overridden it defaults to using the entire `controls` list.

As an illustration, a `toJSON` method was added. Any amount of extra cubit functionality can be used. Minimally, a `FormCubit` only needs `controls` (and ideally some final fields used in that list).

## Providing a form
Now that we have a form defined, we provide it to our widget tree and build the UI.

```dart
// Provide our MyFormCubit
FormCubitProvider<MyFormCubit>(
  // Create the form cubit here with access to context for potential dependency injection
  create: (context) => MyFormCubit(),
  // Without the need for a BlocListener you can listen for validity changes of the entire form
  onValidChange: (form) => print('Form valid: ${form.valid}'),
  // A listener for successful form submission (all validating fields are valid and submit was called)
  onSubmissionSuccess: (form) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Form success!')),
    );
  },
  // A listener for a failed form submission (at least one validating field was invalid)
  onSubmissionFailed: (form) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Form failed :(')),
    );
  },
  // The builder gives direct access to the form cubit without a context lookup.
  builder: (context, form) {
    return Column(
      children: [
        // Use the appropriate live_form widget wired to the associated control in form
        // Likely you'll create wrapper widgets for these which include the appropriate config for your app's design.
        LiveTextFormField(
          control: form.username,
          decoration: const InputDecoration(labelText: 'Username'),
        ),
        LiveTextFormField(
          control: form.password,
          decoration: const InputDecoration(labelText: 'Password'),
        ),
        LiveRadioGroupFormField(
          control: form.radio,
          toggleable: true,
          items: const [
            LiveRadio(value: true, title: Text('Yes')),
            LiveRadio(value: false, title: Text('No')),
          ],
        ),
        ConditionalFormField<MyFormCubit>(
          control: form.age,
          child: LiveNumberFormField(
            control: form.age,
            decoration: const InputDecoration(labelText: 'Age'),
          ),
        ),
        LiveDropdownButtonFormField(
          control: form.fruit,
          items: const [
            DropdownMenuItem(
              value: 'Apple',
              child: Text('Apple'),
            ),
            DropdownMenuItem(
              value: 'Banana',
              child: Text('Banana'),
            ),
            DropdownMenuItem(
              value: 'Orange',
              child: Text('Orange'),
            ),
          ],
        ),
        ElevatedButton(
          onPressed: form.submit,
          child: const Text('submit'),
        ),
      ],
    );
  },
),
```

**There's a lot going on here, but it's not that complicated once we break it down.**

### Providing
First, we provide the `MyFormCubit` much like providing any other BLoC using `FormCubitProvider`. It takes a `create` function where we instantiate our cubit, with access to context in case it needs to do any lookups and pass values into its constructor. Unlike a `BlocProvider`, the `FormCubitProvider` has a `builder` function which builds the child tree of widgets. In addition to providing a new `context` (handy so you don't need a `Builder` as the first child of a provider), it provides a reference to the form cubit itself as `form`. This gives easy access to the controls it holds that we use with the field widgets.

**Important note:** The `builder` does not rebuild when the form changes. You can use the following callbacks to respond to changes, or a `BlocBuilder` if needed.

### Callbacks

- `onValidityChange` is called any time the total validity of the form changes and is passed a reference to the form cubit. The validity can be checked with `form.valid`
- `onSubmissionFailed` is called when the form cubit's `submit()` method is attempted but it is not valid.
- `onSubmissionSuccess` is called when the form cubit's `submit()` method is attempted and the form is valid.

In our case these methods do some simple printing and SnackBars, but in reality would likely have more complex logic like showing an error modal, hitting an API, or proceeding to the next page of the app.

### UI

`live_form` provides common form field widgets which are ready to hook up to our defined controls. They are default Material inputs and take all the same parameters (minus those that `live_form` needs to make things work) for full customization. You can wrap these widgets with your own to simplify and style them appropriately for your app, or you can build your own entirely as described in [making your own widgets](#make-your-own-widgets).

Each `live_form` field widget has a `control` property which links it to the control defined in our form cubit. They take a specific kind of control depending on the widget and it fully handles updating the control/widget's value bi-directionally and showing validation errors according to our form's configuration.

The button at the end simply calls the form cubit's `submit` function when it is pressed. This will mark all controls as `dirty` and `touched` and emit a new state, triggering either `onSubmissionSuccess` or `onSubmissionFailed` depending on validity.

### Showing the first error
No matter the methodology used to show errors, it's possible for users to leave errors on the page and try to submit. Your practice may be to disable the ability to proceed. A better UX practice is to allow the user to see their mistakes when attempting to proceed while in an invalid form state.

`FormCubit`s, and your form cubits by extension, can call `viewFirstError()` and the first error (as defined in the `controls` list) in your form will be scrolled into view. Some ways to handle this may be to call the method in the `onSubmissionFailed` callback, or present a `SnackBar` in the callback and an action the user can tap.

## Controls

The above is all the code you'd need to set up and manage a form. But to build the *right* form you'll need to understand the controls available and how they work.

### State

Controls have the following important state properties:
- `value`: the current value of the control
- `pure`: whether the user has changed the control's value. If not changed from its initial value, a control is considered "pure" and this property will be `true`. If the user has modified the value this property will be `false` and the control considered "dirty".
- `focused`: whether the associated input has focus.
- `touched`: whether the user has interacted with the control. This differs depending on the type of control. Some controls are focusable (like text inputs) and once they have been focused and then unfocused, it becomes "touched" and this property will be `true`. Controls like radios and checkboxes can't be focused without changing their values (unless using accessibility features) and those will be marked "dirty" and "touched" simultaneously when tapped.
- `valid`: `true` if all validators return null (or there are none), `false` otherwise.
- `error`: A `String` error if the field is not valid, `null` otherwise.
- `submitted`: `true` when the form has attempted submit, and remains this way.
- `isFirstError`: `true` when a `submit()` is attempted and this control has an error and is the first error in the list of `controls`. This is important for scrolling to the first error.

These properties are all getters on the control itself which access an immutable state. They cannot be modified directly, but are important to understand how the system works.

### Definition
As we saw above, the controls are created as `final` fields in our form's cubit. There are different types of controls depending on our intent and the widget used to represent them.

`live_form` provides these variations:
- `TextFormControl`: A focusable control which has a `String` value. Used with `LiveTextFormField` widget as a Material text input.
- `NumberFormControl`: A focusable control which has an `int` value. Used with `LiveNumberFormField` widget as a Material text input set to accept only integers.
- `RadioFormControl<T>`: A non-focusable control which is generic and can hold any type. Used with `LiveRadioGroupFormField` widget with `LiveRadio` as its items.
- `SelectionFormControl<T>`: A focusable control which is a generic and can hold any type. Used with `LiveDropdownButtonFormField` widget.

All of these controls take an `initialValue` matching its type. They also take a list of `validators` for checking its value and returning `String` errors.

### Validation
The `validators` list passed to a control determines its validity (and indirectly the parent form's validity). Any time the value changes the validators will be run in sequence and `error` will be set according to *the first validator* which returns a `String` error. If all validators return `null` then the control is valid. Order your validators based on how you want errors to appear. For instance, a required field with a minimum length should show "Required" when empty and "Too short" when filled less than 5 by putting its validators in that order.

There is a `Validator` typedef, and any function following this signature can be provided to the `validators` list.
```dart
typedef Validator<T> = String? Function(T value);
```
`live_form` provides some common validators out of the box like `requiredString`, `requiredField`, `minLengthString(int)`. Check `validators.dart` to see them all. For best UX, consider using `inputFormatters` to whitelist/blacklist/mask fields instead of allowing users to enter things incorrectly and be presented with an error.

## Dynamic forms
Sometimes forms have fields which are dynamic. They may appear or disappear depending on some condition (usually the value of some other form field). This means two things: We must remove the UI widget *and* not validate the field in the form. Luckily, this is super simple!

In our form cubit definition we can override the `validatedControls` getter:
```dart
@override
List<FormControl> get validatedControls => [
  username,
  password,
  radio,
  // Use collection ifs to optionally validate particular fields depending on others
  if (radio.value == true) age,
  fruit,
];
```

Now if the value of the `radio` control is `false`, the `age` field will not be included in validation. This is useful even when the excluded field has no validators because of the `ConditionalFormField` widget.

```dart
ConditionalFormField<MyFormCubit>(
  control: form.age,
  child: LiveNumberFormField(
    control: form.age,
    decoration: const InputDecoration(labelText: 'Age'),
  ),
),
```

Here we use a `ConditionalFormField` widget with the generic type of our form cubit (so it knows where to look and listen in order to rebuild). This widget will watch the given `control` and whether it appears in the `validatedControls` list of our form. If it does not, the `child` subtree will be removed. We can think of `validatedControls` as "*the controls our form currently cares about*" – not all of them may have validation, but it simplifies both validation and dynamic controls.

## Error behavior
You can customize the behavior when errors appear in the UI. Use the `LiveForm` singleton to set the behavior for your entire app. Usually this would mean consistent behavior by setting it in your `main()` function, but you can update at any time. Fields will not react to changes until they've been interacted with in some way.

```dart
LiveForm().setErrorBehavior(ErrorBehavior.onChange);
```

The following `ErrorBehavior`s are available (all require the control to be `invalid`)
- `onChange`: An error will show when the field is `dirty`. This is considered real-time validation.
- `onSubmit`: An error will show when the field is `submitted`. This happens after calling `submit()` on the parent `FormCubit`. Once submitted, errors will be real-time and show/change/hide as the user interacts.
- `onTouched`: An error will show when the field is `touched`. This is after the field has been unfocused the first time. Once touched, errors will be real-time and show/change/hide as the user interacts.
- `onFinished`: An error will show when the field is `dirty` and `touched`. This is after the field has been unfocused the first time AND the user has modified the value. Once touched and dirty, errors will be real-time and show/change/hide as the user interacts.

Notice how in each case, once an error has appeared for the first time, they are real-time afterwards. This is always the best user experience as it allows them to see once they've corrected their mistake. The different behaviors essentially offer different levels of intrusiveness as the user makes modifications.

If for some reason the above behaviors don't work for your application, you can customize the behavior with your own function. The function gets a reference to a control's state and returns a boolean which determines whether or not to show the error. You do not need to check `state.invalid` as this is always a prerequisite for an error to be shown.

```dart
LifeFormConfig().setCustomErrorBehavior((FormControlState state) {
  return // do something weird
});
```

## Make your own widgets
If you need more than the widgets provided by `live_form`, can't wrap those widgets, or have fields not based on Material, you have the ability to create your own. This is a simple exercise when adhering to the following pattern.

```dart
// Declared in a final field
final TextFormControl control;

// Constructor should have a required `control` parameter

@override
Widget build(BuildContext context) {
  return BlocConsumer<TextFormControl, FormControlState<String>>(
    bloc: control,
    listenWhen: (previous, current) => current.isFirstError,
    listener: (context, state) {
      Scrollable.ensureVisible(context,
          duration: const Duration(milliseconds: 300));
    },
    builder: (context, state) {
      return MyDifferentFieldWidget(
        onChanged: (value) => control.update(value),
        errorText: LiveForm().shouldShowError(state) ? state.error : null,
      );
    },
  );
}
```

Our custom field widget takes a `control` of whichever type best suits the values it produces. In this case it is a `TextFormControl`. A `BlocConsumer` is used to listen and rebuild when the `control` changes. If we want the control to have the ability to be scrolled to when it's the first error in the form, we use a `listenWhen` and `listener` to do so. In the `builder` is where our wrapped widget belongs. Here you have the freedom to hook into its values changing to `update` the `control` and show its errors.

While it is not shown, we can manage whether it is `touched` and `focused` too. Also not shown are bi-directional updates (so the control can be updated programmatically and the widget reflects the change). You may need a `StatefulWidget` and to manage a controller or `FocusNode`. For these more complicated examples, see how `LiveTextFormField`, `LiveDropdownButtonFormField`, and `LiveRadioGroupFormField` are built in `lib/src/widgets`.

## Roadmap
