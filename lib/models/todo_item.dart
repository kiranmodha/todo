import 'package:hive/hive.dart';

part 'todo_item.g.dart';

// generate Hive adapter using following command
//flutter packages pub run build_runner build

@HiveType(typeId: 0)
class TodoItem extends HiveObject {
  @HiveField(0)
  String toBeDone;

  @HiveField(1)
  bool isDone;

  @HiveField(2)
  DateTime dueDate;

  @HiveField(3)
  String note;

  @HiveField(4)
  bool? isDeleted;

  @HiveField(5)
  String? documentID;

  @HiveField(6)
  bool? isSyncedWithCloud;

  TodoItem(
      {required this.toBeDone,
      required this.isDone,
      required this.dueDate,
      required this.note,
      this.isDeleted,
      this.documentID,
      this.isSyncedWithCloud});

  Map<String, dynamic> toJson() {
    return {
      'toBeDone': toBeDone,
      'isDone': isDone,
      'dueDate': dueDate.toIso8601String(),
      'note': note,
      'isDeleted': isDeleted ?? false,
      'documentID': documentID ?? "",
      'isSyncedWithCloud': isSyncedWithCloud ?? false
    };
  }

  /// For cloud - documentId and isSyncedWithCloud are not required
  Map<String, dynamic> toJsonForCloud() {
    return {
      'toBeDone': toBeDone,
      'isDone': isDone,
      'dueDate': dueDate.toIso8601String(),
      'note': note,
      'isDeleted': isDeleted ?? false
    };
  }

  static TodoItem fromJson(Map<String, dynamic> json) {
    return TodoItem(
        toBeDone: json['toBeDone'],
        isDone: json['isDone'],
        dueDate: DateTime.parse(json['dueDate']),
        note: json['note'],
        isDeleted: json['isDeleted'] ?? false,
        documentID: json['documentID'] ?? "",
        isSyncedWithCloud: json['isSyncedWithCloud'] ?? false);
  }

  // ToString Method
  @override
  String toString() {
    return 'TodoItem{toBeDone: $toBeDone, isDone: $isDone, dueDate: $dueDate, note: $note, isDeleted: $isDeleted, documentID: $documentID, isSyncedWithCloud: $isSyncedWithCloud}';
  }


  TodoItem copyWith({
    String? toBeDone,
    bool? isDone,
    DateTime? dueDate,
    String? note,
    bool? isDeleted,
    String? documentID,
    bool? isSyncedWithCloud,
  }) {
    return TodoItem(
      toBeDone: toBeDone ?? this.toBeDone,
      isDone: isDone ?? this.isDone,
      dueDate: dueDate ?? this.dueDate,
      note: note ?? this.note,
      isDeleted: isDeleted ?? this.isDeleted,
      documentID: documentID ?? this.documentID,
      isSyncedWithCloud: isSyncedWithCloud ?? this.isSyncedWithCloud,
    );
  }
}
