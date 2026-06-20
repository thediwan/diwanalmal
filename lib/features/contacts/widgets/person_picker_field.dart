import 'package:flutter/material.dart';

import '../../../core/extensions/context_l10n.dart';
import '../../../core/extensions/context_theme.dart';
import '../../../core/theme/app_form_fields.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../database/lazarus_database.dart';
import '../../../services/contact_service.dart';
import '../../../services/lazarus_database_service.dart';

/// Selected person from contacts or a new free-text name.
class PersonSelection {
  const PersonSelection({
    this.contactId,
    required this.displayName,
    this.phone,
  });

  final String? contactId;
  final String displayName;
  final String? phone;

  bool get isEmpty => displayName.trim().isEmpty;
}

/// Picker: first tap opens contact list; second tap or "new name" opens keyboard.
class PersonPickerField extends StatefulWidget {
  const PersonPickerField({
    super.key,
    this.initialSelection,
    required this.onChanged,
    this.label,
    this.hint,
    this.showPhoneField = false,
    this.onWhatsAppTap,
    this.enabled = true,
  });

  final PersonSelection? initialSelection;
  final ValueChanged<PersonSelection> onChanged;
  final String? label;
  final String? hint;
  final bool showPhoneField;
  final VoidCallback? onWhatsAppTap;
  final bool enabled;

  @override
  State<PersonPickerField> createState() => _PersonPickerFieldState();
}

class _PersonPickerFieldState extends State<PersonPickerField> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nameFocusNode = FocusNode();
  List<DbContact> _contacts = [];
  bool _keyboardMode = false;
  String? _selectedContactId;
  String? _selectedPhone;

  @override
  void initState() {
    super.initState();
    _applyInitial(widget.initialSelection);
    _loadContacts();
  }

  void _applyInitial(PersonSelection? selection) {
    if (selection == null) return;
    _selectedContactId = selection.contactId;
    _selectedPhone = selection.phone;
    if (selection.displayName.isNotEmpty) {
      _nameController.text = selection.displayName;
      _keyboardMode = false;
    }
    if (selection.phone != null && selection.phone!.isNotEmpty) {
      _phoneController.text = selection.phone!;
    }
  }

  @override
  void didUpdateWidget(covariant PersonPickerField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_nameFocusNode.hasFocus) return;

    final newName = widget.initialSelection?.displayName ?? '';
    final oldName = oldWidget.initialSelection?.displayName ?? '';
    if (newName != oldName && newName != _nameController.text) {
      _applyInitial(widget.initialSelection);
    }
  }

  Future<void> _loadContacts() async {
    final contacts =
        await ContactService(LazarusDatabaseService.instance).listActive();
    if (!mounted) return;
    setState(() => _contacts = contacts);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  void _emitSelection() {
    widget.onChanged(
      PersonSelection(
        contactId: _selectedContactId,
        displayName: _nameController.text,
        phone: _phoneController.text.trim().isEmpty
            ? _selectedPhone
            : _phoneController.text.trim(),
      ),
    );
  }

  void _selectContact(DbContact contact) {
    setState(() {
      _keyboardMode = false;
      _selectedContactId = contact.id;
      _selectedPhone = contact.phone;
      _nameController.text = contact.name;
      if (contact.phone != null) {
        _phoneController.text = contact.phone!;
      }
    });
    _emitSelection();
  }

  void _enterKeyboardMode() {
    setState(() {
      _keyboardMode = true;
      _selectedContactId = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _nameFocusNode.requestFocus();
    });
  }

  Future<void> _openContactPicker() async {
    final l10n = context.l10n;
    final colors = context.appColors;
    final searchController = TextEditingController();
    var filtered = List<DbContact>.from(_contacts);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            void filter(String q) {
              final query = q.trim().toLowerCase();
              setSheetState(() {
                filtered = query.isEmpty
                    ? List<DbContact>.from(_contacts)
                    : _contacts
                        .where((c) => c.name.toLowerCase().contains(query))
                        .toList();
              });
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.contactPickFromList,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: searchController,
                    style: AppFormFields.inputTextStyleOf(context),
                    decoration: AppFormFields.decoration(
                      context,
                      hintText: l10n.contactSelectOrAdd,
                    ),
                    onChanged: filter,
                  ),
                  const SizedBox(height: 8),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(sheetContext).size.height * 0.4,
                    ),
                    child: filtered.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              l10n.contactPickFromList,
                              style: AppTextStyles.captionOnSurface(colors),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final contact = filtered[index];
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(contact.name),
                                subtitle: contact.phone != null
                                    ? Text(contact.phone!)
                                    : null,
                                onTap: () {
                                  Navigator.pop(sheetContext);
                                  _selectContact(contact);
                                },
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      _enterKeyboardMode();
                    },
                    icon: const Icon(Icons.person_add_outlined),
                    label: Text(l10n.contactEnterNewName),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    searchController.dispose();
  }

  void _onNameFieldTap() {
    if (!widget.enabled || _keyboardMode) return;

    if (_nameController.text.trim().isNotEmpty) {
      _enterKeyboardMode();
      return;
    }

    if (_contacts.isNotEmpty) {
      _openContactPicker();
      return;
    }

    _enterKeyboardMode();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;
    final hasWhatsApp = widget.onWhatsAppTap != null &&
        ((_selectedPhone != null && _selectedPhone!.isNotEmpty) ||
            _phoneController.text.trim().isNotEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppFormFields.sectionLabelStyleOf(context),
          ),
          const SizedBox(height: 8),
        ],
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _nameController,
                focusNode: _nameFocusNode,
                readOnly: !_keyboardMode || !widget.enabled,
                enabled: widget.enabled,
                textCapitalization: TextCapitalization.words,
                style: AppFormFields.inputTextStyleOf(context),
                decoration: AppFormFields.decoration(
                  context,
                  hintText: widget.hint ?? l10n.contactSelectOrAdd,
                  suffixIcon: Icon(
                    _keyboardMode
                        ? Icons.keyboard_outlined
                        : Icons.arrow_drop_down,
                    color: colors.textSecondary,
                  ),
                ),
                onTap: widget.enabled ? _onNameFieldTap : null,
                onChanged: widget.enabled
                    ? (_) {
                        _selectedContactId = null;
                        _emitSelection();
                      }
                    : null,
              ),
            ),
            if (hasWhatsApp) ...[
              const SizedBox(width: 8),
              IconButton(
                tooltip: l10n.whatsappSend,
                onPressed: widget.onWhatsAppTap,
                icon: const Icon(Icons.chat_outlined),
                color: const Color(0xFF25D366),
              ),
            ],
          ],
        ),
        if (widget.showPhoneField && _keyboardMode) ...[
          const SizedBox(height: 8),
          TextFormField(
            controller: _phoneController,
            enabled: widget.enabled,
            keyboardType: TextInputType.phone,
            style: AppFormFields.inputTextStyleOf(context),
            decoration: AppFormFields.decoration(
              context,
              labelText: l10n.contactPhone,
              hintText: l10n.contactPhoneHint,
            ),
            onChanged: widget.enabled
                ? (_) {
                    _selectedPhone = _phoneController.text.trim();
                    _emitSelection();
                  }
                : null,
          ),
        ],
      ],
    );
  }
}
