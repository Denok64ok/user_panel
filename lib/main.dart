import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'di/injection.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/pages/profile_page.dart';
import 'presentation/pages/inspect_zone_page.dart';
import 'data/models/parking_zone_detailed.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  setupDi();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final GoRouter router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HomePage()),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfilePage(),
        ),
        GoRoute(
          path: '/inspect-zone',
          builder: (context, state) {
            final zone = state.extra as ParkingZoneDetailed;
            return InspectZonePage(zone: zone);
          },
        ),
      ],
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [const Locale('ru', 'RU')],
      routerConfig: router,
      title: 'Онлайн парковки',
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}
