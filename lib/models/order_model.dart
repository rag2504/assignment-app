class Order {
  int? id;
  String orderDate;
  String dueDate;
  String customerName;
  String customerContact;
  String projectType;
  double totalAmount;
  double advancePaid;
  double balanceAmount;
  String paymentMode;
  String receivedBy;
  String writerAssigned;
  int pages;
  bool isCompleted;
  String? details;

  Order({
    this.id,
    required this.orderDate,
    required this.dueDate,
    required this.customerName,
    required this.customerContact,
    required this.projectType,
    required this.totalAmount,
    required this.advancePaid,
    required this.balanceAmount,
    required this.paymentMode,
    required this.receivedBy,
    required this.writerAssigned,
    required this.pages,
    this.isCompleted = false,
    this.details,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id?.toString(),  // Ensure ID is a string
      'orderDate': orderDate,
      'dueDate': dueDate,
      'customerName': customerName,
      'customerContact': customerContact,
      'projectType': projectType,
      'totalAmount': totalAmount.toString(),  // Convert to string
      'advancePaid': advancePaid.toString(),  // Convert to string
      'balanceAmount': balanceAmount.toString(),  // Convert to string
      'paymentMode': paymentMode,
      'receivedBy': receivedBy,
      'writerAssigned': writerAssigned,
      'pages': pages.toString(),  // Convert to string
      'isCompleted': isCompleted ? 1 : 0,
      'details': details,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    double parseDouble(dynamic value) {
      if (value is String && value.isNotEmpty) {
        return double.tryParse(value) ?? 0.0;
      } else if (value is double) {
        return value;
      } else {
        return 0.0;
      }
    }

    int parseInt(dynamic value) {
      if (value is String && value.isNotEmpty) {
        return int.tryParse(value) ?? 0;
      } else if (value is int) {
        return value;
      } else {
        return 0;
      }
    }

    return Order(
      id: map['id'] != null ? int.tryParse(map['id'].toString()) : null,
      orderDate: map['orderDate'] ?? '',
      dueDate: map['dueDate'] ?? '',
      customerName: map['customerName'] ?? '',
      customerContact: map['customerContact'] ?? '',
      projectType: map['projectType'] ?? '',
      totalAmount: parseDouble(map['totalAmount']),
      advancePaid: parseDouble(map['advancePaid']),
      balanceAmount: parseDouble(map['balanceAmount']),
      paymentMode: map['paymentMode'] ?? '',
      receivedBy: map['receivedBy'] ?? '',
      writerAssigned: map['writerAssigned'] ?? '',
      pages: parseInt(map['pages']),
      isCompleted: map['isCompleted'] == 1 || map['isCompleted'] == true,
      details: map['details'],
    );
  }
}