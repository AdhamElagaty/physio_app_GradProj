part of 'navigation_cubit.dart';

class NavigationState extends Equatable {
  final int index;
  final List<Widget> pages;

  const NavigationState({
    required this.index,
    required this.pages,
  });

  factory NavigationState.initial() {
    final initialPages = NavigationTab.values.map((tab) => tab.page).toList();
    return NavigationState(
      index: 0,
      pages: initialPages,
    );
  }

  NavigationState copyWith({
    int? index,
    List<Widget>? pages,
  }) {
    return NavigationState(
      index: index ?? this.index,
      pages: pages ?? this.pages,
    );
  }

  @override
  List<Object> get props => [index, pages];
}
