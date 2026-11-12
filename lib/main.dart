import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocs/auth_bloc.dart';
import 'blocs/cart_bloc.dart';
import 'blocs/category_bloc.dart';
import 'blocs/product_list_bloc.dart';
import 'blocs/profile_bloc.dart';
import 'core/api_client.dart';
import 'core/theme.dart';
import 'core/token_storage.dart';
import 'repositories/auth_repository.dart';
import 'repositories/cart_repository.dart';
import 'repositories/catalog_repository.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = TokenStorage();
  await storage.load();
  final api = ApiClient(storage);

  final authRepository = AuthRepository(api, storage);
  final catalogRepository = CatalogRepository(api);
  final cartRepository = CartRepository(api);

  final authBloc = AuthBloc(authRepository, storage)..add(AuthStarted());

  api.onUnauthorized = () => authBloc.add(AuthSessionExpired());

  runApp(
    MyApp(
      authBloc: authBloc,
      authRepository: authRepository,
      catalogRepository: catalogRepository,
      cartRepository: cartRepository,
    ),
  );
}

class MyApp extends StatelessWidget {
  final AuthBloc authBloc;
  final AuthRepository authRepository;
  final CatalogRepository catalogRepository;
  final CartRepository cartRepository;

  const MyApp({
    super.key,
    required this.authBloc,
    required this.authRepository,
    required this.catalogRepository,
    required this.cartRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: catalogRepository),
        RepositoryProvider.value(value: cartRepository),
      ],

      child: BlocProvider.value(
        value: authBloc,
        child: MaterialApp(
          title: 'Wildberries',
          debugShowCheckedModeBanner: false,
          theme: buildTheme(),

          builder: (context, child) {
            return BlocBuilder<AuthBloc, AuthState>(
              buildWhen: (a, b) => a.status != b.status,
              builder: (context, state) {
                if (state.status != AuthStatus.authenticated) return child!;

                return MultiBlocProvider(
                  providers: [
                    BlocProvider(
                      create: (context) =>
                          CategoryBloc(context.read<CatalogRepository>())
                            ..add(CategoriesRequested()),
                    ),
                    BlocProvider(
                      create: (context) =>
                          ProductListBloc(context.read<CatalogRepository>())
                            ..add(ProductsRequested()),
                    ),
                    BlocProvider(
                      create: (context) =>
                          CartBloc(context.read<CartRepository>())
                            ..add(CartRequested()),
                    ),
                    BlocProvider(
                      create: (context) =>
                          ProfileBloc(context.read<AuthRepository>())
                            ..add(ProfileRequested()),
                    ),
                  ],
                  child: child!,
                );
              },
            );
          },
          home: const _Root(),
        ),
      ),
    );
  }
}

class _Root extends StatelessWidget {
  const _Root();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (a, b) => a.status != b.status,
      builder: (context, state) {
        switch (state.status) {
          case AuthStatus.unknown:
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          case AuthStatus.unauthenticated:
            return const LoginScreen();
          case AuthStatus.authenticated:
            return const MainShell();
        }
      },
    );
  }
}
