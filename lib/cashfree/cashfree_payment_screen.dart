import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_cashfree_pg_sdk/api/cferrorresponse/cferrorresponse.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfwebcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfexceptions.dart';
import 'package:http/http.dart' as http;

class CashFreePaymentScreen extends StatefulWidget {
  const CashFreePaymentScreen({super.key});

  @override
  State<CashFreePaymentScreen> createState() => _CashFreePaymentScreenState();
}

class _CashFreePaymentScreenState extends State<CashFreePaymentScreen> {
  var cfPaymentGatewayService = CFPaymentGatewayService();
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    cfPaymentGatewayService.setCallback(verifyPayment, onError);
  }

  void verifyPayment(String orderId) {
    print("Verify Payment $orderId");
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Verify Payment $orderId"),
    ));
  }

  void onError(CFErrorResponse errorResponse, String orderId) {
    print(errorResponse.getMessage());
    print("Error while making payment");
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("${errorResponse.getMessage()}"),
    ));
  }

  webCheckout() async {
    try {
      var session = await createSession();
      if (session != null) {
        var cfWebCheckout =
            CFWebCheckoutPaymentBuilder().setSession(session).build();
        cfPaymentGatewayService.doPayment(cfWebCheckout);
      }
    } on CFException catch (e) {
      print(e.message);
    }
  }

  Future<CFSession?> createSession() async {
    try {
      var response = await createPayment();
      if (response['cf_order_id'] != null) {
        var session = CFSessionBuilder()
            .setEnvironment(CFEnvironment.SANDBOX)
            .setOrderId(response['order_id'])
            .setPaymentSessionId(response['payment_session_id'])
            .build();
        return session;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("${response['message']}"),
        ));
      }
    } on CFException catch (e) {
      print(e.message);
    }
    return null;
  }

  createPayment() async {
    Map<String, dynamic> map = {
      "order_amount": 100,
      "order_currency": "INR",
      "order_id": controller.text.trim(),
      "customer_details": {
        "customer_id": "123",
        "customer_name": "Ravi Patel",
        "customer_email": "ravi@gmail.com",
        "customer_phone": "+91999999999"
      },
      "order_meta": {"notify_url": "https://test.cashfree.com"},
      "order_note": "some order note here"
    };
    var response = await http.post(
      Uri.parse("https://sandbox.cashfree.com/pg/orders"),
      headers: {
        'x-client-id': 'TEST347408fa383aaf589f69bca12d804743',
        'x-client-secret': 'TESTeedf2229201a3233b00cbf47a4834fc818cb6fbf',
        'x-api-version': '2022-09-01',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(map),
    );
    print(response.body);
    var result = jsonDecode(response.body);
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cashfree Payment"),
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(label: Text("Order Id")),
              controller: controller,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (controller.text.trim().isNotEmpty) webCheckout();
        },
        child: const Text("Pay"),
      ),
    );
  }
}
