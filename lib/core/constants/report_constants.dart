/// Monthly report status and surplus disposition values stored in SQLite.
abstract final class ReportConstants {
  static const String statusDraft = 'draft';
  static const String statusFinalized = 'finalized';

  static const String surplusPending = 'pending';
  static const String surplusCarryForward = 'carry_forward';
  static const String surplusAllocateGoal = 'allocate_goal';
  static const String surplusPartial = 'partial';

  static const String workmanagerTaskName = 'dewanalmal_monthly_report';
}
