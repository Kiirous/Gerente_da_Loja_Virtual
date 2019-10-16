import 'dart:async';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:gerente_loja/validators/login_validators.dart';
import 'package:rxdart/rxdart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum LoginState {IDLE, LOADING, SUCCESS, FAIL}

class LoginBloc extends BlocBase with LoginValidators{

  //Controlador Behavior do tipo String pois String é o que colocamos no campo email.
  final _emailController = BehaviorSubject<String>();
  final _passwordController = BehaviorSubject<String>();
  final _stateController = BehaviorSubject<LoginState>();

  //Onde os dados Saem (a Stream pe do tipo String pois o controlador é do tipo String):
  Stream<String> get outEmail => _emailController.stream.transform(validateEmail);
  //Na linha acima, pegamos o email e retornamos o emailController.
  Stream<String> get outPassword => _passwordController.stream.transform(validatePassword);
  Stream<LoginState> get outState => _stateController.stream;

  //Na linha abaixo, vamos observar o email e a senha, combinar as 2 e fazer uma saída.
  Stream<bool> get outSubmitValid => Observable.combineLatest2(
      outEmail, outPassword, (a, b) => true //se tiver dados nas 2, retorno TRUE
  );

  //quando eu colocar uma função changeEmail, o que eu mandar vai ser enviada automaticamente
  //para o meu _emailController.sink.add
  Function(String) get changeEmail => _emailController.sink.add;
  Function(String) get changePassword => _passwordController.sink.add;

  StreamSubscription _streamSubscription;

  //Esse método vai servir para quando houver alguma madança na autenticação (logar e deslogar)
  LoginBloc(){

    _streamSubscription = FirebaseAuth.instance.onAuthStateChanged.listen((user) async{ //me passa o usuário atual
      if(user != null){
        if(await verifyPrivileges(user)){ // se usuário tem privilégio, Sucesso!
          _stateController.add(LoginState.SUCCESS);
        } else { //se não, Falha
          FirebaseAuth.instance.signOut();
          _stateController.add(LoginState.FAIL);
        }
      } else {
        _stateController.add(LoginState.IDLE); //Aqui passamos IDLE e não FAIL pois quando LoginBloc iniciar ele ja vai
        // tentar requisitar o usuário atual, porém podemos ter usuario logado ou não. Se eu abrir o app e já tiver um
        // usuário logado, não será necessário fazer o login
      }
    });
  }

  //Aqui vamos pegar o e-mail e a senha digitada. Basta obter o último dado das streams
  void submit(){
    final email = _emailController.value;
    final password = _passwordController.value;

    //Aqui vamos pedir para o firebase autenticar o usuário em questão
    //Mas antes vamos informar a tela que vamos processar algo, sendo assim o estado muda para loading
    _stateController.add(LoginState.LOADING);

    FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
    ).catchError((e){
      //Se der erro de autenticação, já avisa a tela.
      _stateController.add(LoginState.FAIL);
    });
  }

  //Ver se o usuário está na lista de administradores ou não.
  Future<bool> verifyPrivileges(FirebaseUser user) async{
    return await Firestore.instance.collection('admins').document(user.uid).get().then((doc){
      if(doc.data != null){
        return true;
      } else {
        return false;
      }
    }).catchError((e){
      return false;
    });
  }

  @override
  void dispose() {
    _emailController.close();
    _passwordController.close();
    _stateController.close();

    _streamSubscription.cancel();
  }

}