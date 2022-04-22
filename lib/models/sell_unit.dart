class ContactUnit {
  String contactId = '';
  String id = '';
  String name = '';
  String contactStatus = '';
  String email = '';
  String mobile = '';
  String addressLine_1 = '';
  String addressLine_2 = '';
  String payTermNumber = '';
  String taxNumber = '';
  String creditLimit = '';
  String balance = '';
  String createdAt = '';
  String updatedAt = '';

  ContactUnit fromMap(Map<String, dynamic> map) {
    return ContactUnit(
        contactId: '${map['contact_id']}',
        name: '${map['name']}',
        contactStatus: '${map['contact_status']}',
        email: '${map['email']}',
        mobile: '${map['mobile']}',
        addressLine_1: '${map['addressLine_1']}',
        addressLine_2: '${map['addressLine_2']}',
        payTermNumber: '${map['pay_term_number']}',
        taxNumber: '${map['tax_number']}',
        creditLimit: '${map['credit_limit']}',
        balance: '${map['balance']}',
        createdAt: '${map['created_at']}',
        id: '${map['id']}',
        updatedAt: '${map['updated_at']}');
  }

  ContactUnit(
      {required this.contactId,
      required this.name,
      required this.id,
      required this.contactStatus,
      required this.email,
      required this.mobile,
      required this.addressLine_1,
      required this.addressLine_2,
      required this.payTermNumber,
      required this.taxNumber,
      required this.creditLimit,
      required this.balance,
      required this.createdAt,
      required this.updatedAt});
}
