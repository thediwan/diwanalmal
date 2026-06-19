import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/extensions/context_l10n.dart';
import '../../../core/helpers/currency_formatter.dart';
import '../../../core/theme/app_form_fields.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/currency.dart';
import '../../../providers/currency_provider.dart';
import '../../../core/extensions/context_feedback.dart';

/// Form to add or edit a non-base currency with exchange rate.
class CurrencyFormScreen extends StatefulWidget {
  const CurrencyFormScreen({super.key, this.currencyId});

  final String? currencyId;

  bool get isEditing => currencyId != null;

  @override
  State<CurrencyFormScreen> createState() => _CurrencyFormScreenState();
}

class _CurrencyFormScreenState extends State<CurrencyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _symbolController = TextEditingController();
  final _rateController = TextEditingController();

  String? _selectedPresetCode;
  bool _isSaving = false;
  Currency? _existingCurrency;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadCurrency());
    }
  }

  void _loadCurrency() {
    final currency = context.read<CurrencyProvider>().currencies
        .where((c) => c.id == widget.currencyId)
        .firstOrNull;

    if (currency == null) return;

    _existingCurrency = currency;
    _codeController.text = currency.code;
    _nameController.text = currency.name;
    _symbolController.text = currency.symbol;
    _rateController.text =
        CurrencyFormatter.formatExchangeRate(
          CurrencyFormatter.displayRateFromStored(currency.rateToBase),
        );
    setState(() {});
  }

  void _applyPreset(String code) {
    Map<String, String>? preset;
    for (final item in AppConstants.presetCurrencies) {
      if (item['code'] == code) {
        preset = item;
        break;
      }
    }

    if (preset == null) return;

    _codeController.text = preset['code']!;
    _nameController.text = preset['name']!;
    _symbolController.text = preset['symbol']!;
    setState(() => _selectedPresetCode = code);
  }

  double? get _previewBaseAmount {
    final displayRate = double.tryParse(_rateController.text);
    if (displayRate == null || displayRate <= 0) return null;
    final rateToBase = CurrencyFormatter.storedRateFromDisplay(displayRate);
    return CurrencyFormatter.toBaseAmount(100, rateToBase);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = context.l10n;
    setState(() => _isSaving = true);

    try {
      final provider = context.read<CurrencyProvider>();
      final displayRate = double.parse(_rateController.text);
      final rateToBase = CurrencyFormatter.storedRateFromDisplay(displayRate);

      if (widget.isEditing && _existingCurrency != null) {
        await provider.updateCurrency(
          _existingCurrency!.copyWith(
            name: _nameController.text.trim(),
            symbol: _symbolController.text.trim(),
            rateToBase: rateToBase,
          ),
        );
      } else {
        await provider.addCurrency(
          code: _codeController.text.trim(),
          name: _nameController.text.trim(),
          symbol: _symbolController.text.trim(),
          rateToBase: rateToBase,
        );
      }

      if (mounted) {
        context.showSuccessFeedback(l10n.currencyFormSaveSuccess);
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        context.showOperationError(e, currencyContext: true);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _symbolController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final baseCurrency = context.watch<CurrencyProvider>().baseCurrency;
    final baseCode = baseCurrency?.code ?? 'USD';
    final preview = _previewBaseAmount;
    final codeDisplay =
        _codeController.text.isEmpty ? 'XXX' : _codeController.text;
    final inputStyle = AppFormFields.inputTextStyleOf(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing ? l10n.currencyFormEditTitle : l10n.currencyFormNewTitle,
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (!widget.isEditing) ...[
              Text(l10n.currencyFormPresetHint, style: AppTextStyles.label),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppConstants.presetCurrencies
                    .where((c) => c['code'] != baseCode)
                    .map((preset) {
                  final code = preset['code']!;
                  return FilterChip(
                    label: Text(code),
                    selected: _selectedPresetCode == code,
                    onSelected: (_) => _applyPreset(code),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],
            TextFormField(
              controller: _codeController,
              style: inputStyle,
              decoration: AppFormFields.decoration(
                context,
                labelText: l10n.currencyFormCodeLabel,
                hintText: l10n.currencyFormCodeHint,
              ),
              textCapitalization: TextCapitalization.characters,
              enabled: !widget.isEditing,
              validator: (v) {
                if (v == null || v.trim().length < 2) {
                  return l10n.currencyFormInvalidCode;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              style: inputStyle,
              decoration: AppFormFields.decoration(
                context,
                labelText: l10n.currencyFormNameLabel,
                hintText: l10n.currencyFormNameHint,
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? l10n.authNameRequired : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _symbolController,
              style: inputStyle,
              decoration: AppFormFields.decoration(
                context,
                labelText: l10n.currencyFormSymbolLabel,
                hintText: l10n.currencyFormSymbolHint,
              ),
              validator: (v) => v == null || v.trim().isEmpty
                  ? l10n.currencyFormSymbolRequired
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _rateController,
              style: inputStyle,
              decoration: AppFormFields.decoration(
                context,
                labelText: l10n.currencyFormRateLabel(baseCode),
                hintText: l10n.currencyFormRateHint,
              ).copyWith(
                helperText: l10n.currencyFormRateHelper(baseCode, codeDisplay),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              onChanged: (_) => setState(() {}),
              validator: (v) {
                if (v == null || v.isEmpty) return l10n.currencyFormRateRequired;
                final rate = double.tryParse(v);
                if (rate == null || rate <= 0) {
                  return l10n.currencyFormPositiveNumber;
                }
                return null;
              },
            ),
            if (preview != null) ...[
              const SizedBox(height: 16),
              Card(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withValues(alpha: 0.3),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.currencyFormPreview(
                            codeDisplay,
                            CurrencyFormatter.approximateBase(
                              100,
                              CurrencyFormatter.storedRateFromDisplay(
                                double.parse(_rateController.text),
                              ),
                              baseCode,
                            ),
                          ),
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      widget.isEditing
                          ? l10n.currencyFormSave
                          : l10n.currencyFormAdd,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) return iterator.current;
    return null;
  }
}
