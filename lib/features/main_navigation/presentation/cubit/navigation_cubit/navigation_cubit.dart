import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../domain/navigation_tab.dart';

part 'navigation_state.dart';

class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit() : super(NavigationState.initial());

  final List<NavigationTab> _refreshedTabs = const [
    NavigationTab.settings,
  ];

  void changeTab(int index) {
    final selectedTab = NavigationTab.values[index];
    final updatedPages = List<Widget>.from(state.pages);

    if (_refreshedTabs.contains(selectedTab)) {
      updatedPages[index] = selectedTab.page;
    }

    emit(state.copyWith(
      index: index,
      pages: updatedPages,
    ));
  }
}
