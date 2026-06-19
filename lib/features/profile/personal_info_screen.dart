import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/extensions/context_l10n.dart';
import '../../core/extensions/context_feedback.dart';
import '../../core/theme/app_form_fields.dart';
import '../../models/profile_data.dart';
import '../../providers/profile_provider.dart';
import 'widgets/profile_header.dart';

/// Edit display name, email, phone, and avatar.
class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _imagePicker = ImagePicker();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadFields());
  }

  void _loadFields() {
    final profile = context.read<ProfileProvider>().profile;
    if (profile == null) {
      context.read<ProfileProvider>().load().then((_) {
        if (!mounted) return;
        _applyProfile(context.read<ProfileProvider>().profile);
      });
      return;
    }
    _applyProfile(profile);
  }

  void _applyProfile(ProfileData? profile) {
    if (profile == null) return;
    _nameController.text = profile.displayName;
    _emailController.text = profile.email ?? '';
    _phoneController.text = profile.phone ?? '';
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;

    try {
      await context.read<ProfileProvider>().updateAvatar(picked.path);
      if (mounted) {
        context.showSuccessFeedback(context.l10n.profileAvatarUpdated);
      }
    } catch (e) {
      if (mounted) context.showOperationError(e);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await context.read<ProfileProvider>().updatePersonalInfo(
            fullName: _nameController.text,
            email: _emailController.text,
            phone: _phoneController.text,
          );
      if (mounted) {
        context.showSuccessFeedback(context.l10n.profileSaveSuccess);
        context.pop();
      }
    } catch (e) {
      if (mounted) context.showOperationError(e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final profile = context.watch<ProfileProvider>().profile;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profilePersonalInfo),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.categoryFormSave),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (profile != null)
                ProfileHeader(
                  profile: profile,
                  onEditAvatar: _pickAvatar,
                ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                style: AppFormFields.inputTextStyleOf(context),
                decoration: AppFormFields.decoration(
                  context,
                  labelText: l10n.profileFullName,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return l10n.profileFullNameRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: AppFormFields.inputTextStyleOf(context),
                decoration: AppFormFields.decoration(
                  context,
                  labelText: l10n.profileEmail,
                ),
                validator: (v) {
                  final text = v?.trim() ?? '';
                  if (text.isEmpty) return null;
                  if (!text.contains('@') || !text.contains('.')) {
                    return l10n.profileEmailInvalid;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: AppFormFields.inputTextStyleOf(context),
                decoration: AppFormFields.decoration(
                  context,
                  labelText: l10n.profilePhone,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
