import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_app_fluter/PDF/print_pdf.dart';
import 'package:my_app_fluter/modal/receipt.dart';
import 'package:my_app_fluter/screen_page/receipt_detail_screen.dart';
import 'package:my_app_fluter/utils/push_screen.dart';

class UnfinishReceiptPage extends StatefulWidget {
  const UnfinishReceiptPage({super.key});

  @override
  State<UnfinishReceiptPage> createState() => _UnfinishReceiptPageState();
}

class _UnfinishReceiptPageState extends State<UnfinishReceiptPage> {
  final CollectionReference _receipt =
      FirebaseFirestore.instance.collection('receipt');
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Receipt> listReceipt = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: StreamBuilder(
            stream: _receipt
                .doc(_auth.currentUser!.uid)
                .collection('receipt')
                .where('status', isEqualTo: false)
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
              if (streamSnapshot.hasData) {
                listReceipt.clear();
                for (var element in streamSnapshot.data!.docs) {
                  var _item = Receipt.fromMap(
                    (element.data() as Map<String, dynamic>),
                  );
                  listReceipt.add(_item);
                }
                // log(listReceipt[0].toString());
                return listReceipt.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(top: 150),
                        child: Image.asset('assets/images/nothing.png'),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: listReceipt.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              pushScreen(
                                  context,
                                  ReceiptDetail(
                                    receipt: listReceipt[index],
                                  ));
                            },
                            child: Container(
                              height: 150,
                              width: double.infinity,
                              margin: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: const Color.fromARGB(255, 236, 236, 236),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color.fromARGB(255, 187, 187, 187),
                                    offset: Offset(0.0, 1), //(x,y)
                                    blurRadius: 10.0,
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  Row(
                                    children: [
                                      const Expanded(
                                        flex: 1,
                                        child: CircleAvatar(
                                          radius: 36,
                                          backgroundColor: Colors.black,
                                          child: Icon(
                                            FontAwesomeIcons.truckFast,
                                            color: Colors.white,
                                            size: 26,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: const [
                                                  Text('Code Bill:'),
                                                  Text('Date created:'),
                                                  Text('Total Price:'),
                                                  Text('Status:'),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    listReceipt[index]
                                                        .mahoadon!,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16),
                                                  ),
                                                  Text(
                                                    listReceipt[index]
                                                        .ngaytaohd!
                                                        .toString(),
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16),
                                                  ),
                                                  Text(
                                                    '\$${listReceipt[index].tongtien!.toStringAsFixed(3)}',
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16),
                                                  ),
                                                  Wrap(
                                                    children: const [
                                                      Text(
                                                        'Chưa Hoàn Thành',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 16),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: IconButton(
                                      onPressed: () {
                                        printPdf(
                                          listReceipt[index],
                                        );
                                      },
                                      icon: const Icon(
                                        FontAwesomeIcons.print,
                                        size: 26,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
              }
              return const Card();
            },
          ),
        ),
      ),
    );
  }
}
