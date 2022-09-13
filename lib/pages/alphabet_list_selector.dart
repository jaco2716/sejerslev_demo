import 'dart:convert';
import 'dart:math';
import 'package:azlistview/azlistview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../model/country_code.dart';

class AlphabetListSelector extends StatefulWidget {
  const AlphabetListSelector({Key? key}) : super(key: key);

  @override
  State<AlphabetListSelector> createState() => _AlphabetListSelectorState();
}

class _AlphabetListSelectorState extends State<AlphabetListSelector> {
  int selectedIndex = 0;
  TextEditingController searchController = TextEditingController();
  List<String> strList = [];
  List<CountryCode> countryList = [];
  List<CountryCode> dataList = [];
  final TextEditingController textEditingController = TextEditingController();

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(),
  //     body: Expanded(
  //       child: Text('color: Colors.red'),
  //     ),
  //   );
  // }

  void loadData() {
    rootBundle.loadString('assets/data/country_codes.json').then((value) {
      List list = json.decode(value);
      // print(list);
      countryList = list.map((e) => CountryCode.fromJson(e)).toList();
      for (int i = 0, length = countryList.length; i < length; i++) {
        String tag = countryList[i].country.substring(0, 1).toUpperCase();
        if (RegExp("[A-Z]").hasMatch(tag)) {
          countryList[i].tagIndex = tag;
        } else {
          countryList[i].tagIndex = "#";
        }
      }
      // print(countryList);
      _handleList(countryList);
    });
  }

  void _handleList(List<CountryCode> list) {
    dataList.clear();
    if (list.isEmpty) {
      setState(() {});
      print('empty');
      return;
    }

    dataList.addAll(list);

    // A-Z sort.
    SuspensionUtil.sortListBySuspensionTag(dataList);

    // show sus tag.
    SuspensionUtil.setShowSuspensionStatus(dataList);

    // add header.
    // countyList.insert(0, CountryCode(country: 'header',  code: 1, tagIndex: '↑'));

    setState(() {});
  }

  @override
  void initState() {
    loadData();
    // print(countryList);
    // strList = countryCodes.keys.toList();
    // strList.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    super.initState();
  }

  void _search(String text) {
    if (text.isEmpty) {
      _handleList(countryList);
    } else {
      List<CountryCode> list = countryList.where((v) {
        return v.country.toLowerCase().contains(text.toLowerCase());
      }).toList();
      _handleList(list);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Select Country'),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(40.0),
            child: Container(
              height: 40,
              margin: const EdgeInsets.all(5),
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
              child: TextField(
                autofocus: false,
                onChanged: (value) {
                  _search(value);
                },
                controller: textEditingController,
                decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: Offstage(
                      offstage: textEditingController.text.isEmpty,
                      child: InkWell(
                        onTap: () {
                          textEditingController.clear();
                          _search(textEditingController.text);
                        },
                        child: const Icon(
                          Icons.cancel,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    border: InputBorder.none,
                    hintText: 'Search language',
                    hintStyle: const TextStyle(color: Colors.grey)),
              ),
            )),
      ),
      body: SafeArea(
        bottom: false,
        child: AzListView(
          padding: const EdgeInsets.only(bottom: 20),
          data: dataList,
          itemCount: dataList.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                Navigator.pop(context, dataList[index]);
              },
              child: Ink(
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide()),
                  ),
                  height: 55,
                  child: Center(
                      child: SizedBox(
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: Text(
                              dataList[index].country,
                              style: const TextStyle(fontSize: 16),
                            ),
                          )))),
            );
          },
          // indexBarHeight: 200,
          // indexBarItemHeight: 12,
          // indexBarData:  ['A', 'C', 'E', 'G', 'I', 'K', 'M', 'O', 'Q', 'S', 'U', 'X', 'Z'] : kIndexBarData,
          indexBarOptions: const IndexBarOptions(
            needRebuild: true,
            selectTextStyle: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w500),
            selectItemDecoration: BoxDecoration(),
          ),
        ),
      ),
    );
  }
}
