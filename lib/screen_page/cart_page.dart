import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_app_fluter/DAO/cartDAO.dart';
import 'package:my_app_fluter/modal/cart.dart';
import 'package:my_app_fluter/screen_page/googlemap_picker.dart';
import 'package:my_app_fluter/screen_page/login_screen.dart';
import 'package:my_app_fluter/utils/push_screen.dart';
import 'package:my_app_fluter/utils/showToast.dart';
import 'package:my_app_fluter/utils/show_bottom_sheet.dart';

class CartPage extends StatefulWidget {
  final bool fromToDetail;
  const CartPage({super.key, required this.fromToDetail});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage>
    with AutomaticKeepAliveClientMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  //Đường dẫn
  final CollectionReference _cart =
      FirebaseFirestore.instance.collection('cart');
  List<Cart> listCart = [];

  final tong = ValueNotifier<double>(0.0);
  String uid = 'abc';

  @override
  void initState() {
    super.initState();
    if (_auth.currentUser != null) {
      uid = _auth.currentUser!.uid;
    } else {
      showToast('Bạn Phải Đăng Nhập Trước', Colors.red);
      pushReplacement(context, const Login());
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Cart Page",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: widget.fromToDetail,
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: StreamBuilder(
                  stream: _cart
                      .doc(uid)
                      // .doc(_auth.currentUser!.uid)
                      .collection('cart')
                      .snapshots(),
                  builder:
                      (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                    if (streamSnapshot.hasData) {
                      listCart.clear();
                      double _total = 0.0;
                      for (var element in streamSnapshot.data!.docs) {
                        var _item = Cart.fromMap(
                            (element.data() as Map<String, dynamic>));
                        _total += _item.tongtien!;
                        listCart.add(_item);
                      }

                      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                        tong.value = _total;
                      });

                      return listCart.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(top: 150),
                              child: Image.asset('assets/images/nothing.png'),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: listCart.length,
                              itemBuilder: (context, index) {
                                return _itemCart(index);
                              },
                            );
                    }
                    return const Card();
                  },
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromARGB(255, 176, 176, 176),
                    offset: Offset(0.0, 1), //(x,y)
                    blurRadius: 10.0,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: ListTile(
                      title: const Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                        child: Text('Total Price'),
                      ),
                      subtitle: ValueListenableBuilder<double>(
                          valueListenable: tong,
                          builder: (context, value, child) {
                            return Text(
                              '\$' + value.toString(),
                              // tong.toString(),
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold),
                            );
                          }),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
                      height: 56,
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: ElevatedButton.icon(
                          icon: const Icon(FontAwesomeIcons.upRightFromSquare),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              elevation: 8,
                              shape: (RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(130)))),
                          onPressed: () {
                            if (_auth.currentUser != null) {
                              if (listCart.isEmpty) {
                                showToast('Giỏ Hàng Đang Trống', Colors.red);
                                return;
                              }
                              pushScreen(
                                  context,
                                  GoogleMapPicker(
                                    listCart: listCart,
                                  ));
                              return;
                            }
                          },
                          label: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'CHECK OUT',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quantily(int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(5),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color.fromARGB(255, 255, 255, 255),
            ),
            child: Text(
              '\$${(listCart[index].giasp! * listCart[index].slsp).toStringAsFixed(1)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 253, 253, 253),
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () {
                    setState(
                      () {
                        if (listCart[index].slsp != 1) {
                          listCart[index].slsp = (listCart[index].slsp - 1);
                          listCart[index].tongtien =
                              listCart[index].giasp! * listCart[index].slsp;
                          updateCart(listCart[index]);

                          // tong = 0;
                          // for (int i = 0; i < listCart.length; i++) {
                          //   tong += listCart[i].tongtien!;
                          //   log("Cong " + tong.toString());
                          // }
                        }
                      },
                    );
                  },
                  icon: const Icon(FontAwesomeIcons.minus),
                ),
                Text(
                  '${listCart[index].slsp}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () {
                    setState(
                      () {
                        listCart[index].slsp += 1;
                        listCart[index].tongtien =
                            listCart[index].giasp! * listCart[index].slsp;
                        updateCart(listCart[index]);
                        // tong = 0;
                        // for (int i = 0; i < listCart.length; i++) {
                        //   tong += listCart[i].tongtien!;
                        //   log("Cong " + tong.toString());
                        // }
                      },
                    );
                  },
                  icon: const Icon(FontAwesomeIcons.plus),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _itemCart(index) {
    return Slidable(
      key: UniqueKey(),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        // dismissible: DismissiblePane(onDismissed: () {
        //   dialogModalBottomsheet(
        //       context, 'Delete', () => deleteCart(listCart[index]));
        // }),
        children: [
          SlidableAction(
            borderRadius: const BorderRadius.all(
              Radius.circular(20),
            ),
            spacing: 10,
            onPressed: (context) {
              dialogModalBottomsheet(
                  context, 'Delete', () => deleteCart(listCart[index]));
            },
            backgroundColor: const Color.fromARGB(255, 245, 55, 55),
            // foregroundColor: Colors.white,
            icon: FontAwesomeIcons.trashCan,
            label: 'DELETE',
          ),
        ],
      ),
      child: Container(
        height: 150,
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
          color: Color.fromARGB(255, 226, 235, 247),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(20),
                  ),
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
                child: Image.network(
                  listCart[index].urlImage!,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                margin: const EdgeInsets.only(left: 10),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Wrap(
                            children: [
                              Text(
                                listCart[index].tensp!,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            dialogModalBottomsheet(context, 'Delete',
                                () => deleteCart(listCart[index]));
                          },
                          icon: const Icon(
                            FontAwesomeIcons.trashCan,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${listCart[index].mausp!}  |  Size = ${listCart[index].kichcosp!}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: _quantily(index),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
