import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var UniqueCode = '0x01';
  var userState = ["I'm Home", "I'm Leaving"];
  List<DeviceInfo> devicesInfo = [];
  bool isLoading = true;
  late bool isBluetoothOn;
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();

  // late DeviceInfo deviceinfo;
  // var IP = "http://13.235.244.236:3000";
  var IP = "https://smart-home-bclfef5zqq-el.a.run.app";

  // final Uri _url = Uri.parse('http://proxy60.rt3.io:37278/');
  final Uri _url = Uri.parse('http://172.20.10.4:5001/video_feed');
  var dio = Dio();
  final firestoreInstance = FirebaseFirestore.instance;
  var orientation, size, height, width;

  void sendResponse(status, deviceID) async {
    await dio.post('${IP}/smartdevices/updatedevice',
        data: {"deviceID": deviceID, "deviceState": status});
  }

  void getLockStatus() async {
    // var s = await Dio().post('${IP}/lock/signIn',
    //     data: {"username": "user1", "password": "password1"});
    // print(s.headers);
    // print(s.statusCode);
    // print(s.headers['set-cookie']);
    var response = await Dio().get(
      '${IP}/smartdevices/getAllDeviceID',
    );
    int defaultLength = response.data.length;
    int index = 0;
    for (Map map in response.data) {
      if (devicesInfo.length < response.data.length) {
        devicesInfo.add(DeviceInfo(map['deviceID'], map['deviceState'],
            map['deviceName'], map['deviceType']));
      }
      if (defaultLength == response.data.length) {
        devicesInfo[index] = DeviceInfo(map['deviceID'], map['deviceState'],
            map['deviceName'], map['deviceType']);
      }
      index++;
    }
    setState(() {
      isLoading = false;
    });
  }

  void _lockRealTimeChanges() {
    firestoreInstance.collection("lockRealTime").snapshots().listen((result) {
      result.docChanges.forEach((res) {
        if (res.type == DocumentChangeType.modified) {
          setState(() {
            getLockStatus();
          });
        }
      });
    });
  }

  bool wrngID = true;
  void _wrongIDNotify() {
    firestoreInstance.collection("wrongID").snapshots().listen((result) {
      result.docChanges.forEach((res) {
        if (res.type == DocumentChangeType.modified && wrngID) {
          wrngID = false;
          displaySnackBar("Invalid ID!  😓");
        }
      });
    });
  }

  void displaySnackBar(String message, {Color color = Colors.red}) {
    SnackBar snackBar = SnackBar(
      content: Text(
        message,
      ),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      duration: Duration(seconds: 1),
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    Future.delayed(const Duration(seconds: 5), () {
      wrngID = true;
    });
  }

  @override
  void initState() {
    super.initState();
    getLockStatus();
    _lockRealTimeChanges();
    _wrongIDNotify();
  }

  @override
  Widget build(BuildContext context) {
    orientation = MediaQuery.of(context).orientation;
    size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 50, horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "My Home",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 35,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFDBDBFC),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    onPressed: () async {
                      FirebaseAuth.instance.signOut();
                      GoogleSignIn().signOut();
                      Navigator.pushNamedAndRemoveUntil(
                          context, "/", (Route<dynamic> route) => false);
                    },
                    icon: Icon(
                      Icons.logout,
                      color: Color(0xFF6171DC),
                      // color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: height / 40,
            ),
            Text(
              "Good Day, !😃",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            SizedBox(
              height: height / 200,
            ),
            Text(
              "Manage your Home",
              style: TextStyle(
                color: Colors.black,
                // fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            SizedBox(
              height: height / 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${devicesInfo.length} Devices",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: height / 50,
            ),
            if (isLoading)
              Center(child: CircularProgressIndicator())
            else
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  itemCount: devicesInfo.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: kIsWeb ? 5 : 2,
                    // crossAxisCount: 2,
                    mainAxisExtent: 100,
                    crossAxisSpacing: 15.0,
                    mainAxisSpacing: 15.0,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () async {
                        HapticFeedback.lightImpact();
                        bool? val = !devicesInfo[index].deviceState!;
                        devicesInfo[index].deviceState =
                            !devicesInfo[index].deviceState!;
                        sendResponse(val, devicesInfo[index].deviceID);
                        setState(() {
                          devicesInfo[index].deviceState = val;
                        });
                      },
                      // child: devicesInfo[index].deviceState!
                      child: CustomDeviceWidget(
                          devicesInfo[index].deviceID,
                          devicesInfo[index].deviceName,
                          devicesInfo[index].deviceType,
                          devicesInfo[index].deviceState,
                          devicesInfo[index].deviceState!
                              ? Color(0xFF6171DC)
                              : Color(0xFFDBDBFC), //0xFFDBDBFC
                          devicesInfo[index].deviceState!
                              ? Colors.white
                              : Color(0xFF6171DC),
                          // nodeID[index]['deviceType']!,
                          index),
                    );
                  },
                ),
              ),
            SizedBox(
              height: height / 35,
            ),
          ],
        ),
      ),
    );
  }
}

class CustomDeviceWidget extends StatefulWidget {
  final String? deviceName;
  final String? deviceID;
  final String? deviceType;
  late bool? deviceStatus;
  final Color widgetColors;
  final Color textColors;
  // final String icon;
  final int index;
  CustomDeviceWidget(
      this.deviceID,
      this.deviceName,
      this.deviceType,
      this.deviceStatus,
      this.widgetColors,
      this.textColors,
      // this.icon,
      this.index);

  @override
  State<CustomDeviceWidget> createState() => _CustomDeviceWidgetState();
}

class _CustomDeviceWidgetState extends State<CustomDeviceWidget> {
  var dio = Dio();
  var IP = "https://smart-home-bclfef5zqq-el.a.run.app";
  void sendResponse(status, deviceID) async {
    await dio.post('${IP}/smartdevices/updatedevice',
        data: {"deviceID": deviceID, "deviceState": status});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 15),
      decoration: BoxDecoration(
        color: widget.widgetColors,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              deviceIconWidget(widget.deviceType, widget.deviceStatus),
              Transform.scale(
                scale: 0.7,
                child: CupertinoSwitch(
                  activeColor: Colors.white54,
                  value: widget.deviceStatus!,
                  onChanged: (val) {},
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                widget.deviceName!,
                style: TextStyle(
                  color: widget.textColors,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              widget.deviceStatus!
                  ? Text(
                      "ON",
                      style: TextStyle(
                        color: widget.textColors,
                        fontSize: 12,
                      ),
                    )
                  : Text(
                      "OFF",
                      style: TextStyle(
                        color: widget.textColors,
                        fontSize: 12,
                      ),
                    ),
            ],
          ),
        ],
      ), //BoxDecoration
    );
  }
}

class deviceIconWidget extends StatelessWidget {
  late String? icon;
  late bool? deviceState;
  deviceIconWidget(this.icon, this.deviceState);

  @override
  Widget build(BuildContext context) {
    Map<bool, Color> iconColoring = {
      true: Colors.white,
      false: Color(0xFF6171DC),
    };
    Map<String, IconData> iconMapping = {
      'lock': CupertinoIcons.lock,
      'lamp': CupertinoIcons.lightbulb,
      'fan': CupertinoIcons.dial_fill,
      'tv': CupertinoIcons.tv,
      'ac': CupertinoIcons.snow
    };
    Map<String, IconData> iconMappings = {
      'lock': CupertinoIcons.lock,
      'lamp': CupertinoIcons.lightbulb,
      'fan': CupertinoIcons.dial_fill,
      'tv': CupertinoIcons.tv,
      'ac': CupertinoIcons.snow
    };
    return Icon(deviceState! ? iconMapping[icon] : iconMappings[icon],
        color: iconColoring[deviceState], size: 50);
  }
}

class DeviceInfo {
  String? deviceID;
  bool? deviceState;
  String? deviceName;
  String? deviceType;

  DeviceInfo(
    this.deviceID,
    this.deviceState,
    this.deviceName,
    this.deviceType,
  );

  DeviceInfo.fromJson(Map<String, dynamic> json) {
    deviceID = json['deviceID'];
    deviceState = json['deviceState'];
    deviceName = json['deviceName'];
    deviceType = json['deviceType'];
  }

  Map<String, dynamic> toJson(Map<dynamic, dynamic> map) {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['deviceID'] = this.deviceID;
    data['deviceState'] = this.deviceState;
    data['deviceName'] = this.deviceName;
    data['deviceType'] = this.deviceType;
    return data;
  }
}
