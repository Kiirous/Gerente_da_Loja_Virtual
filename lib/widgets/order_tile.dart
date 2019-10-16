import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gerente_loja/widgets/order_header.dart';

class OrderTile extends StatelessWidget {

  final DocumentSnapshot order;
  OrderTile(this.order);

  final states = [
    '', 'Em preparação', 'Em tansporte', 'Aguardando entrega', 'Entregue'
  ]; // Fazer o status. Em lista. Começa em 0, vai pra 1, 2, 3 e 4.

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        child: ExpansionTile(
          key: Key(order.documentID), // key unico pra cada um dos pedidos, evita bugs do pedido mudar de posição.
          /*initiallyExpanded: order.data['status'] != 4, *///-Este código faz com que os pedidos que ainda não foram entregues
          //apareçam já com a Tile aberta. Ele deve ficar dentro do ExpansionTile.

            title: Text('#${order.documentID.substring(order.documentID.length -7, order.documentID.length)} - '
                '${states[order.data['status']]}', // Pegando estado do pedido.
              //pegando o ID do documento, e selecionando os últimos 7 digitos do OrderID. O " order.documentID.length -7 " é o
              // começo da substring, dps o '"order.documentID.length" é o final da substring.
            style: TextStyle(color: order.data['status'] != 4 ? Colors.grey[850] : Colors.green),
            ),
          children: <Widget>[
            Padding(
                padding: EdgeInsets.only(left: 16, right: 16, bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  OrderHeader(order),
                  Column(
                    mainAxisSize: MainAxisSize.min, //ocupa o espaço mínimo na vertical
                    children: order.data['products'].map<Widget>((p){
                      return ListTile(
                        title: Text(p['product']['title'] + ' ' + p['size']),
                        subtitle: Text(p['category'] +  '/' +  p['pid']),
                        trailing: Text(p['quantity'].toString(), // Transformando a quantidade em String
                          style: TextStyle(fontSize: 20.0),
                        ),
                        contentPadding: EdgeInsets.zero,
                      );  //Dessa forma para cada um dos pedidos/produtos vamos retorar um listTile
                    }).toList(), //O map vai pegar cada um dos meus dados da minha lista.
                  ),
                  Row(
                    children: <Widget>[
                      Text('Forma de pagamento:',
                          style: TextStyle(fontSize: 16)),
                      SizedBox(width: 8),
                      Text(order.data['PaymentMethod'].toString(), // Aqui vai o código pra puxar a forma de pagamento do pedido
                          style: TextStyle(fontSize: 16,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      FlatButton(onPressed: (){
                        Firestore.instance.collection('users').document(order['clientId'])
                        .collection('orders').document(order.documentID).delete();// deletando pedido para o usuário também.
                        order.reference.delete(); // deletando pedido da lsita de pedidos
                      },
                          textColor: Colors.red,
                          child: Text('Excluir')
                      ),
                      FlatButton(onPressed: order.data['status'] > 1 ? (){
                        order.reference.updateData({'status' : order.data['status'] -1 });
                      } : null,
                          textColor: Colors.grey[850],
                          child: Text('Regredir')
                      ),
                      FlatButton(onPressed: order.data['status'] < 4 ? (){
                        order.reference.updateData({'status' : order.data['status'] +1 });
                      } : null,
                          textColor: Colors.green,
                          child: Text('Avançar')
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
