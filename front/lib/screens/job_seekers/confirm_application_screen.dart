import 'package:flutter/material.dart';

class ConfirmApplicationScreen extends StatefulWidget {

  final String jobId;

  const ConfirmApplicationScreen({super.key, required this.jobId});

  @override
  State<ConfirmApplicationScreen> createState() => _ConfirmApplicationScreenState();
}

class _ConfirmApplicationScreenState extends State<ConfirmApplicationScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/jobDetails', arguments: widget.jobId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffbfbcf3),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                color: Color(0xfff1feac),
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(58),
              ),
              child: Center(
                child: Icon(
                  Icons.check,
                  size: 55,
                ),
              ),
            ),
            SizedBox(height: 35,),
            Text(
              'Application sent',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700
              ),
            ),
            SizedBox(height: 8,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_outlined,
                  size: 30,
                ),
                SizedBox(width: 10,),
                Text(
                  'Wait for the confirmation',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
