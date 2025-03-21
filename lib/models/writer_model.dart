class Writer {
  int? id;
  String name;
  int totalOrders;
  double totalEarnings;

  Writer({
    this.id,
    required this.name,
    required this.totalOrders,
    required this.totalEarnings,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'totalOrders': totalOrders,
      'totalEarnings': totalEarnings,
    };
  }

  factory Writer.fromMap(Map<String, dynamic> map) {
    return Writer(
      id: map['id'],
      name: map['name'],
      totalOrders: map['totalOrders'],
      totalEarnings: map['totalEarnings'],
    );
  }
}
