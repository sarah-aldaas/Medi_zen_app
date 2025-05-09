class MetaModel {
  final String? currentPage;
  final String? from;
  final String? lastPage;
  final String? perPage;
  final String? to;
  final String? total;

  MetaModel({this.currentPage, this.from, this.lastPage, this.perPage, this.to, this.total});

  factory MetaModel.fromJson(Map<String, dynamic> json) {
    return MetaModel(
      currentPage: json['current_page']?.toString(),
      from: json['from']?.toString(),
      lastPage: json['last_page']?.toString(),
      perPage: json['per_page']?.toString(),
      to: json['to']?.toString(),
      total: json['total']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'current_page': currentPage, 'from': from, 'last_page': lastPage, 'per_page': perPage, 'to': to, 'total': total};
  }
}

class LinksModel {
  final String? first;
  final String? last;
  final String? prev;
  final String? next;

  LinksModel({this.first, this.last, this.prev, this.next});

  factory LinksModel.fromJson(Map<String, dynamic> json) {
    return LinksModel(first: json['first']?.toString(), last: json['last']?.toString(), prev: json['prev']?.toString(), next: json['next']?.toString());
  }

  Map<String, dynamic> toJson() {
    return {'first': first, 'last': last, 'prev': prev, 'next': next};
  }
}
