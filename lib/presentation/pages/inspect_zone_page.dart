import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:user_panel/presentation/widgets/header.dart';
import '../../data/models/camera_snapshot.dart';
import '../../data/models/parking_zone_detailed.dart';
import '../../data/models/parking_place.dart';
import '../../data/models/car_user.dart';
import '../../data/models/booking_create.dart';
import '../../data/models/booking_detailed.dart';
import '../../data/models/user.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
import '../presenters/inspect_zone_presenter.dart';

class InspectZonePage extends StatefulWidget {
  final ParkingZoneDetailed zone;

  const InspectZonePage({Key? key, required this.zone}) : super(key: key);

  @override
  State<InspectZonePage> createState() => _InspectZonePageState();
}

class _InspectZonePageState extends State<InspectZonePage>
    implements InspectZoneView {
  final _storage = const FlutterSecureStorage();
  late InspectZonePresenter _presenter;
  bool _isLoading = false;
  CameraSnapshot? _snapshot;
  List<ParkingPlace> _places = [];
  List<CarUser> _userCars = [];
  User? _user;

  // Booking form state
  CarUser? _selectedCar;
  ParkingPlace? _selectedPlace;
  DateTime? _startTime;
  DateTime? _endTime;

  @override
  void initState() {
    super.initState();
    _presenter = GetIt.I.get<InspectZonePresenter>(param1: this);
    _presenter.loadMarkedZoneImage(widget.zone.id);
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final token = await _storage.read(key: 'access_token');
    if (token != null) {
      try {
        final useCase = GetIt.I.get<GetUserProfileUseCase>();
        _user = await useCase.execute(token);
        _presenter.loadUserCars(_user!.id, token);
        _presenter.loadPlaces(widget.zone.id);
      } catch (e) {
        showError('Не удалось загрузить данные пользователя');
      }
    }
  }

  Future<void> _selectDateTime(bool isStartTime) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (date != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        final dateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );

        setState(() {
          if (isStartTime) {
            _startTime = dateTime;
          } else {
            _endTime = dateTime;
          }
        });
      }
    }
  }

  Future<void> _createBooking() async {
    if (_selectedCar == null ||
        _selectedPlace == null ||
        _startTime == null ||
        _endTime == null) {
      showError('Пожалуйста, заполните все поля');
      return;
    }

    if (_endTime!.isBefore(_startTime!)) {
      showError('Время окончания должно быть позже времени начала');
      return;
    }

    final token = await _storage.read(key: 'access_token');
    if (token == null) {
      showError('Необходимо авторизоваться');
      return;
    }

    final booking = BookingCreate(
      carUserId: _selectedCar!.id,
      startTime: DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(_startTime!),
      endTime: DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(_endTime!),
      parkingPlaceId: _selectedPlace!.id,
      bookingStatusId: 1,
    );

    _presenter.createBooking(booking, 'Bearer $token');
  }

  @override
  void showLoading() {
    setState(() {
      _isLoading = true;
    });
  }

  @override
  void hideLoading() {
    setState(() {
      _isLoading = false;
    });
  }

  void _showMessage(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[700] : Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  void showError(String message) {
    if (message.toLowerCase().contains('already booked') ||
        message.toLowerCase().contains('место занято')) {
      _showMessage('Это место уже забронировано');
    } else if (message.toLowerCase().contains('network') ||
        message.toLowerCase().contains('connection')) {
      _showMessage('Проверьте подключение к интернету');
    } else if (message.toLowerCase().contains('unauthorized')) {
      _showMessage('Необходимо авторизоваться');
    } else if (message.toLowerCase().contains('invalid time') ||
        message.toLowerCase().contains('invalid date')) {
      _showMessage('Неверно указано время бронирования');
    } else if (message.toLowerCase().contains('place not found')) {
      _showMessage('Выбранное место больше недоступно');
    }
  }

  @override
  void updateSnapshot(CameraSnapshot snapshot) {
    setState(() {
      _snapshot = snapshot;
    });
  }

  @override
  void showPlaces(List<ParkingPlace> places) {
    setState(() {
      _places = places.where((place) => place.placeStatusId != 2).toList();
    });
  }

  @override
  void showUserCars(List<CarUser> cars) {
    setState(() {
      _userCars = cars;
    });
  }

  @override
  void onBookingCreated(BookingDetailed booking) {
    _showMessage('Бронирование успешно создано', isError: false);
    setState(() {
      _selectedCar = null;
      _selectedPlace = null;
      _startTime = null;
      _endTime = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        widget.zone.zoneName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF447BBA),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.zone.address,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  Container(
                    padding: const EdgeInsets.all(24),
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
                      children: [
                        if (_snapshot != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              base64Decode(_snapshot!.image),
                              fit: BoxFit.contain,
                            ),
                          )
                        else
                          const Text(
                            'Нет доступных изображений',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed:
                              () => _presenter.loadMarkedZoneImage(
                                widget.zone.id,
                              ),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Обновить изображение'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF447BBA),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_user != null) ...[
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(24),
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
                        const Text(
                          'Создать бронирование',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF447BBA),
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<CarUser>(
                          value: _selectedCar,
                          decoration: InputDecoration(
                            labelText: 'Выберите автомобиль',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFF447BBA),
                              ),
                            ),
                          ),
                          items:
                              _userCars.map((car) {
                                return DropdownMenuItem(
                                  value: car,
                                  child: Text(
                                    car.carNumber ?? 'Номер не указан',
                                  ),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCar = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<ParkingPlace>(
                          value: _selectedPlace,
                          decoration: InputDecoration(
                            labelText: 'Выберите место',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFF447BBA),
                              ),
                            ),
                          ),
                          items:
                              _places.map((place) {
                                return DropdownMenuItem(
                                  value: place,
                                  child: Text('Место ${place.placeNumber}'),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedPlace = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                readOnly: true,
                                decoration: InputDecoration(
                                  labelText: 'Дата и время начала',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF447BBA),
                                    ),
                                  ),
                                  suffixIcon: const Icon(
                                    Icons.calendar_today,
                                    color: Color(0xFF447BBA),
                                  ),
                                ),
                                controller: TextEditingController(
                                  text:
                                      _startTime != null
                                          ? DateFormat(
                                            'dd.MM.yyyy HH:mm',
                                          ).format(_startTime!)
                                          : '',
                                ),
                                onTap: () => _selectDateTime(true),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                readOnly: true,
                                decoration: InputDecoration(
                                  labelText: 'Дата и время окончания',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF447BBA),
                                    ),
                                  ),
                                  suffixIcon: const Icon(
                                    Icons.calendar_today,
                                    color: Color(0xFF447BBA),
                                  ),
                                ),
                                controller: TextEditingController(
                                  text:
                                      _endTime != null
                                          ? DateFormat(
                                            'dd.MM.yyyy HH:mm',
                                          ).format(_endTime!)
                                          : '',
                                ),
                                onTap: () => _selectDateTime(false),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _createBooking,
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
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                    : const Text(
                                      'Создать бронирование',
                                      style: TextStyle(fontSize: 16),
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
