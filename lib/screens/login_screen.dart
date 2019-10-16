import 'package:flutter/material.dart';
import 'package:gerente_loja/blocs/login_bloc.dart';
import 'package:gerente_loja/screens/home_screen.dart';
import 'package:gerente_loja/widgets/imput_field.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  //vai ser usado apenas nessa tela. Não precisa de Provider.
  final _loginBloc = LoginBloc();

  @override
    void initState(){
super.initState();

_loginBloc.outState.listen((state){
  switch(state){
    case LoginState.SUCCESS:
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomeScreen())
      );
      break;
    case LoginState.FAIL:
      showDialog(context: context, builder: (context) => AlertDialog(
        title: Text('Erro'),
        content: Text('Você não possui os privilégios necessários'),
      ));
      break;
      //No Loading e Idle nao precisamos fazer nada especial pois já tratamos deles dentro do build.
    case LoginState.LOADING:
    case LoginState.IDLE:
  }
});
}

//Liberar recursos do celular
  @override
  void dispose() {
    _loginBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      body: StreamBuilder<LoginState>(
        stream: _loginBloc.outState,
        initialData: LoginState.LOADING,
        builder: (context, snapshot) {
          switch(snapshot.data){
            case LoginState.LOADING:
            return Center(child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(
                  Color.fromARGB(254, 242, 193, 94)
              ),
            ),
            );
            case LoginState.FAIL:
            case LoginState.SUCCESS:
            case LoginState.IDLE:
            return Stack(
              alignment: Alignment.center,
              children: <Widget>[
                //Usando esse container pro Stack colocar o conteúdo no centro
                Container(),
                SingleChildScrollView(
                  child: Container(
                    margin: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Icon(Icons.store_mall_directory,
                          color: Color.fromARGB(254, 242, 193, 94),
                          size: 160,
                        ),
                        InputField(
                          icon: Icons.person_outline,
                          hint: 'Usuário',
                          obscure: false,
                          stream: _loginBloc.outEmail,
                          onChanged: _loginBloc.changeEmail,
                        ),
                        InputField(
                          icon: Icons.lock_outline,
                          hint: 'Senha',
                          obscure: true,
                          stream: _loginBloc.outPassword,
                          onChanged: _loginBloc.changePassword,
                        ),
                        SizedBox(height: 36.0,),
                        StreamBuilder<bool>(
                            stream: _loginBloc.outSubmitValid,
                            builder: (context, snapshot) {
                              return SizedBox(
                                height: 50.0,
                                child: RaisedButton(
                                  color: Color.fromARGB(254, 242, 193, 94),
                                  child: Text('Entrar'),
                                  onPressed: snapshot.hasData ? _loginBloc.submit : null,
                                  textColor: Colors.grey[850],
                                  disabledColor: Color.fromARGB(254, 242, 193, 94).withAlpha(140),
                                ),
                              );
                            }
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
        }
      ),
    );
  }
}
