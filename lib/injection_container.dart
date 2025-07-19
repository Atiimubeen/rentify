import 'package:get_it/get_it.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Naya import
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rentify/features/auth/presenatation/bloc/auth_bloc.dart';
import 'package:rentify/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:rentify/features/property/presentation/bloc/property_bloc.dart';
import 'package:uuid/uuid.dart'; // Naya import

import 'package:rentify/core/network/network_info.dart';

// --- Auth Feature Imports ---
import 'package:rentify/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:rentify/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:rentify/features/auth/domain/repositories/auth_repository.dart';
import 'package:rentify/features/auth/domain/usecases/get_current_user.dart';
import 'package:rentify/features/auth/domain/usecases/sign_in.dart';
import 'package:rentify/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:rentify/features/auth/domain/usecases/sign_out.dart';
import 'package:rentify/features/auth/domain/usecases/sign_up.dart';

// --- Property Feature Imports (Naya Code) ---
import 'package:rentify/features/property/data/datasources/property_remote_data_source.dart';
import 'package:rentify/features/property/data/repositories/property_repository_impl.dart';
import 'package:rentify/features/property/domain/repositories/property_repository.dart';
import 'package:rentify/features/property/domain/usecases/add_property.dart';
import 'package:rentify/features/property/domain/usecases/get_all_properties.dart';
import 'package:rentify/features/property/domain/usecases/get_properties_by_landlord.dart';

// --- Booking Property Imports -----
import 'package:rentify/features/booking/data/datasources/booking_remote_data_source.dart';
import 'package:rentify/features/booking/data/repositories/booking_repository_impl.dart';
import 'package:rentify/features/booking/domain/repositories/booking_repository.dart';
import 'package:rentify/features/booking/domain/usecases/get_booking_requests_for_landlord.dart';
import 'package:rentify/features/booking/domain/usecases/request_booking.dart';
import 'package:rentify/features/booking/domain/usecases/update_booking_status.dart';
import 'package:rentify/features/booking/presentation/bloc/booking_bloc.dart';

// Chat Screen

import 'package:rentify/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:rentify/features/chat/domain/repositories/chat_repository.dart';
import 'package:rentify/features/chat/domain/usecases/get_messages.dart';
import 'package:rentify/features/chat/domain/usecases/send_message.dart';
import 'package:rentify/features/chat/presentation/bloc/chat_bloc.dart';

//
import 'package:rentify/features/booking/domain/usecases/get_booking_requests_for_tenant.dart';

// --- Profile Feature Imports (Naya Code) ---
import 'package:rentify/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:rentify/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:rentify/features/profile/domain/repositories/profile_repository.dart';
import 'package:rentify/features/profile/domain/usecases/get_user_profile.dart';
import 'package:rentify/features/profile/domain/usecases/update_user_profile.dart';
import 'package:rentify/features/profile/domain/usecases/upload_profile_picture.dart';
import 'package:rentify/features/profile/presentation/bloc/profile_bloc.dart';

// Service Locator
final sl = GetIt.instance;

Future<void> init() async {
  // #############################################
  // # Features - Property (Naya Code)
  // #############################################
  // Usecases
  sl.registerLazySingleton(() => AddProperty(sl()));
  sl.registerLazySingleton(() => GetAllProperties(sl()));
  sl.registerLazySingleton(() => GetPropertiesByLandlord(sl()));
  sl.registerLazySingleton(() => GetBookingRequestsForTenant(sl()));
  // Repository
  sl.registerLazySingleton<PropertyRepository>(
    () => PropertyRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton(() => GetUserProfile(sl()));
  sl.registerLazySingleton(() => UpdateUserProfile(sl()));
  sl.registerLazySingleton(() => UploadProfilePicture(sl()));
  sl.registerFactory(
    () => ProfileBloc(
      getUserProfile: sl(),
      updateUserProfile: sl(),
      uploadProfilePicture: sl(),
    ),
  );
  // Repository
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  // Data sources
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(firestore: sl(), storage: sl()),
  );
  sl.registerLazySingleton(() => SendMessage(sl()));
  sl.registerLazySingleton(() => GetMessages(sl()));
  sl.registerFactory(() => ChatBloc(sendMessage: sl(), getMessages: sl()));
  // Repository
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(firestore: sl()),
  );

  // Data sources
  sl.registerLazySingleton<PropertyRemoteDataSource>(
    () => PropertyRemoteDataSourceImpl(
      firestore: sl(),
      storage: sl(),
      uuid: sl(),
    ),
  );

  // #############################################
  // # Features - Auth
  // #############################################
  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      getCurrentUser: sl(),
      signIn: sl(),
      signUp: sl(),
      signOut: sl(),
      signInWithGoogle: sl(),
    ),
  );

  // Usecases
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  sl.registerLazySingleton(() => SignIn(sl()));
  sl.registerLazySingleton(() => SignUp(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
  sl.registerLazySingleton(() => SignInWithGoogle(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: sl(),
      firestore: sl(),
      googleSignIn: sl(),
    ),
  );

  // ...
  // Bloc
  sl.registerFactory(
    () => PropertyBloc(
      addProperty: sl(),
      getAllProperties: sl(),
      getPropertiesByLandlord: sl(),
      deleteProperty: sl(), // --- YEH LINE ADD KAREIN ---
    ),
  );
  // ...
  // #############################################
  // # Core
  // #############################################
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // #############################################
  // # External
  // #############################################
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseStorage.instance); // Naya Code
  sl.registerLazySingleton(() => GoogleSignIn.instance);
  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton(() => const Uuid());

  // Features Booking
  sl.registerLazySingleton(() => RequestBooking(sl()));
  sl.registerLazySingleton(() => GetBookingRequestsForLandlord(sl()));
  sl.registerLazySingleton(() => UpdateBookingStatus(sl()));
  sl.registerFactory(
    () => BookingBloc(
      requestBooking: sl(),
      getBookingRequestsForLandlord: sl(),
      getBookingRequestsForTenant: sl(),
      updateBookingStatus: sl(),
    ),
  );
  // Repository
  sl.registerLazySingleton<BookingRepository>(
    () => BookingRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  // Data sources
  sl.registerLazySingleton<BookingRemoteDataSource>(
    () => BookingRemoteDataSourceImpl(firestore: sl()),
  );
}
