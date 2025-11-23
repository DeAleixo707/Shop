import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/exceptions/firebase_exception.dart';
import 'package:shop/providers/auth.dart';

enum AuthMode { Login, Signup }

class AuthFormCard extends StatefulWidget {
  const AuthFormCard({super.key});

  @override
  State<AuthFormCard> createState() => _AuthFormCardState();
}

class _AuthFormCardState extends State<AuthFormCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _form = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  final _passwordControler = TextEditingController();
  bool _isLoading = false;
  AnimationController? _animationController;
  Animation<double>? _opacityAnimation;
  Animation <Offset>? _ofsetAnimation;

  final Map<String, String> _authData = {
    'email': '',
    'password': '',
  };

  void _showErrorDialog(String msg) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text('Ocorreu um erro!'),
              content: Text(msg),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Fechar'),
                ),
              ],
            ));
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    Auth auth = Provider.of(context, listen: false);
    _form.currentState!.save();
    try {
      if (_authMode == AuthMode.Login) {
        await auth.login(_authData['email']!, _authData['password']!);
      } else {
        await auth.signUp(_authData['email']!, _authData['password']!);
      }
    } on FirebaseException catch (error) {
      _showErrorDialog(error.toString());
    } catch (error) {
      _showErrorDialog('Ocorreu um erro inesperado!');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void switchAuthMode() {
    setState(() {
      if (_authMode == AuthMode.Login) {
        setState(() {
          _authMode = AuthMode.Signup;
        });
        _animationController!.forward();
      } else {
        setState(() {
          _authMode = AuthMode.Login;
        });
        _animationController!.reverse();
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeInOut,
    ));
    _ofsetAnimation = Tween<Offset>(
      begin:Offset(0, -1.5),
      end:Offset(0,0) ,
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _animationController!.dispose();
    _passwordControler.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: AnimatedContainer(
        constraints: BoxConstraints(
          minHeight: _authMode == AuthMode.Signup? 360 : 300,
          maxHeight: _authMode == AuthMode.Signup ? 360 : 300,
        ),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
            padding: const EdgeInsets.all(20),
            // height: _authMode == AuthMode.Signup ? 400 : 300,
            // height: _heightAnimation!.value.height,
            margin: const EdgeInsets.only(bottom: 20),
            width: deviceSize.width * 0.75,
            child: Form(
          key: _form,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(
                      label: const Text('E-mail'),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context)
                              .primaryColor, // Escolha a cor desejada
                          width: 2.0,
                        ),
                      ),
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                              width: 2.0))),
                  validator: (value) {
                    if (value!.isEmpty || !value.contains('@')) {
                      return ('Informe um E-mail valido');
                    }
                    return null;
                  },
                  keyboardType: TextInputType.emailAddress,
                  onSaved: (value) => _authData['email'] = value!,
                ),
                TextFormField(
                  decoration: InputDecoration(
                      label: const Text('Password'),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context)
                              .primaryColor, // Escolha a cor desejada
                          width: 2.0,
                        ),
                      ),
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                              width: 2.0))),
                  validator: (value) {
                    if (value!.isEmpty || value.length < 5) {
                      return ('Informe uma Password valida');
                    }
                    return null;
                  },
                  obscureText: true,
                  keyboardType: TextInputType.visiblePassword,
                  onSaved: (value) => _authData['password'] = value!,
                  controller: _passwordControler,
                ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    constraints: BoxConstraints(
                      minHeight: _authMode == AuthMode.Signup ? 60 : 0,
                      maxHeight: _authMode == AuthMode.Signup ? 120 : 0,
                    ), 

                    child: FadeTransition(
                      opacity:_opacityAnimation!, 
                      child: SlideTransition(
                      position: _ofsetAnimation!,
                        child: TextFormField(
                          decoration: InputDecoration(
                              label: const Text('Confirmar password'),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .primaryColor, // Escolha a cor desejada
                                  width: 2.0,
                                ),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor,
                                      width: 2.0))),
                          validator: (_authMode == AuthMode.Signup)
                              ? (value) {
                                  if (value!.isEmpty ||
                                      value != _passwordControler.text) {
                                    return ('Informou uma password diferente');
                                  }
                                  return null;
                                }
                              : null,
                          obscureText: true,
                          keyboardType: TextInputType.visiblePassword,
                        ),
                      ),
                    ),
                  ),
                _authMode == AuthMode.Login
                    ? const SizedBox(
                        height: 20,
                      )
                    : const SizedBox(
                        height: 60,
                      ),
                _isLoading
                    ? CircularProgressIndicator(
                        backgroundColor: Theme.of(context).primaryColor,
                      )
                    : ElevatedButton(
                        onPressed: _submit,
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                              Theme.of(context).primaryColor),
                          foregroundColor:
                              WidgetStateProperty.all(Colors.white),
                          textStyle: WidgetStateProperty.all(
                            const TextStyle(color: Colors.white),
                          ),
                        ),
                        child: _authMode == AuthMode.Login
                            ? const Text('Entrar')
                            : const Text('Registrar'),
                      ),
                TextButton(
                    onPressed: switchAuthMode,
                    child: _authMode == AuthMode.Login
                        ? const Text(
                            'Registrar',
                            style:
                                TextStyle(decoration: TextDecoration.underline),
                          )
                        : const Text('Entrar',
                            style: TextStyle(
                                decoration: TextDecoration.underline)))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
