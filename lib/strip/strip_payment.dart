import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class StripPaymentScreen extends StatefulWidget {
  const StripPaymentScreen({super.key});

  @override
  State<StripPaymentScreen> createState() => _StripPaymentScreenState();
}

class _StripPaymentScreenState extends State<StripPaymentScreen> {
  void onTapDonate(context) async {

    var paymentIntent = await createPayment();
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: paymentIntent!['client_secret'],
        merchantDisplayName: "Testing",
      ),
    );
    diaplaySheet();
  }

  diaplaySheet() async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) {
        print("Success Payment ${value}");
      });
    } catch (e) {
      print(e.toString());
    }
  }

  createPayment() async {
    Map<String, dynamic> map = {
      "amount": "1000",
      "currency": "inr",
      "payment_method_types[]": 'card'
    };
    var response =
        await http.post(Uri.parse("https://api.stripe.com/v1/payment_intents"),
            headers: {
              'Authorization':
                  'Bearer sk_test_fN0nlTWQP1hWQPlBHwWgymyH00cBpfhnnh',
              'Content-Type': 'application/x-www-form-urlencoded'
            },
            body: map);
    print(response.body);
    return jsonDecode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Strip Payment"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          onTapDonate(context);
        },
        child: Text("Pay"),
      ),
    );
  }
}
