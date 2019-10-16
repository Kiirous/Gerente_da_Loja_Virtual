import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CouponScreen extends StatefulWidget {

  final String categoryId;
  final DocumentSnapshot coupon;


  //final _formKey = GlobalKey<FormState>();

  CouponScreen({this.categoryId, this.coupon});


  @override
  _CouponScreenState createState() => _CouponScreenState();
}

class _CouponScreenState extends State<CouponScreen> {

  TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {

    InputDecoration _buildDecoration(String label){
      return InputDecoration(suffixText: "%",
          suffixStyle: TextStyle(color: Colors.white),
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey)
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[850],
      appBar: AppBar(
        elevation: 0,
        title: Text('Editar Cupom', style: TextStyle(color: Colors.grey[850]),),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.remove, color: Colors.grey[850]),
            onPressed: (){
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Deseja realmente excluir o cupom?', style: TextStyle(color: Colors.grey[850]),),
                  actions: <Widget>[
                    FlatButton(
                      child:Text('Não', style: TextStyle(color: Colors.red, fontSize: 17)),
                      onPressed: (){
                        Navigator.pop(context, false);
                      },
                    ),
                    FlatButton(
                        child: Text('Sim', style: TextStyle(color: Colors.green, fontSize: 17)),
                        onPressed:  (){
                          widget.coupon.reference.delete();

                          Navigator.of(context).popUntil((route) => route.isFirst);
                        }
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.save, color: Colors.grey[850]),
            onPressed: (){
              widget.coupon.reference.updateData({'percent': int.parse(_controller.text)});
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          Form(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: <Widget>[
                TextField(
                  style: TextStyle(color: Colors.white),
                    decoration: _buildDecoration('Porcentagem'),
                  controller: _controller,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
