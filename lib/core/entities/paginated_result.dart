class PaginatedResult<T> {
  final List<T> items;
  final bool hasNextPage;
  final bool hasPreviousPage;

  PaginatedResult({
    required this.items,
    required this.hasNextPage,
    this.hasPreviousPage = false,
  });
}