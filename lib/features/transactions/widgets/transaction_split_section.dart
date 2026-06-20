import 'package:flutter/material.dart';

import '../../../core/constants/split_constants.dart';
import '../../../core/extensions/context_l10n.dart';
import '../../../core/extensions/context_theme.dart';
import '../../../core/helpers/split_calculator.dart';
import '../../../core/theme/app_form_fields.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../services/transaction_split_service.dart';
import '../../contacts/widgets/person_picker_field.dart';

/// UI state for one split participant row.
class SplitParticipantRowState {
  SplitParticipantRowState({
    this.contactId,
    this.contactName,
    this.percent,
    this.fixedAmount,
  });

  String? contactId;
  String? contactName;
  double? percent;
  double? fixedAmount;

  SplitParticipantDraft toDraft() {
    return SplitParticipantDraft(
      contactId: contactId,
      contactName: contactName,
      percent: percent,
      fixedAmount: fixedAmount,
    );
  }
}

/// Split sharing controls for income/expense forms.
class TransactionSplitSection extends StatefulWidget {
  const TransactionSplitSection({
    super.key,
    required this.totalAmount,
    required this.currencyCode,
    required this.onChanged,
    this.initialEnabled = false,
    this.initialMode = SplitConstants.modeEqual,
    this.initialIncludeSelf = true,
    this.initialFixedAmountPerPerson,
    this.initialParticipants = const [],
  });

  final double totalAmount;
  final String currencyCode;
  final ValueChanged<({
    bool enabled,
    String mode,
    bool includeSelfInEqualSplit,
    double? fixedAmountPerPerson,
    List<SplitParticipantDraft> participants,
  })> onChanged;

  final bool initialEnabled;
  final String initialMode;
  final bool initialIncludeSelf;
  final double? initialFixedAmountPerPerson;
  final List<SplitParticipantRowState> initialParticipants;

  @override
  State<TransactionSplitSection> createState() =>
      _TransactionSplitSectionState();
}

class _TransactionSplitSectionState extends State<TransactionSplitSection> {
  late bool _enabled;
  late String _mode;
  late bool _includeSelf;
  late double? _fixedAmountPerPerson;
  late List<SplitParticipantRowState> _participants;
  final _fixedAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _enabled = widget.initialEnabled;
    _mode = widget.initialMode;
    _includeSelf = widget.initialIncludeSelf;
    _fixedAmountPerPerson = widget.initialFixedAmountPerPerson;
    _participants = widget.initialParticipants.isNotEmpty
        ? List.from(widget.initialParticipants)
        : [SplitParticipantRowState()];
    if (_fixedAmountPerPerson != null) {
      _fixedAmountController.text = _fixedAmountPerPerson.toString();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _notifyParent());
  }

  @override
  void didUpdateWidget(covariant TransactionSplitSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.totalAmount != widget.totalAmount) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _fixedAmountController.dispose();
    super.dispose();
  }

  void _notifyParent() {
    widget.onChanged((
      enabled: _enabled,
      mode: _mode,
      includeSelfInEqualSplit: _includeSelf,
      fixedAmountPerPerson: _fixedAmountPerPerson,
      participants: _participants.map((p) => p.toDraft()).toList(),
    ));
  }

  SplitCalculationResult? _preview() {
    if (!_enabled || widget.totalAmount <= 0) return null;

    final drafts = _participants
        .where((p) =>
            (p.contactId != null && p.contactId!.isNotEmpty) ||
            (p.contactName != null && p.contactName!.trim().isNotEmpty))
        .toList();
    if (drafts.isEmpty) return null;

    try {
      return SplitCalculator.calculate(
        totalAmount: widget.totalAmount,
        splitMode: _mode,
        participants: drafts
            .map(
              (p) => SplitParticipantInput(
                contactId: p.contactId ?? p.contactName!.trim(),
                percent: p.percent,
                fixedAmount: p.fixedAmount,
              ),
            )
            .toList(),
        includeSelfInEqualSplit: _includeSelf,
        fixedAmountPerPerson: _fixedAmountPerPerson,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;
    final preview = _preview();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            l10n.transactionSplitEnable,
            style: AppTextStyles.bodyMedium.copyWith(color: colors.textPrimary),
          ),
          value: _enabled,
          onChanged: (value) {
            setState(() => _enabled = value);
            _notifyParent();
          },
        ),
        if (_enabled) ...[
          const SizedBox(height: 8),
          Text(
            l10n.transactionSplitModeLabel,
            style: AppFormFields.sectionLabelStyleOf(context),
          ),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: [
              ButtonSegment(
                value: SplitConstants.modeEqual,
                label: Text(l10n.transactionSplitModeEqual),
              ),
              ButtonSegment(
                value: SplitConstants.modePercent,
                label: Text(l10n.transactionSplitModePercent),
              ),
              ButtonSegment(
                value: SplitConstants.modeFixedAmount,
                label: Text(l10n.transactionSplitModeFixed),
              ),
            ],
            selected: {_mode},
            onSelectionChanged: (selection) {
              setState(() => _mode = selection.first);
              _notifyParent();
            },
          ),
          if (_mode == SplitConstants.modeEqual) ...[
            const SizedBox(height: 12),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                l10n.transactionSplitIncludeSelf,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              value: _includeSelf,
              onChanged: (value) {
                setState(() => _includeSelf = value ?? true);
                _notifyParent();
              },
            ),
          ],
          if (_mode == SplitConstants.modeFixedAmount) ...[
            const SizedBox(height: 12),
            TextFormField(
              controller: _fixedAmountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: AppFormFields.inputTextStyleOf(context),
              decoration: AppFormFields.decoration(
                context,
                labelText: l10n.transactionSplitFixedAmountLabel,
                hintText: l10n.transactionFormAmountHint,
              ).copyWith(suffixText: widget.currencyCode),
              onChanged: (value) {
                _fixedAmountPerPerson = double.tryParse(value.replaceAll(',', '.'));
                _notifyParent();
                setState(() {});
              },
            ),
          ],
          const SizedBox(height: 16),
          for (var i = 0; i < _participants.length; i++) ...[
            _ParticipantRow(
              key: ValueKey('split-participant-$i'),
              index: i,
              mode: _mode,
              currencyCode: widget.currencyCode,
              row: _participants[i],
              onChanged: (row) {
                setState(() => _participants[i] = row);
                _notifyParent();
              },
              onRemove: _participants.length > 1
                  ? () {
                      setState(() => _participants.removeAt(i));
                      _notifyParent();
                    }
                  : null,
            ),
            const SizedBox(height: 12),
          ],
          OutlinedButton.icon(
            onPressed: () {
              setState(() => _participants.add(SplitParticipantRowState()));
              _notifyParent();
            },
            icon: const Icon(Icons.person_add_outlined),
            label: Text(l10n.transactionSplitAddParticipant),
          ),
          if (preview != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.accentSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.transactionSplitYourShare(
                      preview.userShareAmount.toStringAsFixed(2),
                      widget.currencyCode,
                    ),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (var i = 0; i < preview.participantShares.length; i++)
                    Text(
                      l10n.transactionSplitParticipantShare(
                        _participants[i].contactName ?? '',
                        preview.participantShares[i].shareAmount
                            .toStringAsFixed(2),
                        widget.currencyCode,
                      ),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
          ] else if (_enabled && widget.totalAmount > 0) ...[
            const SizedBox(height: 8),
            Text(
              l10n.transactionSplitPreviewUnavailable,
              style: AppTextStyles.captionOnSurface(colors),
            ),
          ],
        ],
      ],
    );
  }
}

class _ParticipantRow extends StatelessWidget {
  const _ParticipantRow({
    super.key,
    required this.index,
    required this.mode,
    required this.currencyCode,
    required this.row,
    required this.onChanged,
    this.onRemove,
  });

  final int index;
  final String mode;
  final String currencyCode;
  final SplitParticipantRowState row;
  final ValueChanged<SplitParticipantRowState> onChanged;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: PersonPickerField(
                initialSelection: PersonSelection(
                  contactId: row.contactId,
                  displayName: row.contactName ?? '',
                ),
                label: l10n.transactionSplitParticipantLabel(index + 1),
                onChanged: (selection) {
                  onChanged(SplitParticipantRowState(
                    contactId: selection.contactId,
                    contactName: selection.displayName,
                    percent: row.percent,
                    fixedAmount: row.fixedAmount,
                  ));
                },
              ),
            ),
            if (onRemove != null) ...[
              const SizedBox(width: 8),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.close),
              ),
            ],
          ],
        ),
        if (mode == SplitConstants.modePercent) ...[
          const SizedBox(height: 8),
          TextFormField(
            initialValue: row.percent?.toString() ?? '',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: AppFormFields.inputTextStyleOf(context),
            decoration: AppFormFields.decoration(
              context,
              labelText: l10n.transactionSplitPercentLabel,
              hintText: '0',
            ).copyWith(suffixText: '%'),
            onChanged: (value) {
              onChanged(SplitParticipantRowState(
                contactId: row.contactId,
                contactName: row.contactName,
                percent: double.tryParse(value.replaceAll(',', '.')),
                fixedAmount: row.fixedAmount,
              ));
            },
          ),
        ],
      ],
    );
  }
}
