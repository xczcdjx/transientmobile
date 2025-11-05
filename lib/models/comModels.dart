/*class PageModelEntity{
  int pageNo;
  int pageSize;
  int total;
  PageModelEntity({this.pageNo=1,this.pageSize=10,this.total=0});
}*/
class PageRes<T> {
  int pageNo;
  int pageSize;
  int total;
  T records;

  PageRes({
    required this.pageNo,
    required this.pageSize,
    required this.total,
    required this.records,
  });

  /// fromJson 需要传入解析 T 的方法
  factory PageRes.fromJson(
      Map<String, dynamic> json,
      T Function(dynamic json) fromJsonT,
      ) {
    return PageRes<T>(
      pageNo: json['pageNo'] ?? 1,
      pageSize: json['pageSize'] ?? 10,
      total: json['total'] ?? 0,
      records: fromJsonT(json['records']),
    );
  }

  Map<String, dynamic> toJson(
      dynamic Function(T value) toJsonT,
      ) {
    return {
      'pageNo': pageNo,
      'pageSize': pageSize,
      'total': total,
      'records': toJsonT(records),
    };
  }
}
