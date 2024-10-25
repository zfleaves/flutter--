import 'dart:convert';

class Product {  
  String id;  
  String title;  
  String cid;  
  int price;  
  String old_price;  
  int is_best;  
  String is_hot;  
  String is_new;  
  List<Attribute> attr;  
  String status;  
  String pic;  
  String content;  
  String cname;  
  int salecount;  
  String sub_title;  
  
  //新增
  int count;
  String selectedAttr;
  
  Product({  
    required this.id,  
    required this.title,  
    required this.cid,  
    required this.price,  
    required this.old_price,  
    required this.is_best,  
    required this.is_hot,  
    required this.is_new,  
    required this.attr,  
    required this.status,  
    required this.pic,  
    required this.content,  
    required this.cname,  
    required this.salecount,  
    required this.sub_title, 
    required this.count,
    required this.selectedAttr 
  });  
  
  factory Product.fromJson(String str) => Product.fromMap(jsonDecode(str));  
  
  factory Product.fromMap(Map<String, dynamic> json) {  
    return Product(  
      id: json['_id'],  
      title: json['title'],  
      cid: json['cid'],  
      price: json['price'],  
      old_price: json['old_price'],  
      is_best: json['is_best'],  
      is_hot: json['is_hot'],  
      is_new: json['is_new'],  
      attr: List<Attribute>.from(json['attr'].map((x) => Attribute.fromMap(x))),  
      status: json['status'],  
      pic: json['pic'],  
      content: json['content'],  
      cname: json['cname'],  
      salecount: json['salecount'],  
      sub_title: json['sub_title'],  
      //新增
      count: 1,
      selectedAttr: ''
    );  
  }  
}  
  
class Attribute {  
  String cate;  
  List<String> list;  
  List<Map> attrList;
  
  Attribute({  
    required this.cate,  
    required this.list,  
    required this.attrList,
  });  
  
  factory Attribute.fromMap(Map<String, dynamic> json) {  
    return Attribute(  
      cate: json['cate'],  
      list: List<String>.from(json['list']),  
      attrList: [],
    );  
  }  
} 