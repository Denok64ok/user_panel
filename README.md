# Пользовательская панель для умных парковок

Мобильное приложение на Flutter для пользователей системы умных парковок. Позволяет находить свободные парковочные места, бронировать их и управлять своими автомобилями.

## Основные функции

- 🔐 Авторизация и регистрация пользователей
- 🗺️ Интерактивная карта парковочных зон
- 🚗 Управление личными автомобилями
- 🅿️ Бронирование парковочных мест
- 📸 Просмотр состояния парковки через камеры
- 🔍 Поиск парковок по адресу
- 📍 Поиск ближайшей парковки
- 📱 Адаптивный интерфейс

## Технологии

- Flutter (версия ^3.7.2)
- Clean Architecture
- MVP Pattern
- Dependency Injection (get_it)
- REST API (retrofit)
- OpenStreetMap (flutter_map)
- Secure Storage

## Требования

- Flutter SDK (версия ^3.7.2)
- Dart SDK
- IDE (рекомендуется VS Code или Android Studio)

## Установка и запуск

1. Клонируйте репозиторий:
```bash
git clone https://github.com/your-username/user_panel.git
cd user_panel
```

2. Установите зависимости:
```bash
flutter pub get
```

3. Запустите приложение:
```bash
# Для веб-версии
flutter run -d chrome

# Для Android
flutter run -d android

# Для iOS
flutter run -d ios
```

## Сборка релиза

```bash
# Для Android
flutter build apk --release

# Для iOS
flutter build ios --release

# Для веб
flutter build web --release
```

## Структура проекта

```
lib/
├── data/           # Слой данных
│   ├── models/     # Модели данных
│   ├── repositories/ # Репозитории
│   └── services/   # Сервисы API
├── domain/         # Бизнес-логика
│   └── usecases/   # Use cases
├── presentation/   # UI слой
│   ├── pages/      # Страницы
│   ├── presenters/ # Презентеры
│   └── widgets/    # Виджеты
└── di/             # Внедрение зависимостей
```

## Особенности архитектуры

- Clean Architecture для четкого разделения слоев
- MVP Pattern для управления UI и бизнес-логикой
- Repository Pattern для работы с данными
- Dependency Injection для управления зависимостями

## Основные страницы

- **Главная страница**: Карта с парковочными зонами
- **Профиль**: Управление личными данными и автомобилями
- **Осмотр зоны**: Детальная информация о парковке и бронирование

## Безопасность

- Защищенное хранение токенов (flutter_secure_storage)
- Аутентификация для всех операций
- Валидация данных на клиенте
- Безопасная передача данных через HTTPS

## Тестирование

```bash
# Запуск тестов
flutter test

# Запуск тестов с покрытием
flutter test --coverage
```

## Вклад в проект

1. Создайте форк проекта
2. Создайте ветку для новой функции (`git checkout -b feature/amazing-feature`)
3. Зафиксируйте изменения (`git commit -m 'Add amazing feature'`)
4. Отправьте изменения в ветку (`git push origin feature/amazing-feature`)
5. Откройте Pull Request

## Лицензия

MIT License
