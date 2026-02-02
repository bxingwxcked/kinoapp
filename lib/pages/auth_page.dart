import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoginMode = true;

  void _submit() async {
    final login = _loginController.text.trim();
    final password = _passwordController.text.trim();

    if (login.isEmpty || password.isEmpty) {
      _showError('Заполните все поля');
      return;
    }

    if (_isLoginMode) {
      final success = await _authService.login(login, password);
      if (success) {
        _navigateToHome();
      } else {
        _showError('Неверный логин или пароль');
      }
    } else {
      final error = await _authService.register(login, password);
      if (error == null) {
        _showSuccess('Регистрация успешна! Теперь войдите');
        setState(() => _isLoginMode = true);
      } else {
        _showError(error);
      }
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.movie_filter, size: 80, color: theme.colorScheme.primary),
              const SizedBox(height: 24),
              Text(
                _isLoginMode ? 'Вход в KinoBox' : 'Регистрация',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _loginController,
                decoration: const InputDecoration(labelText: 'Логин', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Пароль', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                  child: Text(_isLoginMode ? 'Войти' : 'Зарегистрироваться'),
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _isLoginMode = !_isLoginMode),
                child: Text(_isLoginMode ? 'Нет аккаунта? Создать' : 'Уже есть аккаунт? Войти'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}