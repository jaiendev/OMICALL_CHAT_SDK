import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:livetalk_sdk/entity/entity.dart';
import 'package:livetalk_sdk/livetalk_sdk.dart';
import 'package:livetalk_sdk_example/chat_screen.dart';
import 'package:livetalk_sdk_example/dialog/dialog.dart';

class CreateUserFormScreen extends StatefulWidget {
  const CreateUserFormScreen({Key? key}) : super(key: key);

  // var phoneNumber = "";
  @override
  State<StatefulWidget> createState() {
    return _CreateUserFormState();
  }
}

String uuid = "0967884005";

class _CreateUserFormState extends State<CreateUserFormScreen> {
  //video
  late final TextEditingController _userNameController = TextEditingController()
    ..text = "N 0967884005";
  late final TextEditingController _phoneController = TextEditingController()
    ..text = uuid;
  late final TextEditingController _emailController = TextEditingController()
    ..text = '';

  bool _isAutoExpired = false;

  TextStyle basicStyle = const TextStyle(
    color: Colors.white,
    fontSize: 16,
  );

  Gradient gradient4 = LinearGradient(
    colors: [
      Colors.black.withOpacity(0.8),
      Colors.grey[500]!.withOpacity(0.8),
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  @override
  void initState() {
    super.initState();
    requestFCM();
  }

  Future<void> requestFCM() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: false,
      badge: false,
      sound: false,
    );
    final token = await FirebaseMessaging.instance.getToken();
    debugPrint(token);
    FirebaseMessaging.onMessage.listen((event) {
      //have message on foreground => by pass notification
      debugPrint(event.data.toString());
    });
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create User Form'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _userNameController,
              keyboardType: TextInputType.name,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.person),
                labelText: "User Name",
                enabledBorder: myInputBorder(),
                focusedBorder: myFocusBorder(),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.password),
                labelText: "Phone",
                enabledBorder: myInputBorder(),
                focusedBorder: myFocusBorder(),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.cleaning_services),
                labelText: "Email",
                enabledBorder: myInputBorder(),
                focusedBorder: myFocusBorder(),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(
                top: 16,
              ),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isAutoExpired = !_isAutoExpired;
                  });
                },
                child: Row(
                  children: [
                    Icon(
                      _isAutoExpired
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                      size: 24,
                      color: _isAutoExpired ? Colors.blue : Colors.grey,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Text(
                      "Auto Expired",
                      style: TextStyle(
                        fontSize: 16,
                        color: _isAutoExpired ? Colors.blue : Colors.grey,
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            GestureDetector(
              onTap: () async {
                FocusScope.of(context).unfocus();
                try {
                  EasyLoading.show();
                  final fcm = await FirebaseMessaging.instance.getToken();
                  final result = await LiveTalkSdk.shareInstance.createRoom(
                      phone: _phoneController.text,
                      fullName: _userNameController.text,
                      uuid: _phoneController.text,
                      autoExpired: _isAutoExpired,
                      fcm: fcm,
                      projectId: "omicrm-6558a");
                  EasyLoading.dismiss();
                  if (result != null && context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChatScreen(),
                      ),
                    );
                  }
                } catch (error) {
                  EasyLoading.dismiss();
                  if (error is LiveTalkError) {
                    if (!context.mounted) return;
                    showCustomDialog(
                      context: context,
                      message: error.message["message"] as String,
                    );
                  }
                }
              },
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.teal,
                      Colors.teal[200]!,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      offset: Offset(5, 5),
                      blurRadius: 10,
                    )
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Chat',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

OutlineInputBorder myInputBorder() {
  return const OutlineInputBorder(
    borderRadius: BorderRadius.all(
      Radius.circular(30),
    ),
    borderSide: BorderSide(
      color: Colors.redAccent,
      width: 3,
    ),
  );
}

OutlineInputBorder myFocusBorder() {
  return const OutlineInputBorder(
    borderRadius: BorderRadius.all(
      Radius.circular(30),
    ),
    borderSide: BorderSide(
      color: Colors.greenAccent,
      width: 3,
    ),
  );
}
