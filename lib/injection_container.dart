import 'package:get_it/get_it.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rentify/features/auth/presenatation/bloc/auth_bloc.dart';
import 'package:rentify/features/booking/presentation/bloc/booking_event.dart';
import 'package:uuid/uuid.dart';

import 'package:rentify/core/network/network_info.dart';

// Auth Imports
import 'package:rentify/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:rentify/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:rentify/features/auth/domain/repositories/auth_repository.dart';
import 'package:rentify/features/auth/domain/usecases/get_current_user.dart';
import 'package:rentify/features/auth/domain/usecases/sign_in.dart';
import 'package:rentify/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:rentify/features/auth/domain/usecases/sign_out.dart';
import 'package:rentify/features/auth/domain/usecases/sign_up.dart';

// Property Imports
import 'package:rentify/features/property/data/datasources/property_remote_data_source.dart';
import 'package:rentify/features/property/data/repositories/property_repository_impl.dart';
import 'package:rentify/features/property/domain/repositories/property_repository.dart';
import 'package:rentify/features/property/domain/usecases/add_property.dart';
import 'package:rentify/features/property/domain/usecases/delete_property.dart';
import 'package:rentify/features/property/domain/usecases/get_all_properties.dart';
import 'package:rentify/features/property/domain/usecases/get_properties_by_landlord.dart';
import 'package:rentify/features/property/domain/usecases/get_property_by_id.dart';
import 'package:rentify/features/property/domain/usecases/update_property_availability.dart';
import 'package:rentify/features/property/presentation/bloc/property_bloc.dart';

// Booking Imports
import 'package:rentify/features/booking/data/datasources/booking_remote_data_source.dart';
import 'package:rentify/features/booking/data/repositories/booking_repository_impl.dart';
import 'package:rentify/features/booking/domain/repositories/booking_repository.dart';
import 'package:rentify/features/booking/domain/usecases/get_booking_requests_for_landlord.dart';
import 'package:rentify/features/booking/domain/usecases/get_booking_requests_for_tenant.dart';
import 'package:rentify/features/booking/domain/usecases/request_booking.dart';
import 'package:rentify/features/booking/domain/usecases/update_booking_status.dart';
import 'package:rentify/features/booking/presentation/bloc/booking_bloc.dart';

// Chat Imports
import 'package:rentify/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:rentify/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:rentify/features/chat/domain/repositories/chat_repository.dart';
import 'package:rentify/features/chat/domain/usecases/get_messages.dart';
import 'package:rentify/features/chat/domain/usecases/send_message.dart';
import 'package:rentify/features/chat/presentation/bloc/chat_bloc.dart';

// Profile Imports
import 'package:rentify/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:rentify/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:rentify/features/profile/domain/repositories/profile_repository.dart';
import 'package:rentify/features/profile/domain/usecases/get_user_profile.dart';
import 'package:rentify/features/profile/domain/usecases/update_user_profile.dart';
import 'package:rentify/features/profile/domain/usecases/upload_profile_picture.dart';
import 'package:rentify/features/profile/presentation/bloc/profile_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // BLoCs
  sl.registerFactory(
    () => AuthBloc(
      getCurrentUser: sl(),
      signIn: sl(),
      signUp: sl(),
      signOut: sl(),
      signInWithGoogle: sl(),
    ),
  );
  sl.registerFactory(
    () => PropertyBloc(
      addProperty: sl(),
      getAllProperties: sl(),
      getPropertiesByLandlord: sl(),
      deleteProperty: sl(),
      getPropertyById: sl(),
    ),
  );
  sl.registerFactory(
    () => BookingBloc(
      requestBooking: sl(),
      getBookingRequestsForLandlord: sl(),
      getBookingRequestsForTenant: sl(),
      updateBookingStatus: sl(),
      updatePropertyAvailability: sl(),
      cancelBooking: sl(),
    ),
  );
  sl.registerFactory(() => ChatBloc(sendMessage: sl(), getMessages: sl()));
  sl.registerFactory(
    () => ProfileBloc(
      getUserProfile: sl(),
      updateUserProfile: sl(),
      uploadProfilePicture: sl(),
    ),
  );

  // Use Cases
  // Auth
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  sl.registerLazySingleton(() => SignIn(sl()));
  sl.registerLazySingleton(() => SignUp(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
  sl.registerLazySingleton(() => SignInWithGoogle(sl()));
  // Property
  sl.registerLazySingleton(() => AddProperty(sl()));
  sl.registerLazySingleton(() => GetAllProperties(sl()));
  sl.registerLazySingleton(() => GetPropertiesByLandlord(sl()));
  sl.registerLazySingleton(() => DeleteProperty(sl()));
  sl.registerLazySingleton(
    () => UpdatePropertyAvailability(sl()),
  ); // <<< YEH SIRF EK BAAR HONA CHAHIYE
  sl.registerLazySingleton(() => GetPropertyById(sl()));
  // Booking
  sl.registerLazySingleton(() => RequestBooking(sl()));
  sl.registerLazySingleton(() => GetBookingRequestsForLandlord(sl()));
  sl.registerLazySingleton(() => GetBookingRequestsForTenant(sl()));
  sl.registerLazySingleton(() => UpdateBookingStatus(sl()));
  sl.registerLazySingleton(() => CancelBookingEvent(sl()));
  // Chat
  sl.registerLazySingleton(() => SendMessage(sl()));
  sl.registerLazySingleton(() => GetMessages(sl()));
  // Profile
  sl.registerLazySingleton(() => GetUserProfile(sl()));
  sl.registerLazySingleton(() => UpdateUserProfile(sl()));
  sl.registerLazySingleton(() => UploadProfilePicture(sl()));

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<PropertyRepository>(
    () => PropertyRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<BookingRepository>(
    () => BookingRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: sl(),
      firestore: sl(),
      googleSignIn: sl(),
    ),
  );
  sl.registerLazySingleton<PropertyRemoteDataSource>(
    () => PropertyRemoteDataSourceImpl(
      firestore: sl(),
      storage: sl(),
      uuid: sl(),
    ),
  );
  sl.registerLazySingleton<BookingRemoteDataSource>(
    () => BookingRemoteDataSourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(firestore: sl(), storage: sl()),
  );

  // Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // External
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseStorage.instance);
  sl.registerLazySingleton(() => GoogleSignIn.instance);
  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton(() => const Uuid());
}
