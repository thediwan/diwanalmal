import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/category_icon_styles.dart';
import '../../core/constants/database_constants.dart';
import '../../core/extensions/context_feedback.dart';
import '../../core/extensions/context_l10n.dart';
import '../../core/extensions/context_theme.dart';
import '../../core/helpers/category_localization.dart';
import '../../core/theme/app_form_fields.dart';
import '../../services/category_service.dart';
import '../../services/lazarus_database_service.dart';

/// Form to add or edit a user-defined transaction category.
class CategoryFormScreen extends StatefulWidget {
  const CategoryFormScreen({
    super.key,
    this.categoryId,
    this.initialType = DatabaseConstants.categoryExpense,
  });

  final String? categoryId;
  final String initialType;

  bool get isEditing => categoryId != null;

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryService =
      CategoryService(LazarusDatabaseService.instance);

  late String _type;
  String _iconKey = CategoryIconStyles.food;
  String _colorHex = CategoryIconStyles.presetColorHexes.first;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  Future<void> _initialize() async {
    if (widget.isEditing) {
      final category = await _categoryService.getById(widget.categoryId!);
      if (!mounted) return;
      if (category == null) {
        context.pop();
        return;
      }
      if (category.isSystem) {
        context.showWarningFeedback(context.l10n.categoryFormSystemProtected);
        context.pop();
        return;
      }
      _type = category.type;
      _nameController.text = category.name;
      _iconKey = category.iconKey ?? CategoryIconStyles.other;
      _colorHex = category.colorHex ?? CategoryIconStyles.presetColorHexes.first;
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = context.l10n;
    setState(() => _isSaving = true);

    try {
      if (widget.isEditing) {
        await _categoryService.update(
          id: widget.categoryId!,
          name: _nameController.text,
          iconKey: _iconKey,
          colorHex: _colorHex,
        );
      } else {
        await _categoryService.create(
          name: _nameController.text,
          type: _type,
          iconKey: _iconKey,
          colorHex: _colorHex,
        );
      }

      if (!mounted) return;
      context.showSuccessFeedback(l10n.categoryFormSaveSuccess);
      context.pop();
    } catch (e) {
      if (mounted) {
        context.showOperationError(e, categoryContext: true);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing
              ? l10n.categoryFormEditTitle
              : l10n.categoryFormNewTitle,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  if (!widget.isEditing) ...[
                    Text(
                      l10n.categoryFormType,
                      style: AppFormFields.sectionLabelStyleOf(context),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<String>(
                      segments: [
                        ButtonSegment(
                          value: DatabaseConstants.categoryExpense,
                          label: Text(l10n.categoryFormTypeExpense),
                        ),
                        ButtonSegment(
                          value: DatabaseConstants.categoryIncome,
                          label: Text(l10n.categoryFormTypeIncome),
                        ),
                      ],
                      selected: {_type},
                      onSelectionChanged: (value) {
                        setState(() => _type = value.first);
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                  TextFormField(
                    controller: _nameController,
                    style: AppFormFields.inputTextStyleOf(context),
                    decoration: AppFormFields.decoration(
                      context,
                      labelText: l10n.categoryFormName,
                      hintText: l10n.categoryFormNameHint,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.categoryFormNameRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.categoryFormIcon,
                    style: AppFormFields.sectionLabelStyleOf(context),
                  ),
                  const SizedBox(height: 12),
                  _IconPickerGrid(
                    selectedKey: _iconKey,
                    colorHex: _colorHex,
                    onSelected: (key) => setState(() => _iconKey = key),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.categoryFormColor,
                    style: AppFormFields.sectionLabelStyleOf(context),
                  ),
                  const SizedBox(height: 12),
                  _ColorPickerRow(
                    selectedHex: _colorHex,
                    onSelected: (hex) => setState(() => _colorHex = hex),
                  ),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: _isSaving ? null : _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            widget.isEditing
                                ? l10n.categoryFormSave
                                : l10n.categoryFormCreate,
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _IconPickerGrid extends StatelessWidget {
  const _IconPickerGrid({
    required this.selectedKey,
    required this.colorHex,
    required this.onSelected,
  });

  final String selectedKey;
  final String colorHex;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final accent = CategoryIconStyles.colorFor(colorHex);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: CategoryIconStyles.selectableIconKeys.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final key = CategoryIconStyles.selectableIconKeys[index];
        final selected = key == selectedKey;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onSelected(key),
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              decoration: BoxDecoration(
                color: selected
                    ? accent.withValues(alpha: 0.16)
                    : colors.inputFill,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? accent : colors.cardBorder,
                  width: selected ? 2 : 1,
                ),
              ),
              child: Icon(
                CategoryIconStyles.iconFor(key),
                color: selected ? accent : colors.textSecondary,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ColorPickerRow extends StatelessWidget {
  const _ColorPickerRow({
    required this.selectedHex,
    required this.onSelected,
  });

  final String selectedHex;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final hex in CategoryIconStyles.presetColorHexes)
          _ColorDot(
            hex: hex,
            selected: hex == selectedHex,
            onTap: () => onSelected(hex),
          ),
      ],
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({
    required this.hex,
    required this.selected,
    required this.onTap,
  });

  final String hex;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = CategoryIconStyles.colorFor(hex);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? Colors.white : Colors.transparent,
            width: 2,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.55),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: selected
            ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
            : null,
      ),
    );
  }
}
