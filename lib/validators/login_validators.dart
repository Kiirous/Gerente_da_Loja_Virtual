import 'dart:async';

class LoginValidators {
  // aqui vamos colocar StreamTransformers que são objetos que vão transformar algo
  //em algum resultado

  //Aqui no StreamTransformer temos que passar o tipo da entrada e da saída.
  //No caso, vamos entrar com o e-mail e sair com o email(String)
  final validateEmail = StreamTransformer<String, String>.fromHandlers(
    //Aqui vamos verificar se o email é valido ou não
      handleData: (email, sink){
        if(email.contains('@') && email.contains('.')){
          sink.add(email); // passando o e-mail pra frente
        } else {
          sink.addError('Insira um e-mail válido');
        }
  }
  );

  final validatePassword = StreamTransformer<String, String>.fromHandlers(
    handleData: (password, sink){
      if(password.length > 4){
        sink.add(password);
      } else {
        sink.addError('Senha inválida. Deve conter ao menos 5 caracteres');
      }
    }
  );
  
}