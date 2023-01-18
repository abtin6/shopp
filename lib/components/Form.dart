import 'package:flutter/material.dart';
import 'package:persian_numbers/persian_numbers.dart';
import 'package:shopapp/components/InputField.dart';
import 'package:validators/validators.dart';

class FormContainer extends StatelessWidget {
  final formkey;
  final telOnSaved;
  final passwordOnSaved;
  FormContainer({@required this.formkey, this.telOnSaved, this.passwordOnSaved});
  @override
  Widget build(BuildContext context) {
    return Container(
      //margin: const EdgeInsets.symmetric(horizontal: 20),
      //padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: <Widget>[
          Form(
            key: formkey,
            child: Column(
              children: <Widget>[
                InputFieldArea(
                  onSaved: telOnSaved,maxLines: 1,
                  hint: 'شماره موبایل', obscure: false, icon: Icons.phone_android,
                  // ignore: missing_return
                  validator: (String value) {
                    var val = PersianNumbers.toEnglish(value);
                    if(!RegExp(r"09(0[0-9]|1[0-9]|2[0-9]|3[0-9]|9[0-9])-?[0-9]{3}-?[0-9]{4}").hasMatch(val)) {
                    return 'فرمت شماره موبایل صحیح نیست';
                  }}
                ),
                InputFieldArea(
                    onSaved: passwordOnSaved,maxLines: 1,
                    hint: 'کلمه عبور', obscure: true, icon: Icons.lock_open,
                    // ignore: missing_return
                    validator: (String value) {
                      var val = PersianNumbers.toEnglish(value);
                      if(val.length < 4) {
                      return 'طول پسورد حداقل 4 کاراکتر دارد';
                    }}
                    ),
              ],
            )
          )
        ],
      ),
    );
  }
}