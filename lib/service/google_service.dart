/*
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import "package:flutter/material.dart";

class GoogleService {

  static const String _webClientId = '322948964487-s1653nkp0eq497iq4jrq2du61p9af8o1.apps.googleusercontent.com';
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: _webClientId,
    scopes: ['email', 'profile'],
  );

  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) {
        print("user cancelled login.");
        return null;
      }

      final GoogleSignInAuthentication auth = await account.authentication;
      return auth.idToken;
    } catch (error) {
      print("Google sign in error: $error");
      return null;
    }
  }
}*/