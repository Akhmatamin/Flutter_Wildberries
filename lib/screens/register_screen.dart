import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/auth_bloc.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _age = TextEditingController();
  final _phone = TextEditingController();

  @override
  void dispose() {
    for (final c in [
      _username,
      _email,
      _password,
      _firstName,
      _lastName,
      _age,
      _phone,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
      AuthRegisterRequested(
        username: _username.text.trim(),
        password: _password.text,
        email: _email.text.trim(),
        firstName: _firstName.text.trim(),
        lastName: _lastName.text.trim(),
        age: int.tryParse(_age.text.trim()),
        phone: _phone.text.trim(),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool required = true,
    bool obscure = false,
    TextInputType? keyboard,
    String? Function(String?)? extraValidator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboard,
        decoration: InputDecoration(labelText: label),
        validator: (value) {
          final text = value?.trim() ?? '';
          if (required && text.isEmpty) return 'Обязательное поле';
          return extraValidator?.call(text);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Регистрация')),
      backgroundColor: Colors.white,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.error!)));
          }

          if (state.status == AuthStatus.authenticated) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _field(_username, 'Логин'),
                _field(
                  _email,
                  'Email',
                  keyboard: TextInputType.emailAddress,
                  extraValidator: (v) =>
                      v!.contains('@') ? null : 'Некорректный email',
                ),
                _field(
                  _password,
                  'Пароль',
                  obscure: true,
                  extraValidator: (v) =>
                      v!.length < 6 ? 'Минимум 6 символов' : null,
                ),
                _field(_firstName, 'Имя'),
                _field(_lastName, 'Фамилия'),

                _field(
                  _age,
                  'Возраст (необязательно)',
                  required: false,
                  keyboard: TextInputType.number,
                  extraValidator: (v) {
                    if (v!.isEmpty) return null;
                    final age = int.tryParse(v);
                    return (age == null || age < 16 || age > 100)
                        ? 'От 16 до 100'
                        : null;
                  },
                ),
                _field(
                  _phone,
                  'Телефон, например +996555123456 (необязательно)',
                  required: false,
                  keyboard: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) => FilledButton(
                    onPressed: state.isLoading ? null : _submit,
                    child: state.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Создать аккаунт'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
