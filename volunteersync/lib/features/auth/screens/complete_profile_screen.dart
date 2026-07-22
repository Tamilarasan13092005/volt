import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../providers/auth_provider.dart';
import '../../../routes/app_router.dart';
import '../../../widgets/common/common_widgets.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _orgCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _selectedRole = 'volunteer';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _orgCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    
    final auth = context.read<AuthProvider>();
    final ok = await auth.completeProfile(_orgCtrl.text.trim(), _selectedRole);
    
    if (mounted) {
      setState(() => _isSubmitting = false);
      if (ok) {
        context.go(AppRouter.dashboard);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(auth.errorMessage ?? 'Failed to complete profile'),
          backgroundColor: AppColors.accent4,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.primary.withOpacity(0.15),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: const Icon(Icons.hub_rounded,
                              color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 12),
                        const Text(AppConstants.appName,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            )),
                      ],
                    ).animate().fadeIn(delay: 100.ms),
                    const SizedBox(height: 40),
                    Text('Complete Setup',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(fontWeight: FontWeight.w800))
                        .animate()
                        .fadeIn(delay: 200.ms),
                    const SizedBox(height: 6),
                    const Text('Choose your role and organization to continue',
                            style: TextStyle(
                                color: AppColors.textMuted, fontSize: 14))
                        .animate()
                        .fadeIn(delay: 300.ms),
                    const SizedBox(height: 40),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Role Selection Toggle
                          const Text(
                            'Register as a:',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => _selectedRole = 'volunteer'),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      decoration: BoxDecoration(
                                        color: _selectedRole == 'volunteer'
                                            ? AppColors.primary
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(9),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Volunteer',
                                        style: TextStyle(
                                          color: _selectedRole == 'volunteer'
                                              ? Colors.white
                                              : AppColors.textSecondary,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => _selectedRole = 'organizer'),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      decoration: BoxDecoration(
                                        color: _selectedRole == 'organizer'
                                            ? AppColors.primary
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(9),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Organizer',
                                        style: TextStyle(
                                          color: _selectedRole == 'organizer'
                                              ? Colors.white
                                              : AppColors.textSecondary,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(delay: 350.ms),
                          const SizedBox(height: 20),

                          // Organization
                          const Text(
                            'Organization Name',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _orgCtrl,
                            style: const TextStyle(color: AppColors.textPrimary),
                            decoration: const InputDecoration(
                              hintText: 'e.g. Red Cross / Self',
                              prefixIcon: Icon(Icons.business_outlined,
                                  color: AppColors.textMuted, size: 20),
                            ),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Enter your organization'
                                : null,
                          ).animate().fadeIn(delay: 400.ms),
                          const SizedBox(height: 32),

                          GradientButton(
                            label: 'Finish Setup',
                            onPressed: _isSubmitting ? () {} : _submit,
                            isLoading: _isSubmitting,
                            width: double.infinity,
                            icon: Icons.check_circle_outline_rounded,
                          ).animate().fadeIn(delay: 450.ms),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
