import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddNewCoupon extends StatefulWidget {

  @override
  _AddNewCouponState createState() => _AddNewCouponState();
}

class _AddNewCouponState extends State<AddNewCoupon> {

  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.only(right: 8, left: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Nome do Cupom:', style: TextStyle(fontSize: 17),),
              TextField(
                controller: _controller,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  FlatButton(
                    child: Text('Salvar'),
                    onPressed: () {
                      Firestore.instance
                          .collection('coupons').document(_controller.text).setData({"percent": 0});
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
