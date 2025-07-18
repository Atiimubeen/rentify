import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentify/features/auth/presenatation/bloc/auth_bloc.dart';
import 'package:rentify/features/auth/presenatation/bloc/auth_event.dart';
import 'package:rentify/features/auth/presenatation/bloc/auth_state.dart';
import 'package:rentify/features/auth/presenatation/pages/sign_in_page.dart';
import 'package:rentify/features/booking/presentation/bloc/booking_bloc.dart';
import 'package:rentify/features/property/presentation/bloc/property_bloc.dart';
import 'package:rentify/features/property/presentation/pages/home_page.dart';
import 'package:rentify/features/property/presentation/pages/landlord_dashboard_page.dart';

import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final fcm = FirebaseMessaging.instance;
  await fcm.requestPermission();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => di.sl<AuthBloc>()..add(CheckAuthStatusEvent()),
        ),
        BlocProvider(create: (_) => di.sl<PropertyBloc>()),
        BlocProvider(create: (_) => di.sl<BookingBloc>()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Rentify',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          if (state.user.role == 'landlord') {
            return LandlordDashboardPage(user: state.user);
          }
          return const HomePage(); // Default for tenant
        }
        return const SignInPage();
      },
    );
  }
}
