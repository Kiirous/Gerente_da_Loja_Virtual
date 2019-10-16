import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:firebase_storage/firebase_storage.dart';


class ProductBloc extends BlocBase {

  final _dataController = BehaviorSubject<Map>(); // Map pois ele vai conter todos os dados que vai ser emitido na tela
  final _loadingController = BehaviorSubject<bool>();
  final _createdController = BehaviorSubject<bool>();


  Stream<Map> get outData => _dataController.stream;
  Stream<bool> get outLoading => _loadingController.stream;
  Stream<bool> get outCreated => _createdController.stream;
  String categoryId;
  DocumentSnapshot product;

  Map<String, dynamic> unsavedData; // Criando uma mapa de dados nao salvos. Só vao ser salvos quando clicarmos no botao salvar.
  //Dessa forma não vamos prejudicar os dados que já estão salvos no firebase.

  ProductBloc({this.categoryId, this.product}){
    if(product != null){ // Ou seja, se clicarmos em algum produto na lista de produtos...
      unsavedData = Map.of(product.data); //Clonando os dados do meu produto e jogando no unsavedData
      //Dessa forma posso modificar o unsavedData que ele não vai modificar os dados do produto (product.data).
      //E caso eu clicar no "+ adicionar", o produto vai ser nulo, dessa forma o unsavedData também vai ser nulo.

      unsavedData['images'] = List.of(product.data['images']); // Sobrescrevendo o images com uma lista dos dados de imagem.
      //E dessa forma ele cria uma lista que possa ser expandível. Vou fazer o mesmo para o Sizes. Agora posso modificar os dados sem problema.

      unsavedData['sizes'] = List.of(product.data['sizes']);

      _createdController.add(true); // Produto já está criado, habilita o botão ' - '
    } else {
      unsavedData = {
        'title' : null, 'description' : null, 'price' : null, 'images' : [], 'sizes' : [] // Como dito no unsavedData, produto vai ser nulo.
      };

      _createdController.add(false); //Desabilita o botão ' - ' pois o produto ainda não está criado.

    }

    _dataController.add(unsavedData); // Ou seja, os dados que colocarmos no unsavedData vão ser transmitidos para o _dataController
    //e eles vão sair no outData.

  }

  void saveTitle(String title){
    unsavedData['title'] = title;
  }

  void saveDescription(String description){
    unsavedData['description'] = description;
  }

  void savePrice(String price){
    unsavedData['price'] = double.parse(price);
  }

  void saveImages(List images){
    unsavedData['images'] = images;
  }

  void saveSizes(List sizes){
    unsavedData['sizes'] = sizes;
  }

  Future<bool> saveProduct() async { // Salvar todos os dados do produto e depois Salvar os dados no firebase. depois retornar se for sucesso ou não.
    _loadingController.add(true); // Carregando

   try {
     if(product != null){
      await _uploadImages(product.documentID);
      await product.reference.updateData(unsavedData);
     } else {

       DocumentReference dr = await Firestore.instance.collection('products').document(categoryId).
        collection('itens').add(Map.from(unsavedData)..remove('images')); //Salvando todos os dados do produto menos as imagens. Criando um mapa clone do unsavedData e mandando remover as imagens deste mapa clone
       await _uploadImages(dr.documentID);
       await dr.updateData(unsavedData);

     }
     _createdController.add(true); // Habilita o botão ' - '
     _loadingController.add(false);
     return true;
   } catch (e){
     _loadingController.add(false);
     return false;
   }
  }

  Future _uploadImages(String productId) async { // Função que vai pegar todas as fotos que foram adicionadas no app e salva-las no firebase.
    for(int i = 0; i < unsavedData['images'].length; i++){
      if(unsavedData['images'][i] is String) continue; // ignora toda a parte debaixo do for e vai para o próximo [i] possivel

      StorageUploadTask uploadTask = FirebaseStorage.instance.ref().child(categoryId).//peguei a referencia pro meu bando do firebaseStorage
    child(productId).child(DateTime.now().millisecondsSinceEpoch.toString()). //Salvando a imagem em uma pasta chamada categoryId pra deixar mais organizado e vai ter outra pasta dentro chamada productId e em seguida o nome do arquivo
      //O DatetimeNow com o millisecondsSinceEpoch permite termos um valor unico pra cada arquivo.
    putFile(unsavedData['images'][i]); //fazendo o upload

      StorageTaskSnapshot s = await uploadTask.onComplete; // Vai esperar o upload ser completo.
      String downloadUrl = await s.ref.getDownloadURL(); // Pega a URL de download da img

      unsavedData['images'][i] = downloadUrl; // Antes o unsabedData era um arquivo, agora ele se torna uma URL da imagem que já está no firebase.
    }
  }

  void deleteProduct(){
    product.reference.delete();
  }

  @override
  void dispose() {
    _dataController.close();
    _loadingController.close();
    _createdController.close();
  }

}