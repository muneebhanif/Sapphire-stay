import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/ss_button.dart';
import '../../../core/widgets/ss_text_field.dart';
import '../../../core/routing/app_router.dart';
import '../../../providers/providers.dart';

/// Login screen for staff and admin portal access.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final user = await ref.read(authServiceProvider).login(
            _emailCtrl.text.trim(),
            _passCtrl.text,
          );

      if (user == null) {
        setState(() => _error = 'Invalid email or password');
        return;
      }

      ref.read(authProvider.notifier).setUser(user);

      if (!mounted) return;

      switch (user.role.name) {
        case 'admin':
          context.go(RoutePaths.adminDashboard);
          break;
        case 'staff':
          context.go(RoutePaths.staffDashboard);
          break;
        default:
          context.go(RoutePaths.home);
      }
    } catch (e) {
      setState(() => _error = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // ── Left brand panel (desktop only) ──
          if (Responsive.isDesktop(context))
            Expanded(
              flex: 3,
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  image: DecorationImage(
                    image: NetworkImage(
                      'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=1200',
                    ),
                    fit: BoxFit.cover,
                    opacity: 0.3,
                  ),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusMd),
                          ),
                          child: const Icon(
                            Icons.hotel,
                            color: AppColors.primary,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'StaySite',
                          style: AppTypography.displaySmall.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Sapphire Stay Hotel Management',
                          style: AppTypography.bodyLarge.copyWith(
                            color: AppColors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // ── Login form ──
          Expanded(
            flex: 2,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Show small logo on non-desktop
                        if (!Responsive.isDesktop(context)) ...[
                          Center(
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius:
                                    BorderRadius.circular(AppSpacing.radiusMd),
                              ),
                              child: const Icon(
                                Icons.hotel,
                                color: AppColors.accent,
                                size: 28,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],
                        Text(
                          'Welcome Back',
                          style: AppTypography.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          'Sign in to access the portal',
                          style: AppTypography.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        SSTextField(
                          label: 'Email',
                          hint: 'admin@sapphirestay.com',
                          controller: _emailCtrl,
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v?.isEmpty ?? true) return 'Email is required';
                            if (!v!.contains('@')) return 'Enter a valid email';
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        SSTextField(
                          label: 'Password',
                          hint: '••••••••',
                          controller: _passCtrl,
                          prefixIcon: Icons.lock_outline,
                          obscureText: _obscure,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 20,
                            ),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                          validator: (v) =>
                              v?.isEmpty ?? true ? 'Password is required' : null,
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: AppSpacing.md),
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusSm),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline,
                                    color: AppColors.error, size: 18),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Text(
                                    _error!,
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.error,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.lg),
                        SSButton(
                          label: 'Sign In',
                          isExpanded: true,
                          isLoading: _loading,
                          onPressed: _handleLogin,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        // ── Demo credentials ──
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.info.withValues(alpha: 0.08),
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusMd),
                            border: Border.all(
                              color: AppColors.info.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.info_outline,
                                      size: 16, color: AppColors.info),
                                  const SizedBox(width: AppSpacing.xs),
                                  Text(
                                    'Demo Credentials',
                                    style: AppTypography.labelMedium.copyWith(
                                      color: AppColors.info,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              _buildCredRow('Admin', 'admin@sapphirestay.com'),
                              const SizedBox(height: 4),
                              _buildCredRow('Staff', 'staff@sapphirestay.com'),
                              const SizedBox(height: 4),
                              _buildCredRow('Password', 'password'),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Center(
                          child: TextButton.icon(
                            icon: const Icon(Icons.arrow_back, size: 16),
                            label: const Text('Back to Website'),
                            onPressed: () => context.go(RoutePaths.home),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCredRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(
            '$label:',
            style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTypography.bodySmall.copyWith(
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }
}
