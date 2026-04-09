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
import '../../../models/user.dart';
import '../../../providers/providers.dart';

/// Login/signup screen for guest bookings and staff/admin portal access.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _isSignup = false;
  bool _obscure = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  void _handlePostAuthRedirect(User user, String? nextPath) {
    if (!mounted) return;
    switch (user.role.name) {
      case 'admin':
        context.go(RoutePaths.adminDashboard);
        break;
      case 'staff':
        context.go(RoutePaths.staffDashboard);
        break;
      default:
        if (nextPath != null && nextPath.isNotEmpty) {
          context.go(Uri.decodeComponent(nextPath));
        } else {
          context.go(RoutePaths.home);
        }
    }
  }

  Future<void> _handleAuthSubmit(String? nextPath) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_isSignup && _passCtrl.text != _confirmPassCtrl.text) {
      setState(() => _error = 'Passwords do not match');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      final user = _isSignup
          ? await authService.signup(
              name: _nameCtrl.text.trim(),
              email: _emailCtrl.text.trim(),
              password: _passCtrl.text,
              phone: _phoneCtrl.text.trim().isEmpty
                  ? null
                  : _phoneCtrl.text.trim(),
            )
          : await authService.login(
              _emailCtrl.text.trim(),
              _passCtrl.text,
            );

      if (user == null) {
        setState(() => _error = _isSignup
            ? 'Could not create account. Try another email.'
            : 'Invalid email or password');
        return;
      }

      ref.read(authProvider.notifier).setUser(user);

      _handlePostAuthRedirect(user, nextPath);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final nextPath = GoRouterState.of(context).uri.queryParameters['next'];

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
                      'assets/imgs/banner.jpeg',
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
                          'Login or create account to continue',
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
                          _isSignup ? 'Create Account' : 'Welcome Back',
                          style: AppTypography.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          _isSignup
                              ? 'Sign up to book rooms'
                              : 'Sign in to continue',
                          style: AppTypography.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        if (_isSignup) ...[
                          SSTextField(
                            label: 'Full Name',
                            hint: 'Your name',
                            controller: _nameCtrl,
                            prefixIcon: Icons.person_outline,
                            validator: (v) {
                              if (!_isSignup) return null;
                              if (v?.trim().isEmpty ?? true) {
                                return 'Name is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],
                        SSTextField(
                          label: 'Email',
                          hint: 'you@email.com',
                          controller: _emailCtrl,
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v?.isEmpty ?? true) return 'Email is required';
                            if (!v!.contains('@')) return 'Enter a valid email';
                            return null;
                          },
                        ),
                        if (_isSignup) ...[
                          const SizedBox(height: AppSpacing.md),
                          SSTextField(
                            label: 'Phone (Optional)',
                            hint: '+92 3XX XXXXXXX',
                            controller: _phoneCtrl,
                            prefixIcon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                          ),
                        ],
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
                        if (_isSignup) ...[
                          const SizedBox(height: AppSpacing.md),
                          SSTextField(
                            label: 'Confirm Password',
                            hint: '••••••••',
                            controller: _confirmPassCtrl,
                            prefixIcon: Icons.lock_outline,
                            obscureText: _obscureConfirm,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirm
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 20,
                              ),
                              onPressed: () =>
                                  setState(() => _obscureConfirm = !_obscureConfirm),
                            ),
                            validator: (v) {
                              if (!_isSignup) return null;
                              if (v?.isEmpty ?? true) {
                                return 'Confirm your password';
                              }
                              if (v != _passCtrl.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                        ],
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
                          label: _isSignup ? 'Create Account' : 'Sign In',
                          isExpanded: true,
                          isLoading: _loading,
                          onPressed: () => _handleAuthSubmit(nextPath),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TextButton(
                          onPressed: _loading
                              ? null
                              : () {
                                  setState(() {
                                    _isSignup = !_isSignup;
                                    _error = null;
                                  });
                                },
                          child: Text(
                            _isSignup
                                ? 'Already have an account? Sign in'
                                : 'No account? Create one',
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
}
