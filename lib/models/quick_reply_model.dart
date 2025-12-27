/// Quick Reply Model - Represents a single quick reply message
class QuickReplyModel {
  final String id;
  final String message;
  final String category;
  final DateTime createdDate;
  final int usageCount;

  QuickReplyModel({
    required this.id,
    required this.message,
    required this.category,
    required this.createdDate,
    this.usageCount = 0,
  });

  /// Create from JSON map
  factory QuickReplyModel.fromJson(Map<String, dynamic> json) {
    return QuickReplyModel(
      id: json['id'] as String,
      message: json['message'] as String,
      category: json['category'] as String,
      createdDate: DateTime.parse(json['createdDate'] as String),
      usageCount: json['usageCount'] as int? ?? 0,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'category': category,
      'createdDate': createdDate.toIso8601String(),
      'usageCount': usageCount,
    };
  }

  /// Create copy with updated fields
  QuickReplyModel copyWith({
    String? id,
    String? message,
    String? category,
    DateTime? createdDate,
    int? usageCount,
  }) {
    return QuickReplyModel(
      id: id ?? this.id,
      message: message ?? this.message,
      category: category ?? this.category,
      createdDate: createdDate ?? this.createdDate,
      usageCount: usageCount ?? this.usageCount,
    );
  }

  /// Generate unique ID
  static String generateId() {
    return 'qr_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }
}
