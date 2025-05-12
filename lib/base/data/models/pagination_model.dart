class PaginatedResponse<T> {
  final bool status;
  final int errNum;
  final String msg;
  final PaginatedData paginatedData;
  final MetaModel meta;
  final LinksModel links;

  PaginatedResponse({required this.status, required this.errNum, required this.msg, required this.paginatedData, required this.meta, required this.links});

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    String dataKey, // Dynamic key for the data
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final dataJson = json[dataKey] as Map<String, dynamic>;

    return PaginatedResponse<T>(
      status: json['status'] as bool,
      errNum: json['errNum'] as int,
      msg: json['msg'] as String,
      paginatedData: PaginatedData.fromJson(dataJson, fromJsonT),
      meta: MetaModel.fromJson(dataJson['meta']),
      links: LinksModel.fromJson(dataJson['links']),
    );
  }
}

class PaginatedData {
  final List items;

  PaginatedData({required this.items});

  factory PaginatedData.fromJson(Map<String, dynamic> json,  Function(Map<String, dynamic>) fromJsonT) {
    List ito= json['data'].map((item) {
      return fromJsonT(item as Map<String, dynamic>);
    }).toList();
    return PaginatedData(items:ito);
  }
}

class MetaModel {
  final int currentPage;
  final int from;
  final int lastPage;
  final int perPage;
  final int to;
  final int total;

  MetaModel({required this.currentPage, required this.from, required this.lastPage, required this.perPage, required this.to, required this.total});

  factory MetaModel.fromJson(Map<String, dynamic> json) {
    return MetaModel(
      currentPage: json['current_page'] as int,
      from: json['from'] as int,
      lastPage: json['last_page'] as int,
      perPage: json['per_page'] as int,
      to: json['to'] as int,
      total: json['total'] as int,
    );
  }
}

class LinksModel {
  final String first;
  final String last;
  final String? prev;
  final String? next;

  LinksModel({required this.first, required this.last, this.prev, this.next});

  factory LinksModel.fromJson(Map<String, dynamic> json) {
    return LinksModel(first: json['first'] as String, last: json['last'] as String, prev: json['prev'] as String?, next: json['next'] as String?);
  }
}
