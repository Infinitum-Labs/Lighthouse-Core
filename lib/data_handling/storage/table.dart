part of core.data_handling.storage;

typedef FilterFn<T> = bool Function(T);

abstract class Table {
  final String name;
  final TableField<String> objectId = TableField('objectId');
  late Map<String, TableField> fields = {
    'objectId': objectId,
  };

  Table(this.name);

  Future<List<JSON>> recordsToJSON(List<int> indexes) async {
    final List<JSON> results = [];
    LoopUtils.iterateOver<int>(indexes, (int index) {
      LoopUtils.iterateOver<TableField>(fields.values, (TableField tf) {
        final JSON result = {};
        result[tf.propertyName] = tf.getCell(index);
        results.add(result);
      });
    });
    return results;
  }

  Future<void> insertRecords(
    List<JSON> data, {
    bool markAsCreation = true,
  }) async {
    LoopUtils.iterateOver<JSON>(data, (JSON json) {
      final Iterable<String> properties =
          json.keys.where((String key) => fields.keys.contains(key));
      int newIndex = -1;
      LoopUtils.iterateOver<String>(properties, (String property) {
        final TableField tf = fields[property]!;
        if (newIndex == -1) newIndex = tf.cells.length;
        final Object? value = json[property];
        if (value is JSON) {
          tf.cells.insert(newIndex, SubObject.fromJSON(value));
        } else if (TriageState.values.stringify().contains(value as String)) {
          tf.cells.insert(newIndex, TriageState.values.asEnum(value));
        } else if (ProjectType.values.stringify().contains(value)) {
          tf.cells.insert(newIndex, ProjectType.values.asEnum(value));
        } else if (IssueSeverity.values.stringify().contains(value)) {
          tf.cells.insert(newIndex, IssueSeverity.values.asEnum(value));
        } else {
          tf.cells.insert(newIndex, json[property]);
        }
      });
      if (markAsCreation) {
        Storage.workbench.tracker
            .markAsCreation(RTCreation(collection: name, data: json));
      }
    });
  }

  Future<void> moveRecordToBin(
    int index,
    String Function(JSON json) retrieveObjectTitle,
  ) async {
    final JSON data = (await recordsToJSON([index])).first;
    Storage.bin.insertRecords([
      {
        'objectId': data['objectId'],
        'objectTitle': retrieveObjectTitle(data),
        'objectData': data,
        'isDirty': true,
      }
    ]);
    deleteRecord(index);
  }

  Future<void> deleteRecord(int index) async {
    LoopUtils.iterateOver<TableField>(fields.values, (TableField tf) {
      tf.cells.removeAt(index);
    });
  }

  Future<List<int>> getIndexesWhere(TableQuery tableQuery) async {
    List<int> hitIndexes = [];
    final Iterable<TableField> targetedFields = fields.values.where(
      (TableField tf) => tableQuery.parameters.keys.contains(tf.propertyName),
    );
    for (int i = 0; i < targetedFields.length; i++) {
      final TableField<dynamic> thisField = targetedFields.elementAt(i);
      final List<int> hits = await thisField.queryCells(
          tableQuery.parameters[thisField.propertyName]!, hitIndexes);
      if (hits.isEmpty) {
        return [];
      } else {
        if (i == 0) {
          hitIndexes.addAll(hits);
        } else {
          hitIndexes.retainWhere((int hitIndex) => hits.contains(hitIndex));
        }
      }
    }
    return hitIndexes;
  }
}

class BinTable extends Table {
  final TableField<String> objectTitle = TableField('objectTitle');
  final TableField<JSON> objectData = TableField('objectData');

  BinTable() : super('bin') {
    fields.addAll({
      'objectTitle': objectTitle,
      'objectData': objectData,
    });
  }
}

class TableField<T> {
  final String propertyName;
  final List<T> cells = [];

  TableField(this.propertyName);

  void updateCell(int index, T Function(T) updatedData) {
    final T oldData = cells[index];
    cells[index] = updatedData(oldData);
  }

  List<T> getCells(List<int> indexes) {
    final List<T> cells = [];
    LoopUtils.iterateOver<int>(indexes, (int index) {
      cells.add(getCell(index));
    });
    return cells;
  }

  T getCell(int index) {
    return cells[index];
  }

  Future<List<int>> queryCells(
    List<FilterFn<T>> filters, [
    List<int> hitIndexes = const [],
  ]) async {
    final List<int> hits = [];
    final int filtersLength = filters.length;
    if (hitIndexes.isEmpty) {
      final int cellsLength = cells.length;
      for (int i = 0; i < cellsLength; i++) {
        bool hit = true;
        for (int j = 0; j < filtersLength; j++) {
          if (filters[j](cells[i]) == false) {
            hit = false;
            break;
          }
        }
        if (hit) hits.add(i);
      }
    } else {
      final List<T> selectedCells = [];
      LoopUtils.iterateOver<int>(hitIndexes, (int index) {
        selectedCells.add(cells[index]);
      });
      final int selectedCellsLength = selectedCells.length;
      for (int i = 0; i < selectedCellsLength; i++) {
        bool hit = true;
        for (int j = 0; j < filtersLength; j++) {
          if (filters[j](cells[i]) == false) {
            hit = false;
            break;
          }
        }
        if (hit) hits.add(i);
      }
    }
    return hits;
  }
}

class TableQuery {
  final Map<String, List<FilterFn>> parameters = {};
  final Table table;

  TableQuery(this.table);

  TableQuery.dirtyIndexes(this.table) {
    addFilter<bool>('isDirty', (bool value) => value);
  }

  void addFilter<T>(String fieldName, FilterFn<T> filter) {
    if (parameters.containsKey(fieldName)) {
      parameters[fieldName]!.add(filter as FilterFn);
    } else {
      parameters[fieldName] = [filter as FilterFn];
    }
  }
}
