import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:letzrentnew/Services/firebase_services.dart';
import 'package:letzrentnew/Utils/constants.dart';
import 'package:letzrentnew/models/user_model.dart';

class ProfileDetails extends StatelessWidget {
  const ProfileDetails({super.key});
  static const routeName = 'pdet';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Profile Details"),
        ),
        body: FutureBuilder<UserModel>(
          future: FirebaseServices().getUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return spinkit;
            } else {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    details('Name', snapshot.data!.name),
                    details('Phone', snapshot.data!.phoneNumber),
                    details('Email', snapshot.data!.email),
                    details('Date Of Birth', snapshot.data!.dob),
                    Spacer(),
                    CupertinoButton(
                      child: Text("Update"),
                      onPressed: () {},
                      color: appColor,
                    )
                  ],
                ),
              );
            }
          },
        ));
  }

  Column details(String title, String body) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: bigHeadingStyle,
        ),
        TextFormField(
          enabled: false,
          initialValue: body,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            )),
          ),

          // controller: additionalInfoController,
          keyboardType: TextInputType.text,
          maxLines: 1,
        ),
        SizedBox(
          height: 10,
        ),
      ],
    );
  }
}
