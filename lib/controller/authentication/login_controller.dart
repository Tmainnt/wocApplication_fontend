import 'package:flutter/widgets.dart';
import 'package:woc/provider/user_provider.dart';
import 'package:woc/service/auth_service.dart';
//import 'package:woc/service/google_service.dart';

class LoginController extends ChangeNotifier {

  bool validEmail = true;
  bool validPassword = true;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final UserProvider _userProvider;
  LoginController(this._userProvider);

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<bool> loginButtonAction() async {
    if (validInput()) {
      try {
        final userData = await AuthService().loginResponseStatusCode(
          emailController.text,
          passwordController.text,
        );
        _userProvider.setUser(userData);
        return true;
      } catch (e) {
        print("LOGIN ERROR: $e");
        return false;
      }
    }
    
    notifyListeners();
    return false;
  }

  /*
  Future<bool> signInWithGoogleButtonAction() async {
    final idToken = await GoogleService().signInWithGoogle();
    if (idToken != null) {
      try {
        final userData = await AuthService().loginWithGoogle(idToken);
        _userProvider.setUser(userData);
        return true;
      } catch (e) {
        return false;
      }
    }
    return false;
  }
  */

  bool validInput() {
    validEmail = emailController.text.isNotEmpty;
    validPassword = passwordController.text.isNotEmpty;
    return validEmail && validEmail;
  }

  void clearEmailError() {
    if (!validEmail){
      validEmail = true;
      notifyListeners();
    }
  }

  void clearPasswordError() {
    if (!validPassword){
      validPassword = true;
      notifyListeners();
    }
  }
  
}
