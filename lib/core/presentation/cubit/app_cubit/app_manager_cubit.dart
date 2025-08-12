import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../features/auth/domain/usecases/logout/logout_usecase.dart';
import '../../../../features/auth/domain/usecases/refresh_session/refresh_session_usecase.dart';
import '../../../services/cache/settings_cache_service.dart';
import '../../../services/cache/token_cache_service.dart';
import '../../../usecase/usecase.dart';

part 'app_manager_state.dart';

class AppManagerCubit extends Cubit<AppManagerState> {
  final TokenCacheService _tokenCacheService;
  final SettingsCacheService _settingsService;
  final RefreshSessionUseCase _refreshSessionUseCase;
  final LogoutUseCase _logoutUseCase;
  final Connectivity _connectivity;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  AppManagerCubit({
    required TokenCacheService tokenCacheService,
    required SettingsCacheService settingsCacheService,
    required RefreshSessionUseCase refreshSessionUseCase,
    required LogoutUseCase logoutUseCase,
    required Connectivity connectivity,
  })  : _tokenCacheService = tokenCacheService,
        _settingsService = settingsCacheService,
        _refreshSessionUseCase = refreshSessionUseCase,
        _logoutUseCase = logoutUseCase,
        _connectivity = connectivity,
        super(AppManagerState(
          themeMode: settingsCacheService.loadTheme(),
          locale: settingsCacheService.loadLocale(),
        ));

  Future<void> init() async {
    _listenForConnectivityChanges();

    await _checkUserAuthentication();
  }

  void _listenForConnectivityChanges() {
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);
  }

  Future<void> _onConnectivityChanged(List<ConnectivityResult> result) async {
    final bool isOffline = result.contains(ConnectivityResult.none);
    
    if (isOffline) {
      emit(state.copyWith(connectivityStatus: ConnectivityStatus.offline));
    } else {
      emit(state.copyWith(connectivityStatus: ConnectivityStatus.online));
      if (state.authStatus == AuthStatus.unauthenticated) {
         _checkUserAuthentication();
      }
    }
  }

  Future<void> _checkUserAuthentication() async {
    emit(state.copyWith(authStatus: AuthStatus.loading));
    try {
      final hasToken = await _tokenCacheService.hasToken();
      if (!hasToken) {
        emit(state.copyWith(authStatus: AuthStatus.unauthenticated));
        return;
      }

      final isRefreshTokenExpired = await _tokenCacheService.isRefreshTokenExpired();
      if (isRefreshTokenExpired) {
        await _tokenCacheService.clearTokens();
        emit(state.copyWith(authStatus: AuthStatus.unauthenticated));
        return;
      }
      
      final isAccessTokenExpired = await _tokenCacheService.isAccessTokenExpired();
      if (isAccessTokenExpired) {
        final connectivityResult = await _connectivity.checkConnectivity();
        if (connectivityResult.contains(ConnectivityResult.none)) {
            emit(state.copyWith(authStatus: AuthStatus.authenticated));
            return;
        }

        final result = await _refreshSessionUseCase(NoParams());
        result.fold(
          (failure) => sessionExpired(),
          (loginSuccess) {
            _tokenCacheService.saveTokens(
              accessToken: loginSuccess.user.token.value,
              accessTokenExpiresOn: loginSuccess.user.token.expiresOn,
              refreshToken: loginSuccess.user.refreshToken.value,
              refreshTokenExpiresOn: loginSuccess.user.refreshToken.expiresOn,
            );
            emit(state.copyWith(authStatus: AuthStatus.authenticated));
          },
        );
      } else {
        emit(state.copyWith(authStatus: AuthStatus.authenticated));
      }
    } catch (e) {
      await _tokenCacheService.clearTokens();
      emit(state.copyWith(authStatus: AuthStatus.unauthenticated));
    }
  }


  void userLoggedIn() {
    emit(state.copyWith(authStatus: AuthStatus.authenticated));
  }
  
  void userGuest() {
     emit(state.copyWith(authStatus: AuthStatus.guest));
  }

  Future<void> logout() async {
    emit(state.copyWith(isLoggingOut: true));
    
    await _logoutUseCase(NoParams());
    await _tokenCacheService.clearTokens();

    emit(state.copyWith(
      authStatus: AuthStatus.unauthenticated, 
      isLoggingOut: false
    ));
  }

  void sessionExpired() async {
    await _tokenCacheService.clearTokens();
    emit(state.copyWith(authStatus: AuthStatus.unauthenticated));
  }
  
  Future<void> changeTheme(ThemeMode themeMode) async {
    await _settingsService.saveTheme(themeMode);
    emit(state.copyWith(themeMode: themeMode));
  }

  Future<void> changeLocale(Locale locale) async {
    await _settingsService.saveLocale(locale);
    emit(state.copyWith(locale: locale));
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }
}
