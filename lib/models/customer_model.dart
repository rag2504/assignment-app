class Customer {
  int? id;
  String name;
  String orderDate;
  String dueDate;
  String projectType;
  double totalAmount;
  double advancePaid;
  double balanceAmount;
  String paymentMode;
  String receivedBy;
  String writerAssigned;
  String customerContact;
  String writerContact;

  Customer({
    this.id,
    required this.name,
    required this.orderDate,
    required this.dueDate,
    required this.projectType,
    required this.totalAmount,
    required this.advancePaid,
    required this.balanceAmount,
    required this.paymentMode,
    required this.receivedBy,
    required this.writerAssigned,
    required this.customerContact,
    required this.writerContact,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'orderDate': orderDate,
      'dueDate': dueDate,
      'projectType': projectType,
      'totalAmount': totalAmount,
      'advancePaid': advancePaid,
      'balanceAmount': balanceAmount,
      'paymentMode': paymentMode,
      'receivedBy': receivedBy,
      'writerAssigned': writerAssigned,
      'customerContact': customerContact,
      'writerContact': writerContact,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'],
      name: map['name'],
      orderDate: map['orderDate'],
      dueDate: map['dueDate'],
      projectType: map['projectType'],
      totalAmount: map['totalAmount'],
      advancePaid: map['advancePaid'],
      balanceAmount: map['balanceAmount'],
      paymentMode: map['paymentMode'],
      receivedBy: map['receivedBy'],
      writerAssigned: map['writerAssigned'],
      customerContact: map['customerContact'],
      writerContact: map['writerContact'],
    );
  }
}
