import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hard_diffusion/api/authentication.dart';
import 'package:hard_diffusion/constants.dart';
import 'package:hard_diffusion/state/auth.dart';
import 'package:hard_diffusion/state/text_to_image_websocket.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
      _redirecting = true;
      _passwordController.clear();
      Navigator.of(context).pushReplacementNamed('/generate');
    } on BadRequestException catch (error) {
      context.showErrorSnackBar(message: error.cause);
    } on UnauthorizedException catch (error) {
      context.showErrorSnackBar(message: error.cause);
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
    var websocketState = context.watch<TextToImageWebsocketState>();
    if (websocketState.webSocketAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/generate');
      });
    }
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _isLoading ? null : _signIn,
                child: Text(_isLoading ? 'Loading' : 'Login'),
              ),
              const SizedBox(width: 18),
              ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.blue.shade500)),
                  onPressed: () => launchUrl(Uri.parse(
                      'http://localhost:8000/api/v1/oauth/twitter?session_id=${websocketState.sessionId}')),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: SvgPicture.asset('assets/twitter_logo_white.svg',
                            width: 16, height: 16, color: Colors.white),
                      ),
                      Text('Sign in with Twitter'),
                    ],
                  )),
            ],
          )
        ],
      ),
    );
  }
}
