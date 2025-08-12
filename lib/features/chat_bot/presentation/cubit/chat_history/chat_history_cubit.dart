import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

import '../../../../../core/error/error_handler_service.dart';
import '../../../../../core/error/failure.dart';
import '../../../domain/entities/chat.dart';
import '../../../domain/usecases/delete_chat/delete_chat_usecase.dart';
import '../../../domain/usecases/get_chats/get_chats_params.dart';
import '../../../domain/usecases/get_chats/get_chats_usecase.dart';
import '../../../domain/usecases/update_chat_title/update_chat_title_params.dart';
import '../../../domain/usecases/update_chat_title/update_chat_title_usecase.dart';

part 'chat_history_state.dart';

class ChatHistoryCubit extends Cubit<ChatHistoryState> {
  final GetChatsUseCase _getChatsUseCase;
  final DeleteChatUseCase _deleteChatUseCase;
  final UpdateChatTitleUseCase _updateChatTitleUseCase;
  final ErrorHandlerService _errorHandler;

  int _page = 1;
  String? _currentSearchTerm;
  Timer? _debounce;
  
  final TextEditingController searchController;
  final ScrollController scrollController = ScrollController();

  String? get currentSearchTerm => _currentSearchTerm;

  ChatHistoryCubit({
    required GetChatsUseCase getChatsUseCase,
    required DeleteChatUseCase deleteChatUseCase,
    required UpdateChatTitleUseCase updateChatTitleUseCase,
    required ErrorHandlerService errorHandler,
  })  : _getChatsUseCase = getChatsUseCase,
        _deleteChatUseCase = deleteChatUseCase,
        _updateChatTitleUseCase = updateChatTitleUseCase,
        _errorHandler = errorHandler,
        searchController = TextEditingController(),
        super(const ChatHistoryState()) {
    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      fetchNextPage();
    }
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    searchController.dispose();
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
    _currentSearchTerm = searchTerm;
    if (searchController.text != (searchTerm ?? '')) {
      searchController.text = searchTerm ?? '';
    }
    
    emit(state.copyWith(
      status: ChatHistoryStatus.loading,
      chats: [],
      hasNextPage: true,
      clearErrorMessage: true,
    ));
    await _fetchChats();
  }

  Future<void> fetchNextPage() async {
    if (state.status == ChatHistoryStatus.loading ||
        state.status == ChatHistoryStatus.loadingMore ||
        !state.hasNextPage) {
      return;
    }

    emit(state.copyWith(status: ChatHistoryStatus.loadingMore));
    _page++;
    await _fetchChats();
  }

  Future<void> _fetchChats() async {
    final result = await _getChatsUseCase(
      GetChatsParams(pageIndex: _page, titleSearch: _currentSearchTerm),
    );

    result.fold(
      (failure) {
        if (failure is NotFoundFailure && _page > 1) {
          emit(state.copyWith(hasNextPage: false, status: ChatHistoryStatus.loaded));
        } else {
          final friendlyMessage = _errorHandler.getMessageFromFailure(failure);
          if (_page > 1) {
            _page--;
            emit(state.copyWith(
              status: ChatHistoryStatus.loaded,
              errorMessage: friendlyMessage,
            ));
          } else {
            emit(state.copyWith(status: ChatHistoryStatus.error, errorMessage: friendlyMessage));
          }
        }
      },
      (paginatedResult) {
        final currentChats = (_page > 1) ? state.chats : <Chat>[];
        final newChats = [...currentChats, ...paginatedResult.items];
        emit(state.copyWith(
          status: ChatHistoryStatus.loaded,
          chats: newChats,
          hasNextPage: paginatedResult.hasNextPage,
          clearErrorMessage: true,
        ));
      },
    );
  }

  Future<bool> deleteChat(String chatId) async {
    final originalChats = List<Chat>.from(state.chats);
    final updated = originalChats.where((c) => c.id != chatId).toList();
    emit(state.copyWith(chats: updated));

    final result = await _deleteChatUseCase(chatId);

    return result.fold(
      (failure) {
        debugPrint("Failed to delete chat: ${failure.message}");
        emit(state.copyWith(chats: originalChats));
        return false;
      },
      (_) => true,
    );
  }

  Future<bool> updateChatTitle(String chatId, String newTitle) async {
    final result = await _updateChatTitleUseCase(
      UpdateChatTitleParams(chatId: chatId, newTitle: newTitle),
    );
    return result.fold(
      (failure) {
        debugPrint("Failed to rename chat: ${failure.message}");
        return false;
      },
      (_) {
        final updatedList = List<Chat>.from(state.chats);
        final index = updatedList.indexWhere((c) => c.id == chatId);
        if (index != -1) {
          updatedList[index] = updatedList[index].copyWith(
            title: newTitle,
          );
          emit(state.copyWith(chats: updatedList));
        }
        return true;
      },
    );
  }

  void addOrUpdateChat(Chat chat) {
    final currentChats = List<Chat>.from(state.chats);
    final index = currentChats.indexWhere((c) => c.id == chat.id);

    if (index != -1) {
      currentChats.removeAt(index);
      currentChats.insert(0, chat);
    } else {
      currentChats.insert(0, chat);
    }

    emit(state.copyWith(chats: currentChats));
  }

  void refreshList() {
    fetchFirstPage(searchTerm: _currentSearchTerm);
  }
}
