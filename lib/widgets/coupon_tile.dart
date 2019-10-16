import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gerente_loja/screens/coupon_screen.dart';

class CouponTile extends StatelessWidget {

  final DocumentSnapshot category;
  
  CouponTile(this.category);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        child: ExpansionTile(
            title: Text('Cupom: ${category.documentID}'),
          children: <Widget>[
            Column(
              children: <Widget>[
                GestureDetector(
                  child: ListTile(
                    title: Text('Desconto: ${category.data['percent'] == null ? '0' : category.data['percent']}%'),
                  ),
                  onTap: (){
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context)=> CouponScreen(
                          categoryId: category.documentID,
                          coupon: category,
                        )));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

