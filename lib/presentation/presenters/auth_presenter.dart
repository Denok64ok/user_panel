import 'package:dio/dio.dart';
import '../../data/models/token.dart';
import '../../data/models/user.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

abstract class AuthView {
  void showLoading();
  void hideLoading();
  void showError(String message);
  void onLoginSuccess(Token token);
  void onRegisterSuccess(User user);
}

class AuthPresenter {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final AuthView view;

  AuthPresenter(this.loginUseCase, this.registerUseCase, this.view);

  Future<void> login(String email, String password) async {
    view.showLoading();
    try {
      final token = await loginUseCase.execute(email, password);
      view.hideLoading();
      view.onLoginSuccess(token);
    } catch (e) {
      view.hideLoading();
      if (e is DioException) {
        if (e.response?.statusCode == 422 || e.response?.statusCode == 401) {
          view.showError('Неверный email или пароль');
        } else if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.connectionError) {
          view.showError(
            'Не удалось подключиться к серверу. Проверьте подключение к интернету',
          );
        } else {
          view.showError('Не удалось войти в систему. Попробуйте позже');
        }
      } else {
        view.showError('Не удалось войти в систему. Попробуйте позже');
      }
    }
  }

  Future<void> register(
    String userName,
    String phone,
    String email,
    String password,
  ) async {
    view.showLoading();
    try {
      final user = await registerUseCase.execute(
        userName,
        phone,
        email,
        password,
      );

      try {
        final token = await loginUseCase.execute(email, password);
        view.hideLoading();
        view.onLoginSuccess(token);
      } catch (e) {
        view.hideLoading();
        view.onRegisterSuccess(user);
      }
    } catch (e) {
      view.hideLoading();
      if (e is DioException) {
        final responseData = e.response?.data?.toString() ?? '';
        if (e.response?.statusCode == 400 ||
            responseData.contains('already exists')) {
          view.showError('Пользователь с таким email уже существует');
        } else if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.connectionError) {
          view.showError(
            'Не удалось подключиться к серверу. Проверьте подключение к интернету',
          );
        } else {
          view.showError('Не удалось создать аккаунт. Попробуйте позже');
        }
      } else {
        view.showError('Не удалось создать аккаунт. Попробуйте позже');
      }
    }
  }
}
