import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Core Dependencies
import 'core/api/api_consumer.dart';
import 'core/api/api_manager.dart';
import 'core/api/dio_factory.dart';
import 'core/error/error_handler_service.dart';
import 'core/network/network_info.dart';
import 'core/network/network_info_impl.dart';
import 'core/services/cache/dynamic_image_cache_service.dart';
import 'core/services/cache/settings_cache_service.dart';
import 'core/services/cache/token_cache_service.dart';

// Auth Feature Dependencies
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/confirm_email/confirm_email_usecase.dart';
import 'features/auth/domain/usecases/confirm_password_reset/confirm_password_reset_usecase.dart';
import 'features/auth/domain/usecases/confirm_two_factor/confirm_two_factor_usecase.dart';
import 'features/auth/domain/usecases/login/login_usecase.dart';
import 'features/auth/domain/usecases/logout/logout_usecase.dart';
import 'features/auth/domain/usecases/refresh_session/refresh_session_usecase.dart';
import 'features/auth/domain/usecases/register/register_usecase.dart';
import 'features/auth/domain/usecases/request_password_reset/request_password_reset_usecase.dart';
import 'features/auth/domain/usecases/resend_email_confirmation/resend_email_confirmation_usecase.dart';
import 'features/auth/domain/usecases/reset_password/reset_password_usecase.dart';
import 'core/presentation/cubit/app_cubit/app_manager_cubit.dart';
import 'features/auth/presentation/cubit/login_cubit/login_cubit.dart';
import 'features/auth/presentation/cubit/otp_verification_cubit/otp_verification_cubit.dart';
import 'features/auth/presentation/cubit/request_password_reset_cubit/request_password_reset_cubit.dart';
import 'features/auth/presentation/cubit/reset_password_cubit/reset_password_cubit.dart';
import 'features/auth/presentation/cubit/signup_cubit/signup_cubit.dart';

// User Profile Feature Dependencies
import 'features/user_profile/data/datasources/user_remote_data_source.dart';
import 'features/user_profile/data/datasources/user_remote_data_source_impl.dart';
import 'features/user_profile/data/repositories/user_repository_impl.dart';
import 'features/user_profile/domain/repositories/user_repository.dart';
import 'features/user_profile/domain/usecases/get_current_user_details_usecase.dart';
import 'features/user_profile/presentation/cubit/user_profile_cubit.dart';

// Chat Bot Feature Dependencies
import 'features/chat_bot/data/datasources/chat_remote_data_source.dart';
import 'features/chat_bot/data/datasources/chat_remote_data_source_impl.dart';
import 'features/chat_bot/data/repositories/chat_repository_impl.dart';
import 'features/chat_bot/domain/repositories/chat_repository.dart';
import 'features/chat_bot/domain/usecases/delete_chat/delete_chat_usecase.dart';
import 'features/chat_bot/domain/usecases/get_chat_messages/get_chat_messages_usecase.dart';
import 'features/chat_bot/domain/usecases/get_chats/get_chats_usecase.dart';
import 'features/chat_bot/domain/usecases/send_message/send_message_usecase.dart';
import 'features/chat_bot/domain/usecases/update_chat_title/update_chat_title_usecase.dart';
import 'features/chat_bot/presentation/cubit/chat_history/chat_history_cubit.dart';
import 'features/chat_bot/presentation/cubit/chat_messages/chat_message_cubit.dart';

// Exercise Feature Dependencies
import 'features/exercise/data/repositories/exercise_repository_impl.dart';
import 'features/exercise/data/datasources/exercise_local_data_source/exercise_local_data_source.dart';
import 'features/exercise/data/datasources/exercise_local_data_source/exercise_local_data_source_impl.dart';
import 'features/exercise/data/datasources/exercise_remote_data_source/exercise_remote_data_source.dart';
import 'features/exercise/data/datasources/exercise_remote_data_source/exercise_remote_data_source_impl.dart';
import 'features/exercise/domain/repositories/exercise_repository.dart';
import 'features/exercise/domain/usecases/add_exercise_favorite/add_exercise_favorite_usecase.dart';
import 'features/exercise/domain/usecases/add_exercise_history/add_exercise_history_usecase.dart';
import 'features/exercise/domain/usecases/get_exercise_categories/get_exercise_categories_usecase.dart';
import 'features/exercise/domain/usecases/get_exercises/get_exercises_usecase.dart';
import 'features/exercise/domain/usecases/remove_exercise_favorite/remove_exercise_favorite_usecase.dart';
import 'features/exercise/presentation/cubit/exercise_category/exercise_category_cubit.dart';
import 'features/exercise/presentation/cubit/exercise_filter/exercise_filter_cubit.dart';

// Exercise History Feature Dependencies
import 'features/exercise_history/data/datasources/exercise_history_remote_data_source.dart';
import 'features/exercise_history/data/datasources/exercise_history_remote_data_source_impl.dart';
import 'features/exercise_history/data/repositories/exercise_history_repository_impl.dart';
import 'features/exercise_history/domain/repositories/exercise_history_repository.dart';
import 'features/exercise_history/domain/usecases/get_exercise_histories/get_exercise_histories_usecase.dart';

// Navigation
import 'features/main_navigation/presentation/cubit/navigation_cubit/navigation_cubit.dart';


// Create a service locator instance
final sl = GetIt.instance;

/// Initializes all the dependencies for the app.
/// This function is called once when the app starts.
Future<void> init() async {

  
  //############################################################################
  //                                Core
  //############################################################################
  
  // --- API Consumer ---
  sl.registerLazySingleton<ApiConsumer>(() => ApiManager(sl()));

  // --- Network Info ---
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // --- Error Handler ---
  sl.registerLazySingleton(() => ErrorHandlerService());

  // --- Services ---
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => TokenCacheService(sl()));
  sl.registerSingletonAsync<DynamicImageCacheService>(
    () => DynamicImageCacheService.create(apiConsumer: sl()),
  );
  sl.registerLazySingleton(() => SettingsCacheService(sl()));


  //############################################################################
  //                              External
  //############################################################################
  
  sl.registerLazySingleton<Dio>(() => DioFactory(sl()).create());
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton(() => Connectivity());
  
  //############################################################################
  //                          Features - Auth
  //############################################################################

  // --- Presentation (Cubit) ---
  
  sl.registerFactory(() => NavigationCubit());
  sl.registerFactory(() => LoginCubit(sl(), sl(), sl()));
  sl.registerFactory(() => SignupCubit(sl(), sl()));
  sl.registerFactory(() => RequestPasswordResetCubit(sl(), sl()));
  sl.registerFactory(() => OtpVerificationCubit(sl(), sl(), sl(), sl(), sl(), sl()));
  sl.registerFactory(() => ResetPasswordCubit(sl(), sl()));

  // --- Domain (Use Cases) ---
  sl.registerLazySingleton(() => RefreshSessionUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => ConfirmEmailUseCase(sl()));
  sl.registerLazySingleton(() => ResendEmailConfirmationUseCase(sl()));
  sl.registerLazySingleton(() => ConfirmTwoFactorUseCase(sl()));
  sl.registerLazySingleton(() => RequestPasswordResetUseCase(sl()));
  sl.registerLazySingleton(() => ConfirmPasswordResetUseCase(sl()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl()));

  // --- Data (Repository) ---
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl(), sl(), sl()),
  );

  // --- Data (Data Sources) ---
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );

  //############################################################################
  //                       Features - User Profile
  //############################################################################

  // --- Presentation (Cubit) ---
  sl.registerFactory(() => UserProfileCubit(sl()));

  // --- Domain (Use Cases) ---
  sl.registerLazySingleton(() => GetCurrentUserDetailsUseCase(sl()));

  // --- Data (Repository) ---
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(sl(), sl()),
  );

  // --- Data (Data Sources) ---
  sl.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(sl()),
  );
  
  //############################################################################
  //                          Features - ChatBot
  //############################################################################

  // --- Presentation (Cubit) ---
  sl.registerFactory(() => ChatHistoryCubit(
        getChatsUseCase: sl(),
        deleteChatUseCase: sl(),
        updateChatTitleUseCase: sl(),
        errorHandler: sl(),
      ));

  sl.registerFactory<ChatMessagesCubit>(() => ChatMessagesCubit(
        getMessagesUseCase: sl(),
        sendMessageUseCase: sl(),
        errorHandler: sl(),
      ));

  // --- Domain (Use Cases) ---
  sl.registerLazySingleton(() => GetChatsUseCase(sl()));
  sl.registerLazySingleton(() => GetChatMessagesUseCase(sl()));
  sl.registerLazySingleton(() => SendMessageUseCase(sl()));
  sl.registerLazySingleton(() => UpdateChatTitleUseCase(sl()));
  sl.registerLazySingleton(() => DeleteChatUseCase(sl()));

  // --- Data (Repository) ---
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(sl(), sl()),
  );

  // --- Data (Data Sources) ---
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(sl()),
  );

  //############################################################################
  //                          Features - Exercise
  //############################################################################

  // --- Presentation (Cubit) ---
  sl.registerFactory(() => ExerciseCategoryCubit(getExerciseCategoriesUseCase: sl(), errorHandler: sl()));
  sl.registerFactory(() => ExerciseFilterCubit(
        getExercisesUseCase: sl(),
        addExerciseFavoriteUseCase: sl(),
        removeExerciseFavoriteUseCase: sl(),
        errorHandler: sl(),
      ));

  // --- Domain (Use Cases) ---
  sl.registerLazySingleton(() => GetExercisesUseCase(sl()));
  sl.registerLazySingleton(() => GetExerciseCategoriesUseCase(sl()));
  sl.registerLazySingleton(() => AddExerciseHistoryUseCase(sl()));
  sl.registerLazySingleton(() => AddExerciseFavoriteUseCase(sl()));
  sl.registerLazySingleton(() => RemoveExerciseFavoriteUseCase(sl()));

  // --- Data (Repository) ---
  sl.registerLazySingleton<ExerciseRepository>(() => ExerciseRepositoryImpl(
        sl(),
        sl(),
        sl(),
      ));

  // --- Data (Data Sources) ---
  sl.registerLazySingleton<ExerciseRemoteDataSource>(
      () => ExerciseRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<ExerciseLocalDataSource>(
      () => ExerciseLocalDataSourceImpl(sl()));

  //############################################################################
  //                          Features - Exercise History
  //############################################################################

  // --- Domain (Use Cases) ---
  sl.registerLazySingleton(() => GetExerciseHistoriesUseCase(sl()));
  // --- Data (Repository) ---
  sl.registerLazySingleton<ExerciseHistoryRepository>(() => ExerciseHistoryRepositoryImpl(
        sl(),
        sl()
      ));
  // --- Data (Data Sources) ---
  sl.registerLazySingleton<ExerciseHistoryRemoteDataSource>(
      () => ExerciseHistoryRemoteDataSourceImpl(sl()));


  sl.registerSingleton<AppManagerCubit>(AppManagerCubit(
    tokenCacheService: sl(),
    refreshSessionUseCase: sl(),
    logoutUseCase: sl(),
    connectivity: sl(),
    settingsCacheService: sl()
  ));
}
