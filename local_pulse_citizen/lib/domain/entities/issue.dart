import 'package:equatable/equatable.dart';
import 'geo_location.dart';

class Issue extends Equatable {
  final String id;
  final String title;
  final String description;
  final String category;
  final String subcategory;
  final String priority;
  final String status;
  final GeoLocation location;
  final List<String> images;
  final String reporterId;
  final String? assignedTo;
  final String? department;
  final DateTime? estimatedResolution;
  final DateTime? actualResolution;
  final IssueFeedback? feedback;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Issue({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.subcategory,
    required this.priority,
    required this.status,
    required this.location,
    required this.images,
    required this.reporterId,
    this.assignedTo,
    this.department,
    this.estimatedResolution,
    this.actualResolution,
    this.feedback,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        category,
        subcategory,
        priority,
        status,
        location,
        images,
        reporterId,
        assignedTo,
        department,
        estimatedResolution,
        actualResolution,
        feedback,
        createdAt,
        updatedAt,
      ];

  Issue copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? subcategory,
    String? priority,
    String? status,
    GeoLocation? location,
    List<String>? images,
    String? reporterId,
    String? assignedTo,
    String? department,
    DateTime? estimatedResolution,
    DateTime? actualResolution,
    IssueFeedback? feedback,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Issue(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      location: location ?? this.location,
      images: images ?? this.images,
      reporterId: reporterId ?? this.reporterId,
      assignedTo: assignedTo ?? this.assignedTo,
      department: department ?? this.department,
      estimatedResolution: estimatedResolution ?? this.estimatedResolution,
      actualResolution: actualResolution ?? this.actualResolution,
      feedback: feedback ?? this.feedback,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Validation methods
  bool get isValidTitle {
    return title.trim().length >= 5 && title.trim().length <= 100;
  }

  bool get isValidDescription {
    return description.trim().length >= 10 && description.trim().length <= 1000;
  }

  bool get hasImages {
    return images.isNotEmpty;
  }

  bool get isValidImageCount {
    return images.length <= 5; // Maximum 5 images
  }

  // Status checks
  bool get isSubmitted => status == 'submitted';
  bool get isAcknowledged => status == 'acknowledged';
  bool get isInProgress => status == 'in_progress';
  bool get isResolved => status == 'resolved';
  bool get isClosed => status == 'closed';
  bool get isRejected => status == 'rejected';

  bool get isOpen => isSubmitted || isAcknowledged || isInProgress;
  bool get isCompleted => isResolved || isClosed;

  // Priority checks
  bool get isLowPriority => priority == 'low';
  bool get isMediumPriority => priority == 'medium';
  bool get isHighPriority => priority == 'high';
  bool get isEmergency => priority == 'emergency';

  // Category checks
  bool get isDailyLife => category == 'daily_life';
  bool get isEmergencyCategory => category == 'emergency';
  bool get isGeneral => category == 'general';

  // Time calculations
  Duration get age => DateTime.now().difference(createdAt);
  
  Duration? get resolutionTime {
    if (actualResolution != null) {
      return actualResolution!.difference(createdAt);
    }
    return null;
  }

  bool get isOverdue {
    if (estimatedResolution == null) return false;
    return DateTime.now().isAfter(estimatedResolution!) && !isCompleted;
  }

  bool get needsEscalation {
    return age.inDays >= 7 && isOpen;
  }

  // Complete validation
  bool get isValid {
    return isValidTitle &&
        isValidDescription &&
        isValidImageCount &&
        category.isNotEmpty &&
        subcategory.isNotEmpty &&
        priority.isNotEmpty &&
        status.isNotEmpty &&
        reporterId.isNotEmpty;
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'subcategory': subcategory,
      'priority': priority,
      'status': status,
      'location': location.toJson(),
      'images': images,
      'reporterId': reporterId,
      'assignedTo': assignedTo,
      'department': department,
      'estimatedResolution': estimatedResolution?.toIso8601String(),
      'actualResolution': actualResolution?.toIso8601String(),
      'feedback': feedback?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Issue.fromJson(Map<String, dynamic> json) {
    return Issue(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      subcategory: json['subcategory'] ?? '',
      priority: json['priority'] ?? '',
      status: json['status'] ?? '',
      location: GeoLocation.fromJson(json['location'] ?? {}),
      images: List<String>.from(json['images'] ?? []),
      reporterId: json['reporterId'] ?? '',
      assignedTo: json['assignedTo'],
      department: json['department'],
      estimatedResolution: json['estimatedResolution'] != null
          ? DateTime.parse(json['estimatedResolution'])
          : null,
      actualResolution: json['actualResolution'] != null
          ? DateTime.parse(json['actualResolution'])
          : null,
      feedback: json['feedback'] != null
          ? IssueFeedback.fromJson(json['feedback'])
          : null,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class IssueFeedback extends Equatable {
  final int rating;
  final String? comment;
  final DateTime submittedAt;

  const IssueFeedback({
    required this.rating,
    this.comment,
    required this.submittedAt,
  });

  @override
  List<Object?> get props => [rating, comment, submittedAt];

  IssueFeedback copyWith({
    int? rating,
    String? comment,
    DateTime? submittedAt,
  }) {
    return IssueFeedback(
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      submittedAt: submittedAt ?? this.submittedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'comment': comment,
      'submittedAt': submittedAt.toIso8601String(),
    };
  }

  factory IssueFeedback.fromJson(Map<String, dynamic> json) {
    return IssueFeedback(
      rating: json['rating'] ?? 0,
      comment: json['comment'],
      submittedAt: DateTime.parse(json['submittedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}