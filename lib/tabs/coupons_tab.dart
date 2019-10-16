import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gerente_loja/widgets/coupon_tile.dart';

class CouponsTab extends StatefulWidget {
  @override
  _CouponsTabState createState() => _CouponsTabState();
}

class _CouponsTabState extends State<CouponsTab> with AutomaticKeepAliveClientMixin { // estamos usando o mixin e retornando true, indicando que queremos manter o conteúdo da página; portanto, toda vez que a guia é selecionada, o método initState é executado apenas uma vez, no momento da criação.
  @override
  Widget build(BuildContext context) {
    super.build(context);// É necessário um super quando se usa o AutomaticKeepAliveClientMixin

    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('coupons').snapshots(),
      builder: (context, snapshot){
        if(!snapshot.hasData) return Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Color.fromARGB(254, 242, 193, 94)),
          ),
        );
        return ListView.builder(
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index){
              return CouponTile(snapshot.data.documents[index]);// Criar a lista de categorias na tela.
            }
        );
      }
    );
  }

  @override

  bool get wantKeepAlive => true;
}
