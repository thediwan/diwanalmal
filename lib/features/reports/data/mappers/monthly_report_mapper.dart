import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../core/constants/report_constants.dart';
import '../../../../database/lazarus_database.dart';
import '../../domain/entities/report_entities.dart';

/// Maps Drift rows ↔ domain report models.
class MonthlyReportMapper {
  static MonthlyReportSnapshot fromRow(MonthlyReportRow row) {
    final payload = _parsePayload(row.snapshotJson);
    return MonthlyReportSnapshot(
      id: row.id,
      year: row.year,
      month: row.month,
      status: MonthlyReportStatus.fromDb(row.status),
      baseCurrencyCode: row.baseCurrencyCode,
      totalIncome: row.totalIncome,
      totalExpense: row.totalExpense,
      surplus: row.surplus,
      totalGoalSavings: row.totalGoalSavings,
      savingsRate: row.savingsRate,
      previousCarryoverIn: row.previousCarryoverIn,
      availableSurplus: row.availableSurplus,
      incomeChangePct: row.incomeChangePct,
      expenseChangePct: row.expenseChangePct,
      savingsChangePct: row.savingsChangePct,
      surplusAction: SurplusAction.fromDb(row.surplusAction),
      allocatedAmount: row.allocatedAmount,
      goalId: row.goalId,
      carriedForwardAmount: row.carriedForwardAmount,
      generatedAt: row.generatedAt,
      finalizedAt: row.finalizedAt,
      expenseBreakdown: payload.expenseBreakdown,
      incomeBreakdown: payload.incomeBreakdown,
      budgetPerformance: payload.budgetPerformance,
      goalProgress: payload.goalProgress,
      trendPoints: payload.trendPoints,
      insights: payload.insights,
    );
  }

  static MonthlyReportsCompanion toCompanion(MonthlyReportSnapshot snapshot) {
    final now = DateTime.now();
    return MonthlyReportsCompanion(
      id: Value(snapshot.id),
      userId: const Value.absent(),
      year: Value(snapshot.year),
      month: Value(snapshot.month),
      status: Value(snapshot.status.toDb()),
      baseCurrencyCode: Value(snapshot.baseCurrencyCode),
      totalIncome: Value(snapshot.totalIncome),
      totalExpense: Value(snapshot.totalExpense),
      surplus: Value(snapshot.surplus),
      totalGoalSavings: Value(snapshot.totalGoalSavings),
      savingsRate: Value(snapshot.savingsRate),
      previousCarryoverIn: Value(snapshot.previousCarryoverIn),
      availableSurplus: Value(snapshot.availableSurplus),
      incomeChangePct: Value(snapshot.incomeChangePct),
      expenseChangePct: Value(snapshot.expenseChangePct),
      savingsChangePct: Value(snapshot.savingsChangePct),
      surplusAction: Value(snapshot.surplusAction.toDb()),
      allocatedAmount: Value(snapshot.allocatedAmount),
      goalId: Value(snapshot.goalId),
      carriedForwardAmount: Value(snapshot.carriedForwardAmount),
      snapshotJson: Value(_encodePayload(snapshot)),
      generatedAt: Value(snapshot.generatedAt),
      finalizedAt: Value(snapshot.finalizedAt),
      createdAt: Value(now),
      updatedAt: Value(now),
    );
  }

  static MonthlyReportsCompanion toCompanionWithUser({
    required MonthlyReportSnapshot snapshot,
    required String userId,
    DateTime? createdAt,
  }) {
    final now = DateTime.now();
    return MonthlyReportsCompanion(
      id: Value(snapshot.id),
      userId: Value(userId),
      year: Value(snapshot.year),
      month: Value(snapshot.month),
      status: Value(snapshot.status.toDb()),
      baseCurrencyCode: Value(snapshot.baseCurrencyCode),
      totalIncome: Value(snapshot.totalIncome),
      totalExpense: Value(snapshot.totalExpense),
      surplus: Value(snapshot.surplus),
      totalGoalSavings: Value(snapshot.totalGoalSavings),
      savingsRate: Value(snapshot.savingsRate),
      previousCarryoverIn: Value(snapshot.previousCarryoverIn),
      availableSurplus: Value(snapshot.availableSurplus),
      incomeChangePct: Value(snapshot.incomeChangePct),
      expenseChangePct: Value(snapshot.expenseChangePct),
      savingsChangePct: Value(snapshot.savingsChangePct),
      surplusAction: Value(snapshot.surplusAction.toDb()),
      allocatedAmount: Value(snapshot.allocatedAmount),
      goalId: Value(snapshot.goalId),
      carriedForwardAmount: Value(snapshot.carriedForwardAmount),
      snapshotJson: Value(_encodePayload(snapshot)),
      generatedAt: Value(snapshot.generatedAt),
      finalizedAt: Value(snapshot.finalizedAt),
      createdAt: Value(createdAt ?? now),
      updatedAt: Value(now),
    );
  }

  static String _encodePayload(MonthlyReportSnapshot snapshot) {
    return jsonEncode(
      ReportSnapshotPayload(
        expenseBreakdown: snapshot.expenseBreakdown,
        incomeBreakdown: snapshot.incomeBreakdown,
        budgetPerformance: snapshot.budgetPerformance,
        goalProgress: snapshot.goalProgress,
        trendPoints: snapshot.trendPoints,
        insights: snapshot.insights,
      ).toJson(),
    );
  }

  static ReportSnapshotPayload _parsePayload(String json) {
    if (json.trim().isEmpty) return const ReportSnapshotPayload();
    return ReportSnapshotPayload.fromJson(
      jsonDecode(json) as Map<String, dynamic>,
    );
  }

  static double? percentChange(double current, double previous) {
    if (previous.abs() < 0.000001) return null;
    return ((current - previous) / previous) * 100;
  }

  static String defaultSurplusActionForDb(SurplusAction action) {
    if (action == SurplusAction.pending) {
      return ReportConstants.surplusPending;
    }
    return action.toDb();
  }
}
