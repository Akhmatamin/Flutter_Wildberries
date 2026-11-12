import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/auth_bloc.dart';
import '../blocs/category_bloc.dart' show LoadStatus;
import '../blocs/profile_bloc.dart';
import '../core/theme.dart';
import '../widgets/error_view.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state.status == LoadStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == LoadStatus.failure) {
            return ErrorView(
              message: state.error ?? 'Ошибка',
              onRetry: () =>
                  context.read<ProfileBloc>().add(ProfileRequested()),
            );
          }
          final p = state.profile!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    p.username.isEmpty ? '?' : p.username[0].toUpperCase(),
                    style: const TextStyle(fontSize: 32, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  p.fullName.isEmpty ? p.username : p.fullName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Column(
                  children: [
                    _row(Icons.person_outline, 'Логин', p.username),
                    _row(Icons.email_outlined, 'Email', p.email),
                    _row(Icons.cake_outlined, 'Возраст', p.age?.toString()),
                    _row(Icons.phone_outlined, 'Телефон', p.phone),
                    _row(Icons.workspace_premium_outlined, 'Статус', p.status),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => _confirmLogout(context),
                icon: const Icon(Icons.logout),
                label: const Text('Выйти'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _row(IconData icon, String title, String? value) => ListTile(
    leading: Icon(icon, color: AppColors.primary),
    title: Text(
      title,
      style: const TextStyle(fontSize: 12, color: AppColors.grey),
    ),
    subtitle: Text(
      (value == null || value.isEmpty) ? '—' : value,
      style: const TextStyle(fontSize: 16, color: Colors.black),
    ),
  );

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Выйти из аккаунта?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
  }
}
