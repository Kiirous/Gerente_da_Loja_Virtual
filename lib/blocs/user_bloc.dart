import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

class UserBloc extends BlocBase {

  final _usersController = BehaviorSubject<List>();

  Stream<List> get outUsers => _usersController.stream;

  //Vamos armazenar os usuários
  Map<String, Map<String, dynamic>> _users = {};// isso é necessário pois queremos um mapa onde eu possa passar o UID do usuário e já
  // obter os dados dele. Dessa forma passamos o UID em STRING e o Conteúdo do usuárop no segundo Map

  Firestore _firestore = Firestore.instance; // só para economizar codigo, usar o _firestore.

  UserBloc(){
    //Nessa função vamos adicionar um Listener para cada um dos usuários. Sempre que eu adicionmar um usuário, um Listener
    //vai ser chamado, se eu remove-lo, o Listener também vai ser chamado. Se eu modificar os dados do usuário, o Listener
    // também é chamado.
    _addUserListener();
  }

  //Para o sistema de busca do cliente funcionar:
  void onChangedSearch(String search){
    if(search.trim().isEmpty){ // O trim remove os espaços antes e depois do texto escrito
      _usersController.add(_users.values.toList());
    } else {
      _usersController.add(_filter(search.trim()));
    }
  }

  //Função de filtro de pesquisa
  List<Map<String, dynamic>> _filter(String search){
    List<Map<String, dynamic>> filteredUsers = List.from(_users.values.toList());//Pegei a lista de usuários, copiei ela em filteredUsers.
    filteredUsers.retainWhere((user){ //Quando a fução retorna true, vai manter o item, se retornar falso, vai deletar o item. É uma função simples que o Dart fornece.
      return user['name'].toUpperCase().contains(search.toUpperCase());//Para ser possivel pesquisar o nome mesmo se for digitado em letra maiúscula
    }); //Se a pesquisa "search" está contida no nome do usuário, mantém o usuário. Caso contrario vai retornar falso e esse usuário será deletado da lista de usuários filtrados.
    return filteredUsers;
  }


  void _addUserListener(){
    // Na linha a baixo, vai me retornar uma Stream e sempre que tiver uma alteração no BD ele vai chamar o snapshot e assim
    // vamos obter apenas as modificações na coleção users.
    _firestore.collection('users').snapshots().listen((snapshot){
      snapshot.documentChanges.forEach((change){ //Recebe a lista de mudança e pra cada mudança ele chama uma função anonima passando a mudança "change".
        String uid = change.document.documentID;// Uid do usuário cujos dados foram modificados.

        //Verificar qual modificação foi feita:
        switch(change.type){
          case DocumentChangeType.added:
            _users[uid] = change.document.data; //Armazenando os dados do usuário no Map.
            _subscribeToOrders(uid); // Observa os pedidos do usuário
            break;

          case DocumentChangeType.modified: //Quando um usuário for modificado vamos pegar a mudança e adicionar no _user[uid].
            _users[uid].addAll(change.document.data); //Armazenando as modificações do usuário no Map.
            _usersController.add(_users.values.toList());
            break;

          case DocumentChangeType.removed:
            _users.remove(uid);
            _unsubscribeToOrders(uid); //Não precisa observar os pedidos do usuário pois o mesmo foi removido
            _usersController.add(_users.values.toList());
            break;
        }
      });

    });

  }

  void _subscribeToOrders(String uid){
    _users[uid]['subscription'] = _firestore.collection('users').document(uid)
        .collection('orders').snapshots().listen((orders) async{

          int numOrders = orders.documents.length; // Salvamos o nº de ordens

          double money = 0.0; // Quantidade de dinheiro que o cliente gastou

          for(DocumentSnapshot d in orders.documents){
            DocumentSnapshot order = await _firestore.collection('orders').document(d.documentID).get();

            if(order.data == null) continue;

            money += order.data['totalPrice'];
          }

          //Vamos salvar esses dados nos usuários
      _users[uid].addAll(
        {'money' : money, 'orders' : numOrders} // adicionando as infos aos dados locais do _user[uid]
      );

          _usersController.add(_users.values.toList());

    });
  }

  Map<String, dynamic> getUser(String uid){
    return _users[uid]; // retorna a lista de usuários com o usuário correspondente.
  }

  void _unsubscribeToOrders(String uid){
    _users[uid]['subscription'].cancel(); //Cancelo a subscription do usuário
  }

  @override
  void dispose() {
    _usersController.close();
  }
}