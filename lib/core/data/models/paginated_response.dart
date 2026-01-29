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

  // factory PaginatedResponseModel.fromJson(Map<String, dynamic> json) {
  //   final data = json['data'] as Map<String, dynamic>;
  //   return PaginatedResponseModel(
  //     data: data['content'] as List<T>,
  //     pageNumber: data["pageable"]['pageNumber'] != null
  //         ? data["pageable"]['pageNumber'] as int
  //         : 0,
  //     pageSize: data["pageable"]['pageSize'] != null
  //         ? data["pageable"]['pageSize'] as int
  //         : 0,
  //     totalElements: data['totalElements'] != null
  //         ? data['totalElements'] as int
  //         : 0,
  //     totalPages: data['totalPages'] != null ? data['totalPages'] as int : 0,
  //     last: (data['last'] as bool?) ?? true,
  //     numberOfElements: data['numberOfElements'] != null
  //         ? data['numberOfElements'] as int
  //         : 0,
  //   );
  // }

  final List<T> data;
  final int pageNumber;
  final int pageSize;
  final int totalElements;
  final int totalPages;
  final bool last;
  final int numberOfElements;

  int get nextPage => (pageNumber + 1);
}
