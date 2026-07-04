/// Generic API response wrapper.
///
/// Standardizes API response parsing across all features.
library;

import 'package:rug/core/types/typedefs.dart';

class ApiResponse<T> {

  /// Creates from a JSON response with a custom data parser.
  factory ApiResponse.fromJson(
    JSON json,
    T Function(dynamic data)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? true,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : null,
      message: json['message'] as String?,
      errorCode: json['error_code'] as String?,
      meta: json['meta'] != null
          ? PaginationMeta.fromJson(json['meta'] as JSON)
          : null,
    );
  }
  const ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.errorCode,
    this.meta,
  });

  final bool success;
  final T? data;
  final String? message;
  final String? errorCode;
  final PaginationMeta? meta;

  /// Returns true if the response indicates an error.
  bool get isError => !success;
}

/// Pagination metadata from API responses.
class PaginationMeta {

  factory PaginationMeta.fromJson(JSON json) {
    return PaginationMeta(
      currentPage: json['current_page'] as int? ?? 1,
      totalPages: json['total_pages'] as int? ?? 1,
      totalItems: json['total_items'] as int? ?? 0,
      perPage: json['per_page'] as int? ?? 20,
    );
  }
  const PaginationMeta({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.perPage,
  });

  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int perPage;

  bool get hasNextPage => currentPage < totalPages;
  bool get hasPreviousPage => currentPage > 1;
}
