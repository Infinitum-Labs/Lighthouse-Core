part of lh.core.db;

abstract class ComponentProvider {
  Widget textField(
    void Function(String) editingCompleteCallback,
  );

  Widget numberField(
    void Function(String) editingCompleteCallback,
  );

  Widget multiDropdown<R>(void Function(R) selection);

  Widget singleDropdown<R>(void Function(R) selection);

  Widget datePicker(void Function(String) dtString);

  Widget expandableSection(List<FormProperty> properties);
}
