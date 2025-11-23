import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/data/storeStorage.dart';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expiredDate;
  String? _userId;
  Timer? _logoutTimer;

  bool get isAuth {
    return token != null;
  }

  String? get userId {
    return isAuth ? _userId : null;
  }

  String? get token {
    if (_token != null &&
        _expiredDate != null &&
        _expiredDate!.isAfter(DateTime.now())) {
      return _token;
    } else {
      return null;
    }
  }

  Future<void> autenticate(
      String email, String password, String urlSegment) async {
    final url = Uri.parse(
      'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyDa7AELmgy8Dx0zoaWgDVb6iuNzE2CpBF8',
    );
    final response = await http.post(url,
        body: jsonEncode(
            {'email': email, 'password': password, 'returnSecureToken': true}));

    final responseBody = jsonDecode(response.body);
    if (responseBody['error'] != null) {
      throw Exception(responseBody['error']['message']);
    } else {
      _token = responseBody['idToken'];
      _expiredDate = DateTime.now().add(
        Duration(seconds: int.parse(responseBody['expiresIn'])),
      );
     
      print(responseBody['error']);

      Storestorage.saveMap('userData', {
        'token': _token,
        'userId': responseBody['localId'],
        'expiredDate': _expiredDate!.toIso8601String(),
      });
      autoLogout(); 
      notifyListeners();
    }
    return Future.value();
  }

  Future<void> login(String email, String password) async {
    return autenticate(email, password, 'signInWithPassword');
  }

  Future<void> signUp(String email, String password) async {
    return autenticate(email, password, 'signUp');
  }

Future<void> tryAutoLogin() async {
    if(isAuth) {
      return Future.value(true);
    }
    final userData = await Storestorage.getMap('userData');
    if (userData== null) {
      return Future.value(false);
    }
    final expiredDate = DateTime.parse(userData['expiredDate']);
    if (expiredDate.isBefore(DateTime.now())) {
      return Future.value(false);
    }
    _token = userData['token'];
    _userId = userData['userId'];
    _expiredDate = expiredDate;
    autoLogout();
    notifyListeners();
    return Future.value(true);
    
  }

  void logout() {
    _token = null;
    _expiredDate = null;
    _userId = null;
    if (_logoutTimer != null) {
      _logoutTimer!.cancel();
      _logoutTimer = null;
    }
    Storestorage.remove('userData');
    // Clear user data from storage
    notifyListeners();
  }

  void autoLogout() {
    if (_logoutTimer != null) {
      _logoutTimer!.cancel();
    }
    final timeToLogout = _expiredDate!.difference(DateTime.now()).inSeconds;
    _logoutTimer = Timer(Duration(seconds: timeToLogout), logout);
  }
}
