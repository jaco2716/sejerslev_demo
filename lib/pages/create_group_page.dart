import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sejerslev_demo/logic/file_handler.dart';
import 'package:sejerslev_demo/model/my_group.dart';
import 'package:sejerslev_demo/widgets/my_scrollview_w_constraints.dart';

import '../logic/validate_values.dart';
import '../model/providers/select_type_provider.dart';
import '../widgets/my_alert_dialog.dart';
import '../widgets/my_dropdown_button.dart';
import '../widgets/my_text_field.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({Key? key}) : super(key: key);

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final ValidateValues _validateValues = ValidateValues();
  final FileHandler _fileHandler = FileHandler();
  final _formKey = GlobalKey<FormState>();

  String? _title;
  String? _description;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Add Group')),
        body: SafeArea(
          child: MyConstrainedView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ChangeNotifierProvider(
                create: (context) => SelectTypeListProvider([
                  SelectType(0, 'Indoor', leading: const Icon(Icons.house_rounded)),
                  SelectType(1, 'Outdoor', leading: const Icon(Icons.cloud)),
                ]),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Consumer<SelectTypeListProvider>(
                          builder: (context, value, child) => MyDropdownButton(
                                selectTypeListProvider: value,
                                // backgroundColor: Colors.white,
                                // forgroundColor: Colors.black,
                              )),
                      MyTextFieldWidget(
                        icon: const Icon(Icons.view_headline_rounded),
                        // autofillHints: const [AutofillHints.name],
                        labelText: 'Title',
                        // textInputType: TextInputType.name,
                        textCapitalization: TextCapitalization.sentences,
                        isRequired: false,
                        setValue: (value) => _title = value,
                        validate: (value) => _validateValues.validateString(value),
                      ),
                      MyTextFieldWidget(
                        icon: const Icon(Icons.subdirectory_arrow_right_rounded),
                        // autofillHints: const [AutofillHints.password],
                        labelText: 'Description',
                        isRequired: false,
                        textCapitalization: TextCapitalization.sentences,
                        setValue: (value) => _description = value,
                        validate: (value) => null,
                      ),
                      SizedBox(height: 20),
                      Consumer<SelectTypeListProvider>(builder: (context, value, child) {
                        return SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    _formKey.currentState!.save();
                                    var leading = value.indexSelected == 0 ? GroupCategory.indoor : GroupCategory.outdoor;
                                    int groupId = DateTime.now().millisecondsSinceEpoch;
                                    var newGroup = MyGroup(id: groupId, title: _title!, description: _description ?? '', groupCategory: leading);
                                    List<MyGroup> grouplist = [
                                      newGroup,
                                      newGroup,
                                      newGroup,
                                    ];
                                    // await _fileHandler.writeFile(JsonFileName.groupsJsonFile, '');
                                    await _fileHandler.addObjectToJsonListFile(JsonFileName.groupsJsonFile, jsonEncode(newGroup));
                                    if (mounted) {
                                      Navigator.pop(context);
                                    }
                                  }
                                },
                                child: Text('Create Group')));
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}
