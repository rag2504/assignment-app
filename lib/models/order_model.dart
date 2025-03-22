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
  bool isCompleted; // Change to bool

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
    required this.isCompleted, // Required named parameter
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderDate': orderDate,
      'dueDate': dueDate,
      'customerName': customerName,
      'customerContact': customerContact,
      'projectType': projectType,
      'totalAmount': totalAmount,
      'advancePaid': advancePaid,
      'balanceAmount': balanceAmount,
      'paymentMode': paymentMode,
      'receivedBy': receivedBy,
      'writerAssigned': writerAssigned,
      'pages': pages,
      'isCompleted': isCompleted ? 1 : 0, // Convert bool to int
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      orderDate: map['orderDate'],
      dueDate: map['dueDate'],
      customerName: map['customerName'],
      customerContact: map['customerContact'],
      projectType: map['projectType'],
      totalAmount: map['totalAmount'],
      advancePaid: map['advancePaid'],
      balanceAmount: map['balanceAmount'],
      paymentMode: map['paymentMode'],
      receivedBy: map['receivedBy'],
      writerAssigned: map['writerAssigned'],
      pages: map['pages'],
      isCompleted: map['isCompleted'] == 1, // Convert int to bool
    );
  }
}