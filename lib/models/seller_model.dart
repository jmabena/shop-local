///SELLER MODEL FROM ETOM
class SellerModel {
  String? sellerId;
  final String? logoUrl;
  final String? picUrl;
  final String licenseNumber;
  final String organizationName;
  final String organizationType;
  final String organizationDesc;
  bool? hasDeal = false;

  SellerModel({
    this.sellerId,
    required this.logoUrl,
    required this.picUrl,
    required this.organizationName,
    required this.organizationType,
    required this.organizationDesc,
    this.hasDeal,
    required this.licenseNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'logoUrl': logoUrl,
      'picUrl': picUrl,
      'licenseNumber': licenseNumber,
      'organizationName': organizationName,
      'organizationType': organizationType,
      'organizationDesc': organizationDesc,
      'hasDeal': hasDeal,
    };
  }

  factory SellerModel.fromMap(Map<String, dynamic> map,String? sellerId) {
    return SellerModel(
      sellerId: sellerId,
      logoUrl: map['logoUrl'],
      picUrl: map['picUrl'],
      organizationName: map['organizationName'],
      organizationType: map['organizationType'],
      organizationDesc: map['organizationDesc'],
      hasDeal: map['hasDeal'] ?? false,
      licenseNumber: map['licenseNumber'] ?? '',
    );
  }

}
