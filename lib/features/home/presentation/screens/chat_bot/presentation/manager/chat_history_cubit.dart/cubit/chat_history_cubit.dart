import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gradproject/features/auth/presentation/manager/login/login_bloc.dart';
import 'package:gradproject/features/home/presentation/screens/chat_bot/data/models/ai_chat_model.dart';
import 'package:gradproject/features/home/presentation/screens/chat_bot/data/repo/chat_repo_impl.dart';
import 'package:gradproject/features/home/presentation/screens/chat_bot/presentation/manager/chat_history_cubit.dart/cubit/chat_history_state.dart';

class ChatHistoryCubit extends Cubit<ChatHistoryState> {
  final ChatRepository _repository;

  int _page = 1;
  bool _hasNextPage = true;
  bool _isLoading = false;
  String? _currentSearchTerm;
  Timer? _debounce;

  String? get currentSearchTerm => _currentSearchTerm;

  ChatHistoryCubit(this._repository) : super(ChatHistoryInitial());

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }

  void onSearchTermChanged(String searchTerm) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _currentSearchTerm = searchTerm;
    _debounce = Timer(const Duration(milliseconds: 500), () {
      fetchFirstPage(searchTerm: searchTerm);
    });
  }

  Future<void> fetchFirstPage({String? searchTerm}) async {
    _page = 1;
    _hasNextPage = true;
    _currentSearchTerm = searchTerm;
    emit(ChatHistoryLoading());
    await _fetchChats();
  }

  Future<void> fetchNextPage() async {
    if (_isLoading || !_hasNextPage) return;
    _isLoading = true;
    _page++;
    await _fetchChats();
    _isLoading = false;
  }

  Future<void> _fetchChats() async {
    // if (_authCubit.state is ! AuthLoginSuccess) {
    //   emit(const ChatHistoryError("Session expired."));
    //   return;
    // }
    try {
      final response = await _repository.getChats(
          pageIndex: _page, titleSearch: _currentSearchTerm);
      _hasNextPage = response.hasNextPage;

      List<AiChat> currentChats = [];
      if (state is ChatHistoryLoaded && _page > 1) {
        currentChats = (state as ChatHistoryLoaded).chats;
      }

      final newChats = [...currentChats, ...response.chats];
      emit(ChatHistoryLoaded(newChats, _hasNextPage));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        _hasNextPage = false;
        if (_page == 1) {
          emit(const ChatHistoryLoaded([], false));
        } else {
          if (state is ChatHistoryLoaded) {
            final currentState = state as ChatHistoryLoaded;
            emit(ChatHistoryLoaded(currentState.chats, false));
          }
        }
      } else if (e.response?.statusCode != 401) {
        emit(ChatHistoryError(e.message ?? 'An unknown error occurred'));
      }
    } catch (e) {
      emit(ChatHistoryError(e.toString()));
    }
  }

  Future<bool> deleteChat(String chatId) async {
    try {
      await _repository.deleteChat(chatId: chatId);
      if (state is ChatHistoryLoaded) {
        final currentState = state as ChatHistoryLoaded;
        final updatedChats =
            currentState.chats.where((chat) => chat.id != chatId).toList();
        emit(ChatHistoryLoaded(updatedChats, currentState.hasNextPage));
      }
      return true;
    } catch (e) {
      debugPrint("Failed to delete chat: $e");
      return false;
    }
  }

  Future<bool> updateChatTitle(String chatId, String newTitle) async {
    try {
      await _repository.updateChatTitle(chatId: chatId, newTitle: newTitle);
      if (state is ChatHistoryLoaded) {
        final currentState = state as ChatHistoryLoaded;
        final updatedList = List<AiChat>.from(currentState.chats);
        final index = updatedList.indexWhere((c) => c.id == chatId);

        if (index != -1) {
          final oldChat = updatedList[index];
          updatedList[index] = oldChat.copyWith(title: newTitle);
          emit(ChatHistoryLoaded(updatedList, currentState.hasNextPage));
        }
      }
      return true;
    } catch (e) {
      debugPrint("Failed to rename chat: $e");
      return false;
    }
  }

  void refreshList() {
    fetchFirstPage(searchTerm: _currentSearchTerm);
  }
}
