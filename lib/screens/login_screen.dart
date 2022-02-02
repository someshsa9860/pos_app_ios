import 'package:flutter/material.dart';
import 'package:pos_app/provider/auth_provider.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _passwordFocusNode = FocusNode();

  final _form = GlobalKey<FormState>();

  final bool _visibility = false;

  String _username = "null";

  String _password = "null";

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    final authProvider = Provider.of<AuthProvider>(context);
    authProvider.initAuthProvider();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Form(
            key: _form,
            child: ListView(
              children: [
                TextFormField(
                  initialValue: 'james',
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_passwordFocusNode);
                  },
                  validator: (v) {
                    if (v!.isEmpty) {
                      return 'Please enter Username';
                    }
                    return null;
                  },
                  onSaved: (v) {
                    _username = v!;
                  },
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: 'Username'),
                ),
                const SizedBox(height: 10.0),
                TextFormField(
                  initialValue: 'james21',
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.text,
                  obscureText: !_visibility,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_passwordFocusNode);
                  },
                  onSaved: (v) {
                    _password = v!;
                  },
                  validator: (v) {
                    if (v!.isEmpty) {
                      return 'Please enter password';
                    }

                    return null;
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                  ),
                ),
                const SizedBox(height: 10.0),
                ElevatedButton(
                    onPressed: () {
                      if (saveForm()) {
                        authProvider.login(_username, _password);
                        // Navigator.of(context)
                        //     .pushNamed(ContactsCustomersScreen.routeName);
                        //

                      } else {
                        //
                      }
                    },
                    child: const Text('Login'))
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _passwordFocusNode.dispose();
    super.dispose();
  }

  bool saveForm() {
    bool valid = _form.currentState!.validate();
    if (!valid) {
      return false;
    }
    _form.currentState!.save();
    return true;
  }
}
