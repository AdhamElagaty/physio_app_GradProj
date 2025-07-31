import 'package:equatable/equatable.dart';

class GetChatsParams extends Equatable {
  final int pageIndex;
  final int pageSize;
  final String? titleSearch;

  const GetChatsParams({
    required this.pageIndex,
    this.pageSize = 15,
    this.titleSearch,
  });

  @override
  List<Object?> get props => [pageIndex, pageSize, titleSearch];
}
