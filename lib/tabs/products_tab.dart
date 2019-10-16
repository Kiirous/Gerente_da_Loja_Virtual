import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gerente_loja/widgets/category_tile.dart';

class ProductsTab extends StatefulWidget {
  @override
  _ProductsTabState createState() => _ProductsTabState();
}

class _ProductsTabState extends State<ProductsTab> with AutomaticKeepAliveClientMixin{ // essa extensao dps do with é pra
  // manter a tile "viva", pois caso o usuário sair da tela e voltar, nao vai precisar carregar novamente.
  @override
  Widget build(BuildContext context) {
    super.build(context); // É necessário um super quando se usa o AutomaticKeepAliveClientMixin

    return StreamBuilder<QuerySnapshot>( //Vamos Usar StreamBuilder pois não precisamos atualizar isso em tempo real.
      stream: Firestore.instance.collection('products').snapshots(), //Obtendo os documentos do firebase.
      builder: (context, snapshot){
        if(!snapshot.hasData) return Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Color.fromARGB(254, 242, 193, 94)),
          ),
        );
        return ListView.builder(
          itemCount: snapshot.data.documents.length, //Pegar o tamanho da lista
            itemBuilder: (context, index){
            return CategoryTile(snapshot.data.documents[index]); // Criar a lista de categorias na tela.
            }
        );
      },
    );
  }

  @override

  bool get wantKeepAlive => true; // deixar true para o AutomaticKeepAliveClientMixin manter a tela viva.
}
