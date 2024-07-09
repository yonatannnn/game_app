import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:game_app/models/requestModel.dart';

class RequestService {
  final CollectionReference _requestsCollection =
      FirebaseFirestore.instance.collection('Requests');

  Stream<List<RequestModel>> fetchRequests() {
    return _requestsCollection.snapshots().map(
      (snapshot) {
        return snapshot.docs
            .map((doc) => RequestModel.fromFirestore(doc))
            .toList();
      },
    );
  }

  Future<void> sendRequest(RequestModel request) async {
    final existingRequest = await _requestsCollection.doc(request.id).get();

    if (existingRequest.exists) {
      final existingStatus = existingRequest['status'];
      final existingRequestNumber = existingRequest['requestNumber'];

      if (existingStatus == '-') {
        return;
      } else {
        int newRequestNumber = existingRequestNumber + 1;
        RequestModel newRequest = RequestModel(
          date: request.date,
          id: request.id,
          senderId: request.senderId,
          receiverId: request.receiverId,
          requestNumber: newRequestNumber,
          status: request.status,
        );
        await _requestsCollection.doc(existingRequest.id).set(newRequest.toMap());
      }
    } else {
      await _requestsCollection.doc(request.id).set(request.toMap());
    }
  }

  Future<void> updateRequestStatus(String requestId, String status) async {
    await _requestsCollection.doc(requestId).update({'status': status});
  }
}
