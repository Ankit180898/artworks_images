class Pagination {
  final int total;
  final int limit;
  final int offset;
  final int totalPages;
  final int currentPage;

  Pagination({
    required this.total,
    required this.limit,
    required this.offset,
    required this.totalPages,
    required this.currentPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      total: json['total'] ?? 0,
      limit: json['limit'] ?? 0,
      offset: json['offset'] ?? 0,
      totalPages: json['total_pages'] ?? 0,
      currentPage: json['current_page'] ?? 0,
    );
  }
}
