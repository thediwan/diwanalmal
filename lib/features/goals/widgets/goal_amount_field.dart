import 'package:flutter/material.dart';

import '../../../core/extensions/context_theme.dart';
import '../../../core/theme/app_form_fields.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/currency.dart';

/// Amount input with a trailing currency dropdown (RTL-aware).
class GoalAmountField extends StatelessWidget {
  const GoalAmountField({
    super.key,
    required this.controller,
    required this.currencies,
    required this.selectedCurrencyId,
    required this.onCurrencyChanged,
    required this.validator,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final List<Currency> currencies;
  final String? selectedCurrencyId;
  final ValueChanged<String?> onCurrencyChanged;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final inputStyle = AppFormFields.inputTextStyleOf(context);
    final selected = currencies
        .where((c) => c.id == selectedCurrencyId)
        .firstOrNull;

    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: inputStyle,
      validator: validator,
      decoration: AppFormFields.decoration(
        context,
        hintText: '0.00',
        suffixIcon: suffixIcon,
        prefixIcon: currencies.isEmpty
            ? null
            : Padding(
                padding: const EdgeInsetsDirectional.only(start: 4),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selected?.id,
                    isDense: true,
                    dropdownColor: colors.dropdownBackground,
                    borderRadius: BorderRadius.circular(12),
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: colors.textSecondary,
                      size: 20,
                    ),
                    items: currencies
                        .map(
                          (currency) => DropdownMenuItem(
                            value: currency.id,
                            child: Text(
                              currency.symbol,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: colors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: onCurrencyChanged,
                  ),
                ),
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
