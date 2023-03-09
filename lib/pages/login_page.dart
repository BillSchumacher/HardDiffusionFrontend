import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hard_diffusion/api/authentication.dart';
import 'package:hard_diffusion/constants.dart';
import 'package:hard_diffusion/state/auth.dart';
import 'package:hard_diffusion/state/text_to_image_websocket.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  bool _redirecting = false;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  //late final StreamSubscription<AuthState> _authStateSubscription;

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
    });
    try {
      var tokens =
          await fetchTokens(_usernameController.text, _passwordController.text);

      var authState = Provider.of<AuthState>(context, listen: false);
      authState.setAccessToken(tokens.accessToken);
      authState.setRefreshToken(tokens.refreshToken);
      var websocketState =
          Provider.of<TextToImageWebsocketState>(context, listen: false);
      _redirecting = true;
      _passwordController.clear();
      websocketState.connect();
      Navigator.of(context).pushReplacementNamed('/generate');
    } on Exception catch (error) {
      context.showErrorSnackBar(message: error.toString());
    } catch (error) {
      print(error);
      context.showErrorSnackBar(message: 'Unexpected error occurred');
    }
    /*
    } on AuthException catch (error) {
      context.showErrorSnackBar(message: error.message);
    */

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    /*
    _authStateSubscription = supabase.auth.onAuthStateChange.listen((data) {
      if (_redirecting) return;
      final session = data.session;
      if (session != null) {
        _redirecting = true;
        Navigator.of(context).pushReplacementNamed('/account');
      }
    });*/
    super.initState();
  }

  @override
  void dispose() {
    // Disposing these controllers breaks on reload.
    //_usernameController.dispose();
    //_passwordController.dispose();
    //_authStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        children: [
          const SizedBox(height: 18),
          TextFormField(
            controller: _usernameController,
            decoration: const InputDecoration(labelText: 'Username'),
          ),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: _isLoading ? null : _signIn,
            child: Text(_isLoading ? 'Loading' : 'Login'),
          ),
        ],
      ),
    );
  }
}
