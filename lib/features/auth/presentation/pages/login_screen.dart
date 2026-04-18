import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/constants/app_strings.dart';
import 'package:lung_diagnosis_app/core/storage/app_storage.dart';
import 'package:lung_diagnosis_app/core/storage/keys.dart';
import 'package:lung_diagnosis_app/core/widgets/app_bar.dart';
import 'package:lung_diagnosis_app/core/widgets/app_top_message.dart';
import 'package:lung_diagnosis_app/core/widgets/text_button.dart';
import 'package:lung_diagnosis_app/core/widgets/text_field.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/models/remembered_account_option.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/pages/forget_password_screen.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/pages/signup_otp_verification_screen.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/widgets/auth_account_prompt_row.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/widgets/auth_submit_section.dart';
import 'package:lung_diagnosis_app/features/auth/presentation/widgets/remembered_accounts_sheet.dart';
import 'package:lung_diagnosis_app/routes/app_routes.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _showRememberedAccounts() async {
    final auth = context.read<AuthController>();
    if (!auth.isLocalMode) {
      return;
    }

    final accounts = await auth.rememberedAccountOptions();
    if (!mounted) return;

    if (accounts.isEmpty) {
      AppTopMessage.error(context, 'No saved accounts yet.');
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) => RememberedAccountsSheet(
        accounts: accounts,
        onAccountSelected: (account) {
          _applyRememberedAccount(account, sheetContext);
        },
        onAccountRemoved: (account) async {
          await auth.forgetRememberedAccount(account.email);
          if (!sheetContext.mounted) return;
          Navigator.pop(sheetContext);
          AppTopMessage.success(sheetContext, 'Removed saved account');
        },
      ),
    );
  }

  void _applyRememberedAccount(
    RememberedAccountOption account,
    BuildContext sheetContext,
  ) {
    _emailController.text = account.email;
    _passwordController.text = account.password;
    Navigator.pop(sheetContext);
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthController>();

    try {
      setState(() => _isLoading = true);

      final ok = await auth.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (!ok) {
        final pendingEmail = await AppStorage.getString(
          StorageKeys.pendingVerificationEmail,
        );
        final pendingIsDoctor = await AppStorage.getBool(
          StorageKeys.pendingVerificationIsDoctor,
        );
        final errorText = (auth.error ?? '').toLowerCase();
        final requiresVerification =
            errorText.contains('verify your email') ||
            errorText.contains('email first') ||
            errorText.contains('email not confirmed') ||
            errorText.contains('email is not confirmed') ||
            errorText.contains('otp');

        final matchesPendingEmail = pendingEmail != null &&
            pendingEmail.trim().toLowerCase() ==
                _emailController.text.trim().toLowerCase();

        if (requiresVerification || matchesPendingEmail) {
          await AppStorage.setString(
            StorageKeys.pendingVerificationEmail,
            _emailController.text.trim(),
          );

          if (!mounted) return;

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => SignupOtpVerificationScreen(
                email: _emailController.text.trim(),
                isDoctor: pendingIsDoctor,
              ),
            ),
          );
          return;
        }

        AppTopMessage.error(
          context,
          auth.error ?? 'Login failed. Please check your credentials and try again.',
        );
        return;
      }

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.authGate,
        (route) => false,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      AppTopMessage.error(
        context,
        auth.error ?? 'An unexpected error occurred while logging in.',
      );
    }
  }

  void _openForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ForgetPasswordScreen()),
    );
  }

  void _openCreateAccount() {
    Navigator.pushNamed(context, AppRoutes.roleSelection);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final auth = context.watch<AuthController>();

    return Scaffold(
      appBar: CustomAppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: AppStrings.welcomeBack,
        showBack: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LoginHeroCard(scheme: scheme),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: scheme.primary.withOpacity(0.08)),
                    boxShadow: [
                      if (scheme.brightness == Brightness.light)
                        BoxShadow(
                          color: scheme.primary.withOpacity(0.06),
                          blurRadius: 20,
                          offset: const Offset(0, 12),
                        ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextField(
                        controller: _emailController,
                        labelText: AppStrings.email,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icon(Icons.mail_outline_rounded, color: scheme.primary),
                        suffixIcon: auth.isLocalMode
                            ? IconButton(
                                onPressed: _showRememberedAccounts,
                                icon: Icon(
                                  Icons.arrow_drop_down_circle_outlined,
                                  color: scheme.primary,
                                ),
                              )
                            : null,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return AppStrings.emailError;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _passwordController,
                        labelText: AppStrings.password,
                        obscureText: true,
                        prefixIcon: Icon(Icons.lock_outline_rounded, color: scheme.primary),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppStrings.passwordError;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          height: 36,
                          child: CustomTextButton(
                            text: AppStrings.forgotPassword,
                            fontSize: 12,
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                            onPressed: _openForgotPassword,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      AuthSubmitSection(
                        isLoading: _isLoading,
                        text: AppStrings.login,
                        onPressed: _login,
                        height: 52,
                        borderRadius: 20,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                AuthAccountPromptRow(
                  promptText: 'Dont have an account? ',
                  actionText: 'Create account',
                  onTap: _openCreateAccount,
                ),
                const SizedBox(height: 16),
                _LoginModeHintCard(auth: auth, scheme: scheme),
                const SizedBox(height: 20),
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
    super.dispose();
  }
}

class _LoginModeHintCard extends StatelessWidget {
  final AuthController auth;
  final ColorScheme scheme;

  const _LoginModeHintCard({
    required this.auth,
    required this.scheme,
  });

  @override
  Widget build(BuildContext context) {
    const label = 'Connected to the live backend. Sign in with an approved account.';

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: scheme.primary.withOpacity(0.06)),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _LoginHeroCard extends StatelessWidget {
  final ColorScheme scheme;

  const _LoginHeroCard({required this.scheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primary,
            scheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withOpacity(0.16),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.health_and_safety_outlined,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Secure login',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          const Text(
            AppStrings.loginTitle,
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              height: 1.2,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Access your respiratory care tools, saved activity, and personalized health workflow in one place.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.92),
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
