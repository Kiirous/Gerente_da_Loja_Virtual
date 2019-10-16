import 'dart:async';
import 'dart:io';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:rxdart/rxdart.dart';

class CategoryBloc extends BlocBase {

  final _titleController = BehaviorSubject<String>();
  final _imageController = BehaviorSubject(); // Aqui não vou especificar o tipo pois aqui podemos ter tanto um texto que
  // é uma url de uma imagem quanto um file que é a imagem que vamos carregar no dispositivo.
  final _deleteController = BehaviorSubject<bool>(); // Quanto eu esteja criando uma categoria, mostre o botão "Excluir" bloqueado.

  Stream<String> get outTitle => _titleController.stream.transform(StreamTransformer<String, String>.fromHandlers(
    handleData: (title, sink){
      if(title.isEmpty)
        sink.addError('Insira um título');
      else
        sink.add(title);
    }
  )); //Validando a alteração do título de uma categoria de produto.

  Stream get outImage => _imageController.stream;
  Stream<bool> get outDelete => _deleteController.stream;
  Stream<bool> get submitValid => Observable.combineLatest2(outTitle, outImage, (a, b) => true);

  DocumentSnapshot category;

  File image; // Vamos salvar a image no firebase então é bom ter uma instância aqui pra termos acesso mais facil depois.
  String title;

  CategoryBloc(this.category){ //se eu clicar no icone de alguma categoria, vai ser a categoria desse produto.
    // Se eu clicar no botão para criar uma categoria, vai ser nulo.
    if(category != null){
      title = category.data['title'];

      _titleController.add(category.data['title']);
      _imageController.add(category.data['icon']);
      _deleteController.add(true);
    } else{
     _deleteController.add(false); //Sesabilito o botão e não passo nenhum dado de titulo nem de imagem.
    }
  }

  void setImage(File file){
    image = file;
    _imageController.add(file);
  }

  void setTitle(String title){
    this.title = title; //Salvando o titulo atual
    _titleController.add(title); //Mandando para o controlador.

  }

  void delete(){
    category.reference.delete();
  }

  Future saveData() async{

    if(image == null  && category != null && title == category.data['title']) return;

    Map <String, dynamic> dataToUpdate = {}; // Vamos colocar tudo oq temos que mandar para o firebase.

    if(image != null){ // se sim, vamos pegar a imagem e fazer upload no firebase
      StorageUploadTask task = FirebaseStorage.instance.ref().child('icons')
          .child(title).putFile(image);
      StorageTaskSnapshot snap = await task.onComplete;
      dataToUpdate['icon'] = await snap.ref.getDownloadURL();
    }

    if(category  == null || title != category.data['title']){
      dataToUpdate['title'] = title;
    }

    if(category == null){
      await Firestore.instance.collection('products').document(title.toLowerCase())
          .setData(dataToUpdate);
    } else {
      await category.reference.updateData(dataToUpdate); //Peguei a categoria já existente e atualizei os dados com o dataToUpdate.
    }

  }

  @override
  void dispose() {
    _titleController.close();
    _imageController.close();
    _deleteController.close();
  }

}