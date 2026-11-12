import '../core/api_client.dart';
import '../core/token_storage.dart';
import '../models/user_profile.dart';

class AuthRepository {
  final ApiClient api;
  final TokenStorage storage;

  AuthRepository(this.api, this.storage);

  Future<void> login(String username, String password) {
    return api.run(() async {
      final response = await api.dio.post(
        'login/',
        data: {'username': username, 'password': password},
      );
      final data = response.data;
      await storage.save(
        access: data['access'],
        refresh: data['refresh'],
        username: data['user']['username'] ?? username,
        email: data['user']['email'] ?? '',
      );
    });
  }

  Future<void> register({
    required String username,
    required String password,
    required String email,
    required String firstName,
    required String lastName,
    int? age,
    String? phone,
  }) {
    return api.run(() async {
      await api.dio.post(
        'register/',
        data: {
          'username': username,
          'password': password,
          'email': email,
          'first_name': firstName,
          'last_name': lastName,

          if (age != null) 'age': age,
          if (phone != null && phone.isNotEmpty) 'phone_number': phone,
        },
      );
    });
  }

  Future<void> logout() async {
    try {
      await api.dio.post('logout/', data: {'refresh': storage.refreshToken});
    } catch (_) {}
    await storage.clear();
  }

  Future<UserProfile> getProfile() {
    return api.run(() async {
      final response = await api.dio.get('user/');
      final list = resultsOf(response.data);
      if (list.isEmpty) throw ApiException('Профиль не найден');
      return UserProfile.fromJson(list.first);
    });
  }
}
