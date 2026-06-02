import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/wallet.dart';
import '../../providers/currency_provider.dart';
import '../../providers/wallet_provider.dart';

/// Form to create or edit a wallet.
class WalletFormScreen extends StatefulWidget {
  const WalletFormScreen({super.key, this.walletId});

  final String? walletId;

  bool get isEditing => walletId != null;

  @override
  State<WalletFormScreen> createState() => _WalletFormScreenState();
}

class _WalletFormScreenState extends State<WalletFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController(text: '0');

  String? _selectedCurrencyCode;
  String _selectedIcon = '💵';
  bool _isSaving = false;
  Wallet? _existingWallet;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadWallet());
    }
  }

  void _loadWallet() {
    final wallet = context.read<WalletProvider>().wallets
        .where((w) => w.id == widget.walletId)
        .firstOrNull;

    if (wallet == null) return;

    _existingWallet = wallet;
    _nameController.text = wallet.name;
    _balanceController.text = wallet.initialBalance.toString();
    _selectedCurrencyCode = wallet.currencyCode;
    _selectedIcon = wallet.icon;
    setState(() {});
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCurrencyCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختر العملة')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final provider = context.read<WalletProvider>();
      final balance = double.parse(_balanceController.text);

      if (widget.isEditing && _existingWallet != null) {
        await provider.updateWallet(
          _existingWallet!.copyWith(
            name: _nameController.text.trim(),
            currencyCode: _selectedCurrencyCode!,
            initialBalance: balance,
            icon: _selectedIcon,
          ),
        );
      } else {
        await provider.createWallet(
          name: _nameController.text.trim(),
          currencyCode: _selectedCurrencyCode!,
          initialBalance: balance,
          icon: _selectedIcon,
        );
      }

      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المحفظة'),
        content: const Text('هل أنت متأكد؟ لا يمكن التراجع.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed != true || _existingWallet == null) return;

    await context.read<WalletProvider>().deleteWallet(_existingWallet!.id);
    if (mounted) context.pop();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencies = context.watch<CurrencyProvider>().currencies;

    if (_selectedCurrencyCode == null && currencies.isNotEmpty) {
      _selectedCurrencyCode = currencies.first.code;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'تعديل المحفظة' : 'محفظة جديدة'),
        actions: [
          if (widget.isEditing)
            IconButton(
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline, color: Colors.red),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'اسم المحفظة',
                hintText: 'مثال: كاش، بنك',
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'الاسم مطلوب' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCurrencyCode,
              decoration: const InputDecoration(labelText: 'العملة'),
              items: currencies
                  .map(
                    (c) => DropdownMenuItem(
                      value: c.code,
                      child: Text('${c.name} (${c.code})'),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _selectedCurrencyCode = v),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _balanceController,
              decoration: const InputDecoration(
                labelText: 'الرصيد الافتتاحي',
                hintText: '0',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              validator: (v) {
                if (v == null || v.isEmpty) return 'الرصيد مطلوب';
                if (double.tryParse(v) == null) return 'رقم غير صالح';
                return null;
              },
            ),
            const SizedBox(height: 24),
            Text('الأيقونة', style: AppTextStyles.label),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppConstants.walletIconOptions.map((option) {
                final icon = option['icon'] as String;
                final isSelected = _selectedIcon == icon;

                return ChoiceChip(
                  label: Text('${option['icon']} ${option['label']}'),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selectedIcon = icon),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(widget.isEditing ? 'حفظ' : 'إنشاء'),
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
