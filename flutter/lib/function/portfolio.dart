import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_tag_editor/tag_editor.dart';
import 'package:provider/provider.dart';
import 'package:usdh/Widget/widget.dart';
import 'package:usdh/login/firebase_provider.dart';

late PortfolioState pageState;

class Portfolio extends StatefulWidget {
  @override
  PortfolioState createState() {
    pageState = PortfolioState();
    return pageState;
  }
}

class PortfolioState extends State<Portfolio> {
  late FirebaseProvider fp;
  TextEditingController introInput = TextEditingController();
  TextEditingController specInput = TextEditingController();
  TextEditingController tagInput = TextEditingController();
  final FirebaseFirestore fs = FirebaseFirestore.instance;
  bool inputcheck = true;
  List tagList = [];

  final _formKey = GlobalKey<FormState>();
  GlobalKey<AutoCompleteTextFieldState<String>> key = new GlobalKey();

  _onDelete(index) {
    setState(() {
      tagList.removeAt(index);
    });
  }

  @override
  void dispose() {
    introInput.dispose();
    specInput.dispose();
    tagInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    fp = Provider.of<FirebaseProvider>(context);
    fp.setInfo();

    if(fp.getInfo()['portfolio'].length != 0){
      introInput = TextEditingController(text: fp.getInfo()['portfolio'][0]);
      specInput = TextEditingController(text: fp.getInfo()['portfolio'][1]);
      tagInput = TextEditingController(text: fp.getInfo()['portfolio'][2]);
    }

    if(fp.getInfo()['portfolio'].length != 0)
      inputcheck = false;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            cSizedBox(35, 0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                cSizedBox(0, 5),
                IconButton(
                  icon: Image.asset('assets/images/icon/iconback.png', width: 22, height: 22),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                cSizedBox(0, 10),
                headerText("내 포트폴리오"),
                cSizedBox(0, 200),
                ],
            ),
            headerDivider(),
            Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 40)),
            Form(
              key: _formKey,
              child:
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    inputNav2('assets/images/icon/iconme.png', "  자기소개"),
                    Container(
                      height: 140,
                      margin: EdgeInsets.fromLTRB(35, 10, 35, 0),
                      child: TextFormField(
                        controller: introInput,
                        keyboardType: TextInputType.multiline,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(200),
                        ],
                        maxLines: 6,
                        style: TextStyle(fontFamily: "SCDream", color: Colors.grey[800], fontWeight: FontWeight.w400, fontSize: 14),
                        decoration:
                          (inputcheck)?
                            InputDecoration(
                              hintText: "200자 이내의 자기소개 글을 작성해주세요.",
                              hintStyle: TextStyle(fontFamily: "SCDream", color: Colors.grey[400], fontWeight: FontWeight.w400, fontSize: 14),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey.shade400, width: 0.5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey.shade400, width: 0.5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            )
                            : InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey.shade400, width: 0.5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey.shade400, width: 0.5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          validator: (text) {
                            if (text == null || text.isEmpty) {
                              return "자기소개를 입력하지 않으셨습니다.";
                            }
                            return null;
                          }),
                    ),
                    Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 50)),
                    inputNav2('assets/images/icon/iconwin.png', "  경력"),
                    Container(
                      height: 140,
                      margin: EdgeInsets.fromLTRB(35, 10, 35, 0),
                      child: TextFormField(
                        controller: specInput,
                        keyboardType: TextInputType.multiline,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(200),
                        ],
                        maxLines: 6,
                        style: TextStyle(fontFamily: "SCDream", color: Colors.grey[800], fontWeight: FontWeight.w400, fontSize: 14),
                        decoration:
                          (inputcheck)?
                            InputDecoration(
                              hintText: "어필할 경력 혹은 스펙들을 입력하세요.",
                              hintStyle: TextStyle(fontFamily: "SCDream", color: Colors.grey[400], fontWeight: FontWeight.w400, fontSize: 14),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey.shade400, width: 0.5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey.shade400, width: 0.5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            )
                          : InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey.shade400, width: 0.5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey.shade400, width: 0.5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          )
                      ),
                    ),
                    Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 50)),
                    inputNav2('assets/images/icon/icontag.png', "  태그"),
                    Container(
                      //height: 140,
                      margin: EdgeInsets.fromLTRB(35, 10, 35, 30),
                      child: TagEditor(
                        key: key,
                        controller: tagInput,
                        keyboardType: TextInputType.multiline,
                        length: tagList.length,
                        delimiters: [',', ' '],
                        hasAddButton: false,
                        resetTextOnSubmitted: true,
                        //maxLines: 7,
                        textStyle: TextStyle(fontFamily: "SCDream", color: Color(0xffa9aaaf), fontWeight: FontWeight.w500, fontSize: 14),
                        inputDecoration:
                        InputDecoration(
                          labelText: "자신을 나타낼 수 있는 태그를 입력해주세요.",
                          labelStyle: TextStyle(fontFamily: "SCDream", color: Colors.grey[400], fontWeight: FontWeight.w400, fontSize: 14),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade400, width: 0.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade400, width: 0.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onSubmitted: (outstandingValue) {
                          setState(() {
                            tagList.add(outstandingValue);
                          });
                        },
                        onTagChanged: (newValue) {
                          setState(() {
                            tagList.add("#" + newValue + " ");
                          });
                        },
                        tagBuilder: (context, index) => _Chip(
                          index: index,
                          label: tagList[index],
                          onDeleted: _onDelete,
                        ),
                      )
                    ),
                    Container(
                      alignment: Alignment(1.0, 0.0),
                      height: 30,
                      margin: EdgeInsets.fromLTRB(0, 0, 40, 40),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Color((0xff639ee1)),
                        ),
                        child: Text(
                          "저장",
                          style: TextStyle(fontFamily: "SCDream", color: Colors.white, fontWeight: FontWeight.w400, fontSize: 13),
                        ),
                        onPressed: () {
                          FocusScope.of(context).requestFocus(new FocusNode());
                          if (_formKey.currentState!.validate()) {
                            uploadOnFS();
                            Navigator.pop(context);
                          }
                        },
                      )
                    ),
                  ],
                )
            )
          ]
        )
      )
    );
  }

  void uploadOnFS() async {
    List<String> list = [introInput.text, specInput.text, tagInput.text];

    await fs.collection('users').doc(fp.getUser()!.email).update({
      'portfolio': list,
    });
  }
}



class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.onDeleted,
    required this.index,
  });

  final String label;
  final ValueChanged<int> onDeleted;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Chip(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      labelStyle: TextStyle(fontFamily: "SCDream", color: Color(0xffa9aaaf), fontWeight: FontWeight.w500, fontSize: 11.5),
      labelPadding: EdgeInsets.only(left: 10),
      backgroundColor: Colors.grey[350],
      label: smallText(label, 13, Colors.white),
      deleteIcon: const Icon(
        Icons.close,
        color: Colors.white,
        size: 13,
      ),
      onDeleted: () {
        onDeleted(index);
      },
    );
  }
}