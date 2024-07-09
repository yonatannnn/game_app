import 'package:flutter/material.dart';
import 'package:game_app/models/requestModel.dart';
import 'package:game_app/services/requestService.dart';
import 'package:game_app/widgets/singleRequestWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReceivedRequestsLists extends StatefulWidget {
  @override
  State<ReceivedRequestsLists> createState() => _ReceivedRequestsListsState();
}

class _ReceivedRequestsListsState extends State<ReceivedRequestsLists> {
  final RequestService requestService = RequestService();
  late String username;

  @override
  void initState() {
    super.initState();
    loadUsername();
  }

  Future<void> loadUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<RequestModel>>(
      stream: requestService.fetchRequests(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        List<RequestModel>? requests = snapshot.data;

        if (requests == null || requests.isEmpty) {
          return Center(child: Text('No requests found.'));
        }

        List<RequestModel> receivedRequests = requests
            .where((request) => request.receiverId == username)
            .toList();

        if (receivedRequests.isEmpty) {
          return Center(child: Text('No received requests found.'));
        }

        return ListView.separated(
          itemCount: receivedRequests.length,
          separatorBuilder: (BuildContext context, int index) => Divider(),
          itemBuilder: (context, index) {
            RequestModel request = receivedRequests[index];
            return SingleRequestWidget(isSender: false, request: request);
          },
        );
      },
    );
  }
}
