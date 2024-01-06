part of lh.core.db;

abstract class ComponentProvider {
  Widget textField(
    TextProperty property,
    void Function(String) editingCompleteCallback,
  );

  Widget numberField(
    NumProperty property,
    void Function(String) editingCompleteCallback,
  );

  Widget multiDropdown<T>(
    MultiSelectProperty<T> property,
    void Function(List<String>) selections,
  );

  Widget singleDropdown<T>(
    SingleSelectProperty<T> property,
    void Function(String) selection,
  );

  Widget datePicker(
    DateTimeProperty property,
    void Function(String) dtString,
  );

  Widget expandableSection(
    ExpandableProperty property,
    List<FormProperty> properties,
  );
}
