import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_form/live_form.dart';

void main() {
  group('LiveDropdownButtonFormField', () {
    test('asserts when T is non-nullable but an item has a null value', () {
      expect(
        () {
          LiveDropdownButtonFormField<int>(
            control: SelectionFormControl(initialValue: 1),
            items: const [
              DropdownMenuItem(value: 1, child: Text('one')),
              DropdownMenuItem(value: null, child: Text('two')),
              DropdownMenuItem(value: 3, child: Text('three')),
            ],
          );
        },
        throwsAssertionError,
      );
    });

    testWidgets('shows initial value', (tester) async {
      final control = SelectionFormControl<int>(initialValue: 1);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LiveDropdownButtonFormField<int>(
              control: control,
              items: const [
                DropdownMenuItem(value: 1, child: Text('one')),
                DropdownMenuItem(value: 2, child: Text('twoooo')),
                DropdownMenuItem(value: 3, child: Text('threeeeeee')),
              ],
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(LiveDropdownButtonFormField<int>),
        matchesGoldenFile(
            'goldens/live_dropdown_button_form_field_initial.png'),
      );
    });

    testWidgets('updates when control value changes', (tester) async {
      final control = SelectionFormControl<int>(initialValue: 1);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LiveDropdownButtonFormField<int>(
              control: control,
              items: const [
                DropdownMenuItem(value: 1, child: Text('one')),
                DropdownMenuItem(value: 2, child: Text('twoooo')),
                DropdownMenuItem(value: 3, child: Text('threeeeeee')),
              ],
            ),
          ),
        ),
      );

      control.update(3);
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(LiveDropdownButtonFormField<int>),
        matchesGoldenFile(
            'goldens/live_dropdown_button_form_field_selection.png'),
      );
    });

    testWidgets('updates control value', (tester) async {
      final control = SelectionFormControl<int>(initialValue: 1);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LiveDropdownButtonFormField<int>(
              control: control,
              items: const [
                DropdownMenuItem(value: 1, child: Text('one')),
                DropdownMenuItem(value: 2, child: Text('twoooo')),
                DropdownMenuItem(value: 3, child: Text('threeeeeee')),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.byType(DropdownButton<int>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('threeeeeee').last);
      await tester.pumpAndSettle();

      expect(control.value, 3);
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
                LiveDropdownButtonFormField<int?>(
                  control: form.selectControl,
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('one')),
                    DropdownMenuItem(value: 2, child: Text('twoooo')),
                    DropdownMenuItem(value: 3, child: Text('threeeeeee')),
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

  testWidgets('can focus and touch', (tester) async {
    final control = SelectionFormControl(initialValue: 'one');
    const field = ValueKey('field');
    const other = ValueKey('other');

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            LiveDropdownButtonFormField<String>(
              key: field,
              control: control,
              items: const [
                DropdownMenuItem(value: 'one', child: Text('one')),
                DropdownMenuItem(value: 'two', child: Text('twoooo')),
                DropdownMenuItem(value: 'three', child: Text('threeeeeee')),
              ],
            ),
            const TextField(key: other),
          ],
        ),
      ),
    ));

    expect(control.focused, false);

    await tester.tap(find.byKey(field));
    await tester.pumpAndSettle();
    // on tap it gains and then loses focus when the dropdown opens
    await tester.tap(find.text('threeeeeee').last);
    await tester.pumpAndSettle();
    // remains focused after selecting an option
    expect(control.focused, true);

    await tester.tap(find.byKey(other));
    await tester.pumpAndSettle();

    expect(control.focused, false);
    expect(control.touched, true);
  });

  testWidgets('can swap focus nodes', (tester) async {
    final control = SelectionFormControl(initialValue: 'one');
    final focusNode = FocusNode();
    final value = ValueNotifier<FocusNode?>(null);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ValueListenableBuilder(
          valueListenable: value,
          builder: (context, focusNode, __) {
            return LiveDropdownButtonFormField(
              control: control,
              focusNode: focusNode,
              items: const [
                DropdownMenuItem(value: 'one', child: Text('one')),
                DropdownMenuItem(value: 'three', child: Text('three')),
              ],
            );
          },
        ),
      ),
    ));

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('three').last);
    await tester.pumpAndSettle();
    expect(focusNode.hasFocus, false);

    value.value = focusNode;
    await tester.pump();
    expect(focusNode.hasFocus, false);
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('one').last);
    await tester.pumpAndSettle();
    expect(focusNode.hasFocus, true);
  });
}

class TestFormCubit extends FormCubit {
  final selectControl = SelectionFormControl<int?>(
    initialValue: null,
    validators: [(value) => value != 1 ? 'error' : null],
  );

  @override
  List<FormControl> get controls => [selectControl];
}
