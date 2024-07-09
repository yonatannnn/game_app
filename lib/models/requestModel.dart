import 'package:cloud_firestore/cloud_firestore.dart';

class RequestModel {
  DateTime date;
  String id;
  String senderId;
  String receiverId;
  int requestNumber;
  String status;

  RequestModel({
    required this.date,
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.requestNumber,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'date':
          Timestamp.fromDate(date), // Convert DateTime to Firestore Timestamp
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'requestNumber': requestNumber,
      'status': status,
    };
  }

  static RequestModel fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    Timestamp timestamp = data['date'] ?? Timestamp.now();
    DateTime realDate = timestamp.toDate();

    return RequestModel(
      date: realDate,
      id: data['id'] ?? '',
      senderId: data['senderId'] ?? '',
      receiverId: data['receiverId'] ?? '',
      requestNumber: data['requestNumber'] ?? 0,
      status: data['status'] ?? '',
    );
  }
}
