import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

enum SortCriteria {READY_FIRST, READY_LAST} // Enumerador com critério de enumeração.

class OrdersBloc extends BlocBase{

  final _ordersController = BehaviorSubject<List>();

  Stream<List> get outOrders => _ordersController.stream; // Stream da saída dos dados

  Firestore _firestore = Firestore.instance;

  List<DocumentSnapshot> _orders = []; //Esses pedidos vou armazenar um snapshot do meu documento, fazendo isso eu tenho acesso a referencia do meu documento. Se eu quiser exluir, regredir ou avançar é muito mais facil. Por isso usarei DocumentSnapshot

  SortCriteria _criteria;

  OrdersBloc(){
    _addOrdersListener();
  }

  void _addOrdersListener(){ //Função com um Listener para pegar todas as mudanças dos pedidos.
    _firestore.collection('orders').snapshots().listen((snapshot){
      snapshot.documentChanges.forEach((change){
        String oid = change.document.documentID;

        switch(change.type){
          case DocumentChangeType.added:
            _orders.add(change.document); //Armazenei meu Documento na minha lista _orders
          break;
          case DocumentChangeType.modified:
            _orders.removeWhere((order) => order.documentID == oid);
            _orders.add(change.document); //Pegando a lista e adicionando o documento modificado
          break;
          case DocumentChangeType.removed:
            _orders.removeWhere((order) => order.documentID == oid);
            break;
        }
      });
      _sort();

    }); //Sempre que tiver uma alteração nos documentos do pedido, vamos ser notificados
  }

  void setOrderCriteria(SortCriteria criteria){
    _criteria = criteria; // setei o critério
    _sort(); // Ordena.
  }

  void _sort(){
    switch(_criteria){
      case SortCriteria.READY_FIRST:
        _orders.sort((a, b){
          int sa = a.data['status'];
          int sb = b.data['status'];

          if(sa < sb) return 1;
          else if(sa > sb) return -1;
          else return 0;
        });
        break;
      case SortCriteria.READY_LAST:
        _orders.sort((a, b){
          int sa = a.data['status'];
          int sb = b.data['status'];

          if(sa > sb) return 1;
          else if(sa < sb) return -1;
          else return 0;
        });
        break;
    }
    _ordersController.add(_orders); // Roda os pedidos já ordenados para o _ordersController
  }

  @override
  void dispose() {
    _ordersController.close();
  }

}