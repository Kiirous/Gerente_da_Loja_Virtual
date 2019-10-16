import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:gerente_loja/blocs/orders_bloc.dart';
import 'package:gerente_loja/widgets/order_tile.dart';

class OrdersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final _ordersBloc = BlocProvider.of<OrdersBloc>(context); // ter acesso ao orders_bloc

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: StreamBuilder<List>(
        stream: _ordersBloc.outOrders,
        builder: (context, snapshot) {
          if(!snapshot.hasData)
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Color.fromARGB(254, 242, 193, 94)),
              ),
            );

          else if (snapshot.data.length == 0)
            return Center(
              child: Text('Nenhum pedido pedido encontrado',
              style: TextStyle(color: Color.fromARGB(254, 242, 193, 94)),),
            );

          return ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (context, index){
              return OrderTile(snapshot.data[index]);// Pra cada um dos itens vou criar um orderTile e vou passar este item
            },
          );
        }
      ),
    );
  }
}
