import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_form/live_form.dart';

void main() {
  group('LiveRadioFormField', () {
    test('asserts when toggleable is true but T is non-nullable', () {
      expect(
        () {
          LiveRadioGroupFormField<int>(
            control: RadioFormControl(initialValue: 1),
            toggleable: true,
            items: const [
              LiveRadio(value: 1, title: Text('one')),
              LiveRadio(value: 2, title: Text('two')),
              LiveRadio(value: 3, title: Text('three')),
            ],
          );
        },
        throwsAssertionError,
      );
    });

    testWidgets('builds radio list tiles', (tester) async {
      final control = RadioFormControl<int?>(initialValue: null);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LiveRadioGroupFormField<int?>(
              control: control,
              items: const [
                LiveRadio(value: 1, title: Text('one')),
                LiveRadio(value: 2, title: Text('two')),
                LiveRadio(value: 3, title: Text('three')),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(RadioListTile<int?>), findsNWidgets(3));
    });

    testWidgets('updates control value', (tester) async {
      final control = RadioFormControl<int?>(initialValue: null);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LiveRadioGroupFormField<int?>(
              control: control,
              items: const [
                LiveRadio(value: 1, title: Text('one')),
                LiveRadio(value: 2, title: Text('two')),
                LiveRadio(value: 3, title: Text('three')),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text('two'));
      await tester.pump();

      expect(control.value, 2);
    });

    testWidgets('updates selection when control value changes', (tester) async {
      final control = RadioFormControl<int?>(initialValue: null);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LiveRadioGroupFormField<int?>(
              control: control,
              items: const [
                LiveRadio(value: 1, title: Text('one')),
                LiveRadio(value: 2, title: Text('two')),
                LiveRadio(value: 3, title: Text('three')),
              ],
            ),
          ),
        ),
      );

      control.update(2);
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(LiveRadioGroupFormField<int?>),
        matchesGoldenFile('goldens/live_radio_group_form_field_selected.png'),
      );
    });

    testWidgets('is scrolled to when isFirstError is set', (tester) async {
      final form = TestFormCubit();
      final scrollController = ScrollController();

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: [
                LiveRadioGroupFormField<int?>(
                  control: form.radioControl,
                  items: const [
                    LiveRadio(value: 1, title: Text('one')),
                    LiveRadio(value: 2, title: Text('two')),
                    LiveRadio(value: 3, title: Text('three')),
                  ],
                ),
                const SizedBox(height: 5000),
              ],
            ),
          ),
        ),
      ));

      expect(scrollController.offset, 0);

      scrollController.jumpTo(2000);
      await tester.pumpAndSettle();
      expect(scrollController.offset, 2000);

      form.viewFirstError();
      await tester.pumpAndSettle();

      expect(scrollController.offset, 0);

      scrollController.dispose();
    });
  });
}

class TestFormCubit extends FormCubit {
  final radioControl = RadioFormControl<int?>(
    initialValue: null,
    validators: [(value) => value != 1 ? 'error' : null],
  );

  @override
  List<FormControl> get controls => [radioControl];
}
