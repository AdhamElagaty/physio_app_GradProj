part of 'app_manager_cubit.dart';

enum AuthStatus { authenticated, unauthenticated, guest, loading }
enum ConnectivityStatus { online, offline }

class AppManagerState extends Equatable {
  final AuthStatus authStatus;
  final ConnectivityStatus connectivityStatus;
  final ThemeMode themeMode;
  final Locale locale;
  final bool isLoggingOut;

  const AppManagerState({
    this.authStatus = AuthStatus.loading,
    this.connectivityStatus = ConnectivityStatus.online,
    this.themeMode = ThemeMode.light,
    this.locale = const Locale('en'),
    this.isLoggingOut = false, // <-- ADD DEFAULT VALUE
  });

  AppManagerState copyWith({
    AuthStatus? authStatus,
    ConnectivityStatus? connectivityStatus,
    ThemeMode? themeMode,
    Locale? locale,
    bool? isLoggingOut, // <-- ADD TO COPYWITH
  }) {
    return AppManagerState(
      authStatus: authStatus ?? this.authStatus,
      connectivityStatus: connectivityStatus ?? this.connectivityStatus,
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      isLoggingOut: isLoggingOut ?? this.isLoggingOut, // <-- ADD TO COPYWITH
    );
  }

  @override
  List<Object?> get props => [authStatus, connectivityStatus, themeMode, locale, isLoggingOut]; // <-- ADD TO PROPS
}