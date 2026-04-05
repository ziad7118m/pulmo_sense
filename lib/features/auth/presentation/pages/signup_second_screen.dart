import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/constants/app_strings.dart';
import 'package:lung_diagnosis_app/core/validators/account_validators.dart';
import 'package:lung_diagnosis_app/core/widgets/app_bar.dart';
import 'package:lung_diagnosis_app/core/widgets/app_top_message.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/helpers/signup_register_request_builder.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/models/signup_profile_seed.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/pages/login_screen.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/widgets/auth_submit_section.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/widgets/signup_credentials_section.dart';
import 'package:lung_diagnosis_app/shared/domain/enums/user_role.dart';
import 'package:provider/provider.dart';

class SignupSecondScreen extends StatefulWidget {
  final bool isDoctor;
  final SignupProfileSeed profileSeed;

  const SignupSecondScreen({
    super.key,
    required this.isDoctor,
    required this.profileSeed,
  });

  @override
  State<SignupSecondScreen> createState() => _SignupSecondScreenState();
}

class _SignupSecondScreenState extends State<SignupSecondScreen> {
  static const SignupRegisterRequestBuilder _requestBuilder =
      SignupRegisterRequestBuilder();

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _licenseController = TextEditingController();

  bool _isLoading = false;

  String? _confirmPasswordValidator(String? value) {
    if ((value ?? '').isEmpty) return 'Confirm password is required';
    if (value != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthController>();
    auth.clearError();

    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    if (password != confirm) {
      AppTopMessage.error(
        context,
        'Password and confirm password do not match',
      );
      return;
    }

    final role = widget.isDoctor ? UserRole.doctor : UserRole.patient;

    setState(() => _isLoading = true);

    final request = _requestBuilder.build(
      seed: widget.profileSeed,
      role: role,
      email: _emailController.text,
      password: password,
      doctorLicense: _licenseController.text,
    );

    final ok = await auth.register(request);

    setState(() => _isLoading = false);

    if (!ok || !mounted) {
      AppTopMessage.error(context, auth.error ?? 'Signup failed');
      return;
    }

    AppTopMessage.success(
      context,
      'Account created. Waiting for admin approval.',
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: AppStrings.welcome,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                SignupCredentialsSection(
                  emailController: _emailController,
                  passwordController: _passwordController,
                  confirmPasswordController: _confirmPasswordController,
                  licenseController: _licenseController,
                  emailValidator: AccountValidators.email,
                  passwordValidator: AccountValidators.password,
                  confirmPasswordValidator: _confirmPasswordValidator,
                  licenseValidator: AccountValidators.license,
                  isDoctor: widget.isDoctor,
                ),
                const SizedBox(height: 24),
                AuthSubmitSection(
                  isLoading: _isLoading,
                  text: AppStrings.createAccount,
                  onPressed: _signup,
                  borderRadius: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _licenseController.dispose();
    super.dispose();
  }
}
