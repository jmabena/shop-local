///SELLER MODEL FROM ETOM
class SellerModel {
  final String sellerId;
  final String? logoUrl;
  final String? picUrl;
  final String organizationName;
  final String organizationType;
  final String organizationDesc;

  SellerModel({
    required this.sellerId,
    required this.logoUrl,
    required this.picUrl,
    required this.organizationName,
    required this.organizationType,
    required this.organizationDesc,
  });

  Map<String, dynamic> toMap() {
    return {
      'sellerId': sellerId,
      'logoUrl': logoUrl,
      'picUrl': picUrl,
      'organizationName': organizationName,
      'organizationType': organizationType,
      'organizationDesc': organizationDesc,
    };
  }

  factory SellerModel.fromMap(Map<String, dynamic> map) {
    return SellerModel(
      sellerId: map['sellerId'],
      logoUrl: map['logoUrl'],
      picUrl: map['picUrl'],
      organizationName: map['organizationName'],
      organizationType: map['organizationType'],
      organizationDesc: map['organizationDesc'],
    );
  }

}
