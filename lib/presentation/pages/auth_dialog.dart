import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:user_panel/domain/usecases/login_usecase.dart';
import 'package:user_panel/domain/usecases/register_usecase.dart';
import '../../data/models/token.dart';
import '../../data/models/user.dart';
import '../../di/injection.dart';
import '../presenters/auth_presenter.dart';

class AuthDialog extends StatefulWidget {
  const AuthDialog({super.key});

  @override
  _AuthDialogState createState() => _AuthDialogState();
}

class _AuthDialogState extends State<AuthDialog> implements AuthView {
  final _storage = const FlutterSecureStorage();
  late AuthPresenter _presenter;
  bool _isLogin = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  // Controllers for registration
  final _userNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _presenter = AuthPresenter(
      getIt<LoginUseCase>(),
      getIt<RegisterUseCase>(),
      this,
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  void showLoading() {
    setState(() => _isLoading = true);
  }

  @override
  void hideLoading() {
    setState(() => _isLoading = false);
  }

  @override
  void showError(String message) {
    hideLoading();
    if (message.toLowerCase().contains('email already exists')) {
      _showError('Пользователь с таким email уже существует');
    } else if (message.toLowerCase().contains('invalid credentials')) {
      _showError('Неверный email или пароль');
    } else if (message.toLowerCase().contains('network') ||
        message.toLowerCase().contains('connection')) {
      _showError('Проверьте подключение к интернету');
    } else {
      _showError('Что-то пошло не так. Попробуйте позже');
    }
  }

  @override
  void onLoginSuccess(Token token) async {
    await _storage.write(key: 'access_token', value: token.accessToken);
    if (mounted) {
      context.go('/profile');
      Navigator.of(context).pop();
    }
  }

  @override
  void onRegisterSuccess(User user) {
    _presenter.login(_emailController.text, _passwordController.text);
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword && _obscurePassword,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF447BBA)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        suffixIcon:
            isPassword
                ? IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: const Color(0xFF447BBA),
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                )
                : null,
      ),
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTextField(
          controller: _userNameController,
          label: 'Имя пользователя',
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _phoneController,
          label: 'Телефон',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _emailController,
          label: 'Email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _passwordController,
          label: 'Пароль',
          icon: Icons.lock_outline,
          isPassword: true,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed:
                _isLoading
                    ? null
                    : () {
                      if (_userNameController.text.isEmpty ||
                          _phoneController.text.isEmpty ||
                          _emailController.text.isEmpty ||
                          _passwordController.text.isEmpty) {
                        _showError('Пожалуйста, заполните все поля');
                        return;
                      }
                      _presenter.register(
                        _userNameController.text,
                        _phoneController.text,
                        _emailController.text,
                        _passwordController.text,
                      );
                    },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF447BBA),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child:
                _isLoading
                    ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                    : const Text(
                      'Зарегистрироваться',
                      style: TextStyle(fontSize: 16),
                    ),
          ),
        ),
        TextButton(
          onPressed: () => setState(() => _isLogin = true),
          child: const Text(
            'Уже есть аккаунт? Войти',
            style: TextStyle(color: Color(0xFF447BBA)),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTextField(
          controller: _emailController,
          label: 'Email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _passwordController,
          label: 'Пароль',
          icon: Icons.lock_outline,
          isPassword: true,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed:
                _isLoading
                    ? null
                    : () {
                      if (_emailController.text.isEmpty ||
                          _passwordController.text.isEmpty) {
                        _showError('Пожалуйста, заполните все поля');
                        return;
                      }
                      _presenter.login(
                        _emailController.text,
                        _passwordController.text,
                      );
                    },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF447BBA),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child:
                _isLoading
                    ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                    : const Text('Войти', style: TextStyle(fontSize: 16)),
          ),
        ),
        TextButton(
          onPressed: () => setState(() => _isLogin = false),
          child: const Text(
            'Нет аккаунта? Зарегистрироваться',
            style: TextStyle(color: Color(0xFF447BBA)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _isLogin ? 'Вход' : 'Регистрация',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF447BBA),
                ),
              ),
              const SizedBox(height: 24),
              _isLogin ? _buildLoginForm() : _buildRegisterForm(),
            ],
          ),
        ),
      ),
    );
  }
}
