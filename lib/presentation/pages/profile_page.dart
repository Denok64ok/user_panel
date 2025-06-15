import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../data/models/user.dart';
import '../../data/models/car_user.dart';
import '../../data/models/booking_detailed.dart';
import '../../di/injection.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
import '../../domain/usecases/get_user_cars_usecase.dart';
import '../../domain/usecases/get_user_bookings_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/delete_user_car_usecase.dart';
import '../../domain/usecases/create_car_usecase.dart';
import '../../domain/usecases/create_car_user_usecase.dart';
import '../presenters/profile_presenter.dart';
import '../widgets/header.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> implements ProfileView {
  final _storage = const FlutterSecureStorage();
  late ProfilePresenter _presenter;
  bool _isLoading = false;
  User? _user;
  List<CarUser> _userCars = [];
  List<BookingDetailed> _userBookings = [];
  final TextEditingController _carNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _presenter = ProfilePresenter(
      getIt<GetUserProfileUseCase>(),
      getIt<GetUserCarsUseCase>(),
      getIt<GetUserBookingsUseCase>(),
      getIt<DeleteUserCarUseCase>(),
      getIt<LogoutUseCase>(),
      getIt<CreateCarUseCase>(),
      getIt<CreateCarUserUseCase>(),
      this,
    );
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final token = await _storage.read(key: 'access_token');
    if (token == null) {
      if (mounted) {
        context.go('/');
      }
      return;
    }
    _presenter.loadProfile(token);
  }

  void _showMessage(String message, {bool isError = true}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[700] : Colors.green[700],
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
    if (message.contains('401') || message.contains('Unauthorized')) {
      _storage.delete(key: 'access_token');
      if (mounted) {
        context.go('/');
      }
      return;
    }

    if (message.contains('network') || message.contains('connection')) {
      _showMessage(
        'Не удалось подключиться к серверу. Проверьте подключение к интернету',
      );
    } else if (message.contains('not found') || message.contains('404')) {
      _showMessage('Запрашиваемые данные не найдены');
    } else if (message.contains('car already exists')) {
      _showMessage('Автомобиль с таким номером уже добавлен');
    } else if (message.contains('invalid car number')) {
      _showMessage('Неверный формат номера автомобиля');
    } else {
      _showMessage('Произошла ошибка. Попробуйте позже');
    }
  }

  @override
  void showProfile(User user) {
    setState(() => _user = user);
  }

  @override
  void showUserCars(List<CarUser> cars) {
    setState(() => _userCars = cars);
  }

  @override
  void showUserBookings(List<BookingDetailed> bookings) {
    setState(() => _userBookings = bookings);
  }

  @override
  void onLogoutSuccess() async {
    await _storage.delete(key: 'access_token');
    if (mounted) {
      context.go('/');
    }
  }

  Future<void> _handleLogout() async {
    final token = await _storage.read(key: 'access_token');
    if (token != null) {
      _presenter.logout(token);
    }
  }

  Future<void> _handleDeleteCar(CarUser car) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Подтверждение'),
            content: Text(
              'Вы действительно хотите удалить автомобиль ${car.carNumber}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Удалить'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      final token = await _storage.read(key: 'access_token');
      if (token != null) {
        _presenter.deleteUserCar(car.id, token);
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final formatter = DateFormat('dd.MM.yyyy HH:mm');
    return formatter.format(dateTime);
  }

  Widget _buildProfileInfo() {
    if (_user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      padding: const EdgeInsets.all(24),
      constraints: const BoxConstraints(maxWidth: 600),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Профиль пользователя',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF447BBA),
              ),
            ),
            const SizedBox(height: 32),
            _buildInfoRow(Icons.person_outline, 'Имя:', _user!.userName),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.phone_outlined, 'Телефон:', _user!.phone),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.email_outlined, 'Email:', _user!.email),
            const SizedBox(height: 32),
            _buildCarsList(),
            const Text(
              'Парковочные сессии',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF447BBA),
              ),
            ),
            const SizedBox(height: 16),
            if (_userBookings.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Text(
                  'У вас пока нет бронирований',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _userBookings.length,
                itemBuilder: (context, index) {
                  final booking = _userBookings[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              color: Color(0xFF447BBA),
                              size: 24,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    booking.zoneName ?? 'Зона не указана',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    booking.address ?? 'Адрес не указан',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              color: Color(0xFF447BBA),
                              size: 24,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'С ${_formatDateTime(booking.startDateTime)}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  Text(
                                    'До ${_formatDateTime(booking.endDateTime)}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.directions_car_outlined,
                              color: Color(0xFF447BBA),
                              size: 24,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Место ${booking.placeNumber}, ${booking.carNumber}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF447BBA).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            booking.bookingStatusName ?? 'Статус не указан',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF447BBA),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: 32),
            Center(
              child: SizedBox(
                width: 200,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _handleLogout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.logout),
                  label:
                      _isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : const Text('Выйти', style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF447BBA), size: 24),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Мои автомобили',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF447BBA),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add, color: Color(0xFF447BBA)),
              onPressed: _showAddCarDialog,
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_userCars.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Text(
              'У вас пока нет добавленных автомобилей',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _userCars.length,
            itemBuilder: (context, index) {
              final car = _userCars[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.directions_car_outlined,
                      color: Color(0xFF447BBA),
                      size: 24,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      car.carNumber ?? 'Зона не указана',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _handleDeleteCar(car),
                      tooltip: 'Удалить автомобиль',
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  void _showAddCarDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Добавить автомобиль'),
            content: TextField(
              controller: _carNumberController,
              decoration: const InputDecoration(
                labelText: 'Номер автомобиля',
                hintText: 'Введите номер автомобиля',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _carNumberController.clear();
                },
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: () async {
                  if (_carNumberController.text.isEmpty) {
                    _showMessage('Введите номер автомобиля');
                    return;
                  }

                  try {
                    await _presenter.createCar(_carNumberController.text);
                    if (mounted) {
                      Navigator.of(context).pop();
                      _showMessage(
                        'Автомобиль успешно добавлен',
                        isError: false,
                      );
                    }
                  } catch (e) {
                    showError(e.toString());
                  }
                  _carNumberController.clear();
                },
                child: const Text('Добавить'),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _carNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(),
      body: Center(child: _buildProfileInfo()),
    );
  }
}
