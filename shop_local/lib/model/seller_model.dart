class SellerModel {
  final String sellerId;
  final String logoUrl;
  final String picUrl;
  final String licenseNumber;
  final String organizationName;
  final String organizationType;
  final String organizationDesc;

  SellerModel({
    required this.sellerId,
    required this.logoUrl,
    required this.picUrl,
    required this.licenseNumber,
    required this.organizationName,
    required this.organizationType,
    required this.organizationDesc,
  });

  Map<String, dynamic> toMap() {
    return {
      'sellerId': sellerId,
      'logoUrl': logoUrl,
      'picUrl': picUrl,
      'licenseNumber': licenseNumber,
      'organizationName': organizationName,
      'organizationType': organizationType,
      'organizationDesc': organizationDesc,
    };
  }

  factory SellerModel.fromMap(Map<String, dynamic> map) {
    return SellerModel(
      sellerId: map['sellerId'] ?? '',
      logoUrl: map['logoUrl'] ?? '',
      picUrl: map['picUrl'] ?? '',
      licenseNumber: map['licenseNumber'] ?? '',
      organizationName: map['organizationName'] ?? '',
      organizationType: map['organizationType'] ?? '',
      organizationDesc: map['organizationDesc'] ?? '',
    );
  }

}

