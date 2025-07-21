import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:rentify/features/auth/presenatation/bloc/auth_bloc.dart';
import 'package:rentify/features/auth/presenatation/bloc/auth_event.dart';
import 'package:rentify/features/auth/presenatation/bloc/auth_state.dart';
import 'package:rentify/features/auth/presenatation/pages/sign_in_page.dart';

import 'package:rentify/features/booking/presentation/bloc/booking_bloc.dart';
import 'package:rentify/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:rentify/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:rentify/features/property/presentation/bloc/property_bloc.dart';
import 'package:rentify/features/property/presentation/pages/home_page.dart';
import 'package:rentify/features/property/presentation/pages/landlord_dashboard_page.dart';
// <<< YEH IMPORT ZAROORI HAI
import 'injection_container.dart' as di;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase ko initialize karte waqt options dena zaroori hai
  await Firebase.initializeApp(
    // <<< YEH LINE THEEK KI GAYI HAI
  );

  // Push Notifications ki ijazat lena
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
        // Har BlocProvider ko uski type batana zaroori hai
        BlocProvider<AuthBloc>(
          create: (_) => di.sl<AuthBloc>()..add(CheckAuthStatusEvent()),
        ),
        BlocProvider<PropertyBloc>(create: (_) => di.sl<PropertyBloc>()),
        BlocProvider<BookingBloc>(create: (_) => di.sl<BookingBloc>()),
        BlocProvider<ChatBloc>(create: (_) => di.sl<ChatBloc>()),
        BlocProvider<ProfileBloc>(create: (_) => di.sl<ProfileBloc>()),
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
            // --- YAHAN NAAM THEEK KIYA GAYA HAI ---
            return LandlordDashboardPage(user: state.user);
          }
          // Default for tenant
          return const HomePage();
        }
        // For any other state (Unauthenticated, Loading, Error)
        return const SignInPage();
      },
    );
  }
}
