import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gerente_loja/blocs/product_bloc.dart';
import 'package:gerente_loja/validators/product_validator.dart';
import 'package:gerente_loja/widgets/image_widget.dart';
import 'package:gerente_loja/widgets/product_sizes.dart';

class ProductScreen extends StatefulWidget {

 final String categoryId; //Salvando localmente
 final DocumentSnapshot product; //Salvando localmente. OBS: Não vou usar diretamente na tela isso mas caso precise, ja temos aqui.

  ProductScreen({this.categoryId, this.product});
  @override
  _ProductScreenState createState() => _ProductScreenState(categoryId, product);
}

class _ProductScreenState extends State<ProductScreen> with ProductValidator { // o with ProductValidator é pra ter acesso aos validadores.

  final ProductBloc _productBloc;

  _ProductScreenState(String categoryId, DocumentSnapshot product):
        _productBloc = ProductBloc(categoryId: categoryId, product: product);

 final _formKey = GlobalKey<FormState>();
 final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {

    InputDecoration _buildDecoration(String label){
      return InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey)
      );
    }

    final _fieldStyle = TextStyle(
      color: Colors.white,
      fontSize: 16,
    );

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[850],
      appBar: AppBar(
        elevation: 0,
        title: StreamBuilder<bool>(
          stream: _productBloc.outCreated,
          initialData: false,
          builder: (context, snapshot) {
            return Text(snapshot.data == true ? 'Editar Produto' : 'Criar produto');
          }
        ),
        actions: <Widget>[
          StreamBuilder<bool>(
            stream: _productBloc.outCreated,
            initialData: false,
            builder: (context, snapshot){
              if(snapshot.data)
                return StreamBuilder<bool>(
                    stream: _productBloc.outLoading,
                    initialData: false,
                    builder: (context, snapshot) {
                      return IconButton(
                        icon: Icon(Icons.remove, color: Colors.grey[850]),
                        onPressed: (){
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Deseja realmente excluir o produto?', style: TextStyle(color: Colors.grey[850]),),
                              actions: <Widget>[
                                    FlatButton(
                                      child:Text('Não', style: TextStyle(color: Colors.red, fontSize: 17),),
                                      onPressed: (){
                                        Navigator.pop(context, false);
                                      },
                                    ),
                                    FlatButton(
                                        child: Text('Sim', style: TextStyle(color: Colors.green, fontSize: 17),),
                                        onPressed: snapshot.data ? null : (){
                                          _productBloc.deleteProduct();
                                          Navigator.of(context).popUntil((route) => route.isFirst);
                                        }
                                    ),
                              ],
                            ),
                          );
                        }
                      );
                    }
                );
              else return Container(); //Pois retornando um container vazio nao vai mostrar o botão de remover
            },
          ),
          StreamBuilder<bool>(
            stream: _productBloc.outLoading,
            initialData: false,
            builder: (context, snapshot) {
              return IconButton(// Botão salvar
                  icon: Icon(Icons.save, color: Colors.grey[850]),
                  onPressed: snapshot.data ? null : saveProduct, // Se ele está carregando, o botão vai ficar desabilitado, caso contrário, saveProduct.
              );
            }
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          Form( //Form pois vou fazer validações
            key: _formKey,
            child: StreamBuilder<Map>(
              stream: _productBloc.outData, //Emitindo os dados que saem pelo outData na tela
              builder: (context, snapshot) {
                if(!snapshot.hasData) return Container();
                return ListView(
                  padding: EdgeInsets.all(16),
                  children: <Widget>[
                    Text(
                        'Imagens',
                      style: TextStyle(color: Colors.grey,
                      fontSize: 12,
                      ),
                    ),
                    ImagesWidget(
                      context: context,
                      initialValue: snapshot.data['images'],
                      onSaved: _productBloc.saveImages,
                      validator: validateImages,
                    ),
                    TextFormField(
                      initialValue: snapshot.data['title'],
                      style: _fieldStyle,
                      decoration: _buildDecoration('Título'),
                      onSaved: _productBloc.saveTitle,
                      validator: validateTitle,
                    ),
                    TextFormField(
                      initialValue: snapshot.data['description'],
                      style: _fieldStyle,
                      maxLines: 6,
                      decoration: _buildDecoration('Descrição'),
                      onSaved: _productBloc.saveDescription,
                      validator: validateDescription,
                    ),
                    TextFormField(
                      initialValue: snapshot.data['price']?.toStringAsFixed(2), //Interrogação antes do ponto pq caso o valor
                      // price seja nulo ele nem vai tentar emitir as informções, simplesmente vai manter os campos vazios.
                      style: _fieldStyle,
                      decoration: _buildDecoration('Preço'),
                      keyboardType: TextInputType.numberWithOptions(decimal: true), //Ativando teclado de números
                      onSaved: _productBloc.savePrice,
                      validator: validatePrice,
                    ),
                    SizedBox(height: 16,),
                    Text(
                      'Tamanhos',
                      style: TextStyle(color: Colors.grey,
                        fontSize: 17,
                      ),
                    ),
                    SizedBox(height: 5),
                    ProductSizes(
                      context: context,
                      initialValue: snapshot.data['sizes'],
                      onSaved: _productBloc.saveSizes,
                      validator: (s){
                        if(s.isEmpty) return ''; // Não posso retornar nulo pois ele precisa ter um erro no validator.
                      },
                    ),
                  ],
                );
              }
            ),
          ),
          StreamBuilder<bool>(
              stream: _productBloc.outLoading,
              initialData: false,
              builder: (context, snapshot) {
                return IgnorePointer( // Fazendo uma tela que impede de clicar em qualquer coisa na tela. O Sack que está no body que permite um widget sobre outro.
                  //Então assim que clicar no botão salvar, vai ativar este IgnorePointer que desativa o ponteiro e tem como filho a tela ofuscada.
                  //Dessa forma, dá à entender que quando clica em salvar, nao pode clicar em mais nada enquanto está salvando. Macete do Marcola ^^.
                  ignoring: !snapshot.data, // Se estiver carregando ignora o ponteiro
                  child: Container(
                    color: snapshot.data ? Colors.black54 : Colors.transparent,
                  ),
                );
              }
          ),
        ],
      ),
    );
  }

  void saveProduct() async{
   if (_formKey.currentState.validate()){ // Quando clicar para salvar, já chama o validate de todos os campos.
     _formKey.currentState.save(); // Vai chamar o onSave de todos os campos e salvar.

     _scaffoldKey.currentState.showSnackBar(
       SnackBar(content: Text('Salvando Produto...',
         style: TextStyle(color: Colors.grey[850],),
       ),
         duration: Duration(minutes: 1),
         backgroundColor:  Color.fromARGB(254, 242, 193, 94),
       ),
     );

    bool success = await _productBloc.saveProduct(); // realiza o salvamento em background

    _scaffoldKey.currentState.removeCurrentSnackBar(); // Remove a snackbar atual e emite uma nova

     _scaffoldKey.currentState.showSnackBar(
       SnackBar(content: Text(success ? 'Produto salvo!' : 'Erro ao salvar o produto!', style: TextStyle(color: Colors.white),),
         backgroundColor: Colors.green,
       ),
     );
   }
  }
}
