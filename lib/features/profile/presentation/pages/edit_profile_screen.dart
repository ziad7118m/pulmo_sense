import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lung_diagnosis_app/core/constants/app_strings.dart';
import 'package:lung_diagnosis_app/core/widgets/app_bar.dart';
import 'package:lung_diagnosis_app/core/widgets/app_top_message.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:lung_diagnosis_app/features/profile/logic/profile_controller.dart';
import 'package:lung_diagnosis_app/features/profile/presentation/models/edit_profile_seed.dart';
import 'package:lung_diagnosis_app/features/profile/presentation/widgets/edit_profile_avatar_picker.dart';
import 'package:lung_diagnosis_app/features/profile/presentation/widgets/edit_profile_form_fields.dart';
import 'package:lung_diagnosis_app/features/profile/presentation/widgets/edit_profile_save_section.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _nationalIDController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _licenseController = TextEditingController();

  String _gender = AppStrings.male;
  String _maritalStatus = AppStrings.yes;
  File? _profileImage;
  bool _loading = true;

  bool get _isDoctor => context.read<AuthController>().isDoctor;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final auth = context.read<AuthController>();
    final profileController = context.read<ProfileController>();
    final seed = await profileController.loadEditSeed(auth.currentUser);

    if (!mounted) return;
    if (seed != null) {
      _applySeed(seed);
    }
    setState(() => _loading = false);
  }

  void _applySeed(EditProfileSeed seed) {
    _firstNameController.text = seed.firstName;
    _lastNameController.text = seed.lastName;
    _nationalIDController.text = seed.profile.nationalId;
    _addressController.text = seed.profile.address;
    _phoneController.text = seed.profile.phone;
    _birthDateController.text = seed.profile.birthDate;
    _licenseController.text = seed.profile.doctorLicense;
    _gender = seed.gender;
    _maritalStatus = seed.maritalStatus;
    _profileImage = seed.avatarFile;
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source);
    if (!mounted || picked == null) return;
    setState(() => _profileImage = File(picked.path));
  }

  void _handleAvatarSelection(String value) {
    if (value == 'camera') {
      _pickImage(ImageSource.camera);
      return;
    }
    _pickImage(ImageSource.gallery);
  }

  Future<void> _selectBirthDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (date == null) return;
    _birthDateController.text = DateFormat('dd/MM/yyyy').format(date);
  }

  Future<void> _saveProfile() async {
    final auth = context.read<AuthController>();
    final user = auth.currentUser;
    if (user == null) return;
    if (!_formKey.currentState!.validate()) return;

    final profileController = context.read<ProfileController>();
    final fullName = profileController.composeDisplayName(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
    );

    if (fullName.isEmpty) {
      AppTopMessage.error(context, 'Name is required');
      return;
    }

    await profileController.saveProfileForm(
      user: user,
      nationalId: _nationalIDController.text,
      address: _addressController.text,
      phone: _phoneController.text,
      birthDate: _birthDateController.text,
      gender: _gender,
      maritalStatus: _maritalStatus,
      doctorLicense: _licenseController.text,
      avatarFile: _profileImage,
    );

    await auth.updateDisplayName(fullName);

    if (!mounted) return;
    AppTopMessage.success(context, 'Profile updated');
    Navigator.pop(context);
  }

  Widget _loadingBody() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _formBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            EditProfileAvatarPicker(
              profileImage: _profileImage,
              onSelected: _handleAvatarSelection,
            ),
            const SizedBox(height: 20),
            EditProfileFormFields(
              firstNameController: _firstNameController,
              lastNameController: _lastNameController,
              nationalIdController: _nationalIDController,
              addressController: _addressController,
              phoneController: _phoneController,
              birthDateController: _birthDateController,
              licenseController: _licenseController,
              gender: _gender,
              maritalStatus: _maritalStatus,
              isDoctor: _isDoctor,
              onBirthDateTap: _selectBirthDate,
              onGenderChanged: (value) {
                setState(() => _gender = value ?? AppStrings.male);
              },
              onMaritalStatusChanged: (value) {
                setState(() => _maritalStatus = value ?? AppStrings.yes);
              },
            ),
            const SizedBox(height: 22),
            EditProfileSaveSection(onSave: _saveProfile),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppStrings.editProfile,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _loading ? _loadingBody() : _formBody(),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _nationalIDController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _birthDateController.dispose();
    _licenseController.dispose();
    super.dispose();
  }
}
