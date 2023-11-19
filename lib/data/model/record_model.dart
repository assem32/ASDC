class RecordModel{
  String ?senderId;
  String ?recordUrl;
  String ?date;
  RecordModel({this.senderId,
    this.recordUrl
    ,
    this.date
  }
      );
  RecordModel.fromJson(Map<dynamic,dynamic>json){
    senderId=json['senderId'];
    recordUrl=json['recordUrl'];
    date=json['date'];

  }
  Map<dynamic,dynamic>toMap(){
    return {
      'senderId':senderId,
      'recordUrl':recordUrl,
      'date':date,
    };
  }
}