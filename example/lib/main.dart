import 'package:flutter/material.dart';
import 'package:live_form/live_form.dart';

void main() {
  runApp(const MyApp());
}

// Define a cubit which extends FormCubit
class MyFormCubit extends FormCubit {
  // Define final fields which are all the controls the form can have
  // Type safety is maintained!
  final username = TextFormControl(
    validators: [requiredString],
  );
  final password = TextFormControl(
    validators: [requiredString, minLengthString(5)],
  );
  late final confirmPassword = TextFormControl(
    dependent: [password],
    validators: [
      requiredString,
      (value) => value != password.value ? 'Passwords must match' : null
    ],
  );
  final radio = RadioFormControl<bool?>(
    initialValue: null,
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
  List<FormControl> get controls =>
      [username, password, confirmPassword, radio, age, fruit];

  // Optionally define a list of controls which are currently being validated. This *can* change
  // over the life of the cubit to deal with conditional fields. The ConditionalFormField widget
  // can show/hide sections of the widget tree based on these, or you can control that yourself.
  // If not overridden, this will default to the list defined by controls.
  @override
  List<FormControl> get validatedControls => [
        username,
        password,
        confirmPassword,
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Live form example',
      home: Scaffold(
        appBar: AppBar(title: const Text('Live form example')),
        body: Builder(builder: (context) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            // Provide MyFormCubit similar to a BlocProvider
            child: FormCubitProvider<MyFormCubit>(
              // Create the form cubit here with access to context for potential dependency injection
              create: (context) => MyFormCubit(),
              // Without the need for a BlocListener you can listen for validity changes of the entire form
              onValidChange: (form) => print('Form valid: ${form.valid}'),
              // A listener for successful form submission (all validating fields are valid and submit was called)
              onSubmissionSuccess: (form) {
                print(form.toJSON().toString());
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Form success!')),
                );
              },
              onSubmissionFailed: (form) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('There were errors'),
                        SnackBarAction(
                          label: 'View',
                          onPressed: () {
                            // This will cause the nearest scrollable to scroll the first error in the cubit's
                            // list of controls into view.
                            form.viewFirstError();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
              // The builder gives direct access to the form cubit without a context lookup.
              builder: (context, form) {
                return Column(
                  children: [
                    // Use the appropriate live_form widget wired to the associated control in form
                    // Likely you'll create wrapper widgets for these which include the appropriate config
                    // for your app's design.
                    LiveTextFormField(
                      control: form.username,
                      decoration: const InputDecoration(labelText: 'Username'),
                    ),
                    LiveTextFormField(
                      control: form.password,
                      decoration: const InputDecoration(labelText: 'Password'),
                    ),
                    LiveTextFormField(
                      control: form.confirmPassword,
                      decoration:
                          const InputDecoration(labelText: 'Confirm password'),
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
                    const SizedBox(height: 500),
                    ElevatedButton(
                      onPressed: form.submit,
                      child: const Text('submit'),
                    ),
                    ElevatedButton(
                      onPressed: form.reset,
                      child: const Text('reset'),
                    ),
                  ]
                      .expand((e) sync* {
                        yield const SizedBox(height: 20.0);
                        yield e;
                      })
                      .skip(1)
                      .toList(),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}
