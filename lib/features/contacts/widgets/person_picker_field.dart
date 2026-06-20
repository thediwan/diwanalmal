import 'package:flutter/material.dart';

import '../../../core/theme/app_form_fields.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/extensions/context_l10n.dart';
import '../../../core/extensions/context_theme.dart';
import '../../../database/lazarus_database.dart';
import '../../../services/contact_service.dart';
import '../../../services/lazarus_database_service.dart';

/// Selected person from contacts or a new free-text name.
class PersonSelection {
  const PersonSelection({
    this.contactId,
    required this.displayName,
  });

  final String? contactId;
  final String displayName;

  bool get isEmpty => displayName.trim().isEmpty;
}

/// Autocomplete field for picking an existing contact or typing a new name.
class PersonPickerField extends StatefulWidget {
  const PersonPickerField({
    super.key,
    this.initialSelection,
    required this.onChanged,
    this.label,
    this.hint,
  });

  final PersonSelection? initialSelection;
  final ValueChanged<PersonSelection> onChanged;
  final String? label;
  final String? hint;

  @override
  State<PersonPickerField> createState() => _PersonPickerFieldState();
}

class _PersonPickerFieldState extends State<PersonPickerField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  List<DbContact> _contacts = [];
  PersonSelection? _selection;

  @override
  void initState() {
    super.initState();
    _selection = widget.initialSelection;
    if (_selection != null && _selection!.displayName.isNotEmpty) {
      _controller.text = _selection!.displayName;
    }
    _loadContacts();
  }

  @override
  void didUpdateWidget(covariant PersonPickerField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSelection != oldWidget.initialSelection &&
        widget.initialSelection != null) {
      _selection = widget.initialSelection;
      _controller.text = widget.initialSelection!.displayName;
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
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Iterable<DbContact> _filterContacts(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return _contacts;
    return _contacts.where((c) => c.name.toLowerCase().contains(q));
  }

  void _emitSelection({String? contactId, required String name}) {
    final selection = PersonSelection(
      contactId: contactId,
      displayName: name.trim(),
    );
    _selection = selection;
    widget.onChanged(selection);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;

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
        RawAutocomplete<DbContact>(
          textEditingController: _controller,
          focusNode: _focusNode,
          displayStringForOption: (option) => option.name,
          optionsBuilder: (textEditingValue) {
            return _filterContacts(textEditingValue.text);
          },
          onSelected: (contact) {
            _controller.text = contact.name;
            _emitSelection(contactId: contact.id, name: contact.name);
          },
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              textCapitalization: TextCapitalization.words,
              style: AppFormFields.inputTextStyleOf(context),
              decoration: AppFormFields.decoration(
                context,
                hintText: widget.hint ?? l10n.contactSelectOrAdd,
              ),
              onChanged: (value) {
                DbContact? match;
                for (final contact in _contacts) {
                  if (contact.name.toLowerCase() ==
                      value.trim().toLowerCase()) {
                    match = contact;
                    break;
                  }
                }
                _emitSelection(
                  contactId: match?.id,
                  name: value,
                );
              },
              onFieldSubmitted: (_) => onFieldSubmitted(),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            if (options.isEmpty) {
              final typed = _controller.text.trim();
              if (typed.isEmpty) return const SizedBox.shrink();
              return _SuggestionPanel(
                children: [
                  ListTile(
                    leading: Icon(Icons.person_add_outlined, color: colors.textSecondary),
                    title: Text(
                      l10n.contactAddNewNamed(typed),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    onTap: () {
                      _emitSelection(name: typed);
                      _focusNode.unfocus();
                    },
                  ),
                ],
              );
            }

            return _SuggestionPanel(
              children: [
                for (final contact in options)
                  ListTile(
                    title: Text(
                      contact.name,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    onTap: () => onSelected(contact),
                  ),
                if (_controller.text.trim().isNotEmpty &&
                    !options.any(
                      (c) =>
                          c.name.toLowerCase() ==
                          _controller.text.trim().toLowerCase(),
                    ))
                  ListTile(
                    leading: Icon(Icons.person_add_outlined, color: colors.textSecondary),
                    title: Text(
                      l10n.contactAddNewNamed(_controller.text.trim()),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    onTap: () {
                      _emitSelection(name: _controller.text.trim());
                      _focusNode.unfocus();
                    },
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _SuggestionPanel extends StatelessWidget {
  const _SuggestionPanel({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Align(
      alignment: AlignmentDirectional.topStart,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(12),
        color: colors.surfaceElevated,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 220, minWidth: 280),
          child: ListView(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            children: children,
          ),
        ),
      ),
    );
  }
}
