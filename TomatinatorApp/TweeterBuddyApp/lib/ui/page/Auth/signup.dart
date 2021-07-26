import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/helper/constant.dart';
import 'package:flutter_twitter_clone/helper/enum.dart';
import 'package:flutter_twitter_clone/helper/utility.dart';
import 'package:flutter_twitter_clone/model/user.dart';
import 'package:flutter_twitter_clone/state/authState.dart';
import 'package:flutter_twitter_clone/ui/page/Auth/widget/googleLoginButton.dart';
import 'package:flutter_twitter_clone/ui/page/Auth/widget/twitterLoginButton.dart';
import 'package:flutter_twitter_clone/ui/theme/theme.dart';
import 'package:flutter_twitter_clone/widgets/customFlatButton.dart';
import 'package:flutter_twitter_clone/widgets/customWidgets.dart';
import 'package:flutter_twitter_clone/widgets/newWidget/customLoader.dart';
import 'package:provider/provider.dart';

class Signup extends StatefulWidget {
  final VoidCallback loginCallback;

  const Signup({Key key, this.loginCallback}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  TextEditingController _nameController;
  TextEditingController _emailController;
  TextEditingController _passwordController;
  TextEditingController _confirmController;
  CustomLoader loader;
  final _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  void initState() {
    loader = CustomLoader();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmController = TextEditingController();
    super.initState();
  }

  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Widget _body(BuildContext context) {
    return Container(
      height: context.height - 88,
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Stack(
        children: <Widget>[
          SingleChildScrollView(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _entryField('Name', controller: _nameController),
                _entryField('Enter email',
                controller: _emailController, isEmail: true),
                _entryField('Enter password',
                controller: _passwordController, isPassword: true),
                _entryField('Confirm password',
                controller: _confirmController, isPassword: true),
                _submitButton(context),

                Divider(height: 30),
                // _googleLoginButton(context),
                GoogleLoginButton(
                  loginCallback: widget.loginCallback,
                  loader: loader,
                ),
                Divider(height: 30),
                TwitterLoginButton(
                  loginCallback: widget.loginCallback,
                  loader: loader,
                ),
              ]
            )
          )
        ],
      ),
    );
  }

  Widget _entryField(String hint,
      {TextEditingController controller,
      bool isPassword = false,
      bool isEmail = false}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        style: TextStyle(
          fontStyle: FontStyle.normal,
          fontWeight: FontWeight.normal,
        ),
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(30.0),
            ),
            borderSide: BorderSide(color: Colors.blue),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
      ),
    );
  }

  Widget _submitButton(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 35),
      child: CustomFlatButton(
        label: "Sign up",
        onPressed: _submitForm,
        borderRadius: 30,
      ),
    );
  }

  void _submitForm() {
    if (_emailController.text.isEmpty) {
      Utility.customSnackBar(_scaffoldKey, 'Please enter name');
      return;
    }
    if (_emailController.text.length > 27) {
      Utility.customSnackBar(
          _scaffoldKey, 'Name cannot be longer than 27 characters');
      return;
    }
    if (_emailController.text == null ||
        _emailController.text.isEmpty ||
        _passwordController.text == null ||
        _passwordController.text.isEmpty ||
        _confirmController.text == null) {
      Utility.customSnackBar(_scaffoldKey, 'Please fill form carefully');
      return;
    } else if (_passwordController.text != _confirmController.text) {
      Utility.customSnackBar(
          _scaffoldKey, 'passwords do not match');
      return;
    }

    loader.showLoader(context);
    var state = Provider.of<AuthState>(context, listen: false);
    Random random = new Random();
    int randomNumber = random.nextInt(8);

    UserModel user = UserModel(
      email: _emailController.text.toLowerCase(),
      bio: 'Edit profile to update bio',
      // contact:  _mobileController.text,
      displayName: _nameController.text,
      dob: DateTime(2000, DateTime.now().month, DateTime.now().day)
          .toString(),
      location: 'Somewhere in universe',
      profilePic: Constants.dummyProfilePicList[randomNumber],
      isVerified: false,
    );
    state
        .signUp(
      user,
      password: _passwordController.text,
      scaffoldKey: _scaffoldKey,
    )
        .then((status) {
      print(status);
    }).whenComplete(
      () {
        loader.hideLoader();
        if (state.authStatus == AuthStatus.LOGGED_IN) {
          Navigator.pop(context);
          widget.loginCallback();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: customText(
          'Sign Up',
          context: context,
          style: TextStyle(fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(child: _body(context)),
    );
  }
}