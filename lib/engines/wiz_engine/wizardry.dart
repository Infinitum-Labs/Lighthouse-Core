part of core.engines.wiz_engine;

class Wizardry {
  /// https://www.notion.so/infinitum-lighthouse/Wizardry-8fa434e4679c42f5ad0a00f0fd83d51c#452029e412044aabb301a0ffd9048269
  static Future<List<WizardryRecommendation>> suggestNextActions(
      WizardryConfigs configs) async {
    final List<WizardryRecommendation> nextActions = [];
    final DateTime currentTime = DateTime.now().add(const Duration(minutes: 5));
    final List<int> currentEventIndexes = await Storage.events.getIndexesWhere(
      TableQuery(Storage.events)
        ..addFilter(
          'startDate',
          (DateTime dt) => dt.isBefore(currentTime),
        )
        ..addFilter(
          'endDate',
          (DateTime dt) => dt.isAfter(currentTime),
        ),
    );
    final List<ObjectId> currentEventIds =
        Storage.events.objectId.getCells(currentEventIndexes);

    final List<int> currentScheduledTaskIndices =
        await Storage.tasks.getIndexesWhere(
      TableQuery(Storage.tasks)
        ..addFilter<ObjectId>(
          'event',
          (ObjectId id) => currentEventIds.contains(id),
        ),
    );

    if (currentScheduledTaskIndices.isNotEmpty) {
      LoopUtils.iterateOver<int>(currentScheduledTaskIndices, (int index) {
        nextActions.add(
          WizardryRecommendation.undertakeTask(
            Storage.tasks.objectId.getCell(index),
          ),
        );
      });
    }

    final int inboxCount = (await Storage.tasks.getIndexesWhere(
      TableQuery(Storage.tasks)
        ..addFilter<TriageState>(
            'triageState', (TriageState state) => state == TriageState.inbox),
    ))
        .length;
    if (inboxCount > configs.inboxLoadLimit) {
      nextActions.add(WizardryRecommendation.triageInbox());
    }

    final int triagedCount = (await Storage.tasks.getIndexesWhere(
      TableQuery(Storage.tasks)
        ..addFilter(
            'triageState', (TriageState state) => state == TriageState.triaged),
    ))
        .length;

    if (triagedCount > configs.triagedLoadLimit) {
      nextActions.add(WizardryRecommendation.scheduleTriaged());
    }

    /// Create methods in EventsTable to get working time in next week

    return nextActions;
  }

  static void autoschedulerSuggestions() {}
}

class WizardryRecommendation {
  final ObjectId? object;

  WizardryRecommendation.undertakeTask(this.object);
  WizardryRecommendation.triageInbox([this.object]);
  WizardryRecommendation.scheduleTriaged([this.object]);
  WizardryRecommendation.planEpic(this.object);
  WizardryRecommendation.planSprint(this.object);
  WizardryRecommendation.sysAdmin([this.object]);
}

class WizardryConfigs {
  /// turn into SubObject
  final int inboxLoadLimit;
  final int triagedLoadLimit;
  final Duration sprintPlanningWindow;

  WizardryConfigs({
    required this.inboxLoadLimit,
    required this.triagedLoadLimit,
    required this.sprintPlanningWindow,
  });
}
