import 'package:equatable/equatable.dart';

class KhatmaProgress extends Equatable {
  final int id;
  final int targetDays;
  final int pagesPerDay;
  final int currentPage;
  final DateTime startDate;
  final DateTime lastUpdate;
  final bool completed;
  
  const KhatmaProgress({
    required this.id,
    required this.targetDays,
    required this.pagesPerDay,
    required this.currentPage,
    required this.startDate,
    required this.lastUpdate,
    this.completed = false,
  });
  
  factory KhatmaProgress.fromMap(Map<String, dynamic> map) {
    return KhatmaProgress(
      id: map['id'],
      targetDays: map['target_days'],
      pagesPerDay: map['pages_per_day'],
      currentPage: map['current_page'],
      startDate: DateTime.fromMillisecondsSinceEpoch(map['start_date']),
      lastUpdate: DateTime.fromMillisecondsSinceEpoch(map['last_update']),
      completed: map['completed'] == 1,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'target_days': targetDays,
      'pages_per_day': pagesPerDay,
      'current_page': currentPage,
      'start_date': startDate.millisecondsSinceEpoch,
      'last_update': lastUpdate.millisecondsSinceEpoch,
      'completed': completed ? 1 : 0,
    };
  }
  
  @override
  List<Object?> get props => [id, currentPage, completed];
}