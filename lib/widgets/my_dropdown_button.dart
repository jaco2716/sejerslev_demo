import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/providers/select_type_provider.dart';

class MyDropdownButton extends StatelessWidget {
  final Color? backgroundColor;
  final Color? forgroundColor;
  const MyDropdownButton({
    Key? key,
    required this.selectTypeListProvider,
    this.backgroundColor = Colors.blue,
    this.forgroundColor = Colors.white,
  }) : super(key: key);

  final SelectTypeListProvider selectTypeListProvider;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: backgroundColor),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        // width: double.infinity,
        child: DropdownButton<SelectType>(
          value: selectTypeListProvider.selectType[selectTypeListProvider.indexSelected],
          icon: const Icon(Icons.arrow_drop_down),
          elevation: 16,
          dropdownColor: backgroundColor,
          iconEnabledColor: forgroundColor,
          borderRadius: BorderRadius.circular(5),
          isExpanded: true,
          style: TextStyle(color: forgroundColor, fontSize: 15),
          underline: const SizedBox.shrink(),
          onChanged: (SelectType? newValue) {
            if (newValue != null) {
              context.read<SelectTypeListProvider>().changeSelected(newValue.id);
            }
          },
          items: selectTypeListProvider.selectType.map<DropdownMenuItem<SelectType>>((SelectType value) {
            return DropdownMenuItem<SelectType>(
              value: value,
              child: Row(
                children: [
                  value.leading != null
                      ? Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: Theme(data: ThemeData(iconTheme: IconThemeData(color: forgroundColor)), child: value.leading!),
                        )
                      : const SizedBox.shrink(),
                  const SizedBox(width: 6),
                  Text(
                    value.title,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
