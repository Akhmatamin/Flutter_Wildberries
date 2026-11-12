import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/cart_bloc.dart';
import '../core/theme.dart';
import 'cart_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return BlocListener<CartBloc, CartState>(
      listenWhen: (prev, curr) =>
          curr.message != null && prev.messageId != curr.messageId,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(state.message!),
              duration: const Duration(seconds: 1),
            ),
          );
      },
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: const [HomeScreen(), CartScreen(), ProfileScreen()],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          backgroundColor: Colors.white,
          indicatorColor: AppColors.primary.withValues(alpha: 0.15),
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home, color: AppColors.primary),
              label: 'Главная',
            ),
            NavigationDestination(
              icon: BlocBuilder<CartBloc, CartState>(
                buildWhen: (a, b) => a.totalCount != b.totalCount,
                builder: (context, state) => Badge(
                  isLabelVisible: state.totalCount > 0,
                  label: Text('${state.totalCount}'),
                  child: const Icon(Icons.shopping_cart_outlined),
                ),
              ),
              selectedIcon: const Icon(
                Icons.shopping_cart,
                color: AppColors.primary,
              ),
              label: 'Корзина',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person, color: AppColors.primary),
              label: 'Профиль',
            ),
          ],
        ),
      ),
    );
  }
}
