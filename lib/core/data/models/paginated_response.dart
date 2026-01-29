class PaginatedResponseModel<T> {
  PaginatedResponseModel({
    required this.data,
    required this.pageNumber,
    required this.pageSize,
    required this.totalElements,
    required this.totalPages,
    required this.last,
    required this.numberOfElements,
  });

  factory PaginatedResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final todos = (json['todos'] as List)
        .map((item) => fromJsonT(item as Map<String, dynamic>))
        .toList();

    return PaginatedResponseModel(
      data: todos,
      pageNumber: 0, // The API doesn't provide page number
      pageSize: json['limit'] as int? ?? 10,
      totalElements: json['total'] as int? ?? 0,
      totalPages: ((json['total'] as int? ?? 0) / (json['limit'] as int? ?? 10))
          .ceil(),
      last:
          (json['skip'] as int? ?? 0) + todos.length >=
          (json['total'] as int? ?? 0),
      numberOfElements: todos.length,
    );
  }

  final List<T> data;
  final int pageNumber;
  final int pageSize;
  final int totalElements;
  final int totalPages;
  final bool last;
  final int numberOfElements;

  int get nextPage => (pageNumber + 1);
}
