import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import '../../di/injection.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
import '../pages/auth_dialog.dart';

class Header extends StatefulWidget implements PreferredSizeWidget {
  const Header({super.key});

  @override
  _HeaderState createState() => _HeaderState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _HeaderState extends State<Header> {
  final _storage = const FlutterSecureStorage();
  bool _isLoading = false;

  static const primaryColor = Color(0xFF447BBA);

  Future<void> _handleProfileTap() async {
    setState(() => _isLoading = true);
    try {
      final token = await _storage.read(key: 'access_token');
      if (token != null) {
        // Проверяем валидность токена, пытаясь получить профиль
        final useCase = getIt<GetUserProfileUseCase>();
        await useCase.execute(token);
        if (mounted) {
          context.go('/profile');
        }
      } else {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => const AuthDialog(),
          );
        }
      }
    } catch (e) {
      // Если токен невалиден, удаляем его и показываем диалог авторизации
      await _storage.delete(key: 'access_token');
      if (mounted) {
        showDialog(context: context, builder: (context) => const AuthDialog());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0,
      title: Row(
        children: [
          GestureDetector(
            onTap: () => context.go('/'),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'favicon.png',
                  height: 40,
                  width: 40,
                  errorBuilder:
                      (_, __, ___) => Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.local_parking,
                          color: Colors.white,
                        ),
                      ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Онлайн парковки',
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child:
              _isLoading
                  ? const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: primaryColor,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                  : IconButton(
                    icon: const Icon(
                      Icons.person_outline,
                      color: primaryColor,
                      size: 28,
                    ),
                    onPressed: _handleProfileTap,
                    tooltip: 'Профиль',
                    splashRadius: 24,
                  ),
        ),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(3),
        child: Divider(height: 3, thickness: 3, color: primaryColor),
      ),
    );
  }
}
