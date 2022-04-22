class ExpenseUnit {
  String id = '';
  String createdAt = '';
  String updatedAt = '';

  ExpenseUnit fromMap(Map<String, dynamic> map) {
    return ExpenseUnit(
        createdAt: '${map['created_at']}',
        id: '${map['id']}',
        updatedAt: '${map['updated_at']}');
  }

  ExpenseUnit(
      {required this.id, required this.createdAt, required this.updatedAt});
}
