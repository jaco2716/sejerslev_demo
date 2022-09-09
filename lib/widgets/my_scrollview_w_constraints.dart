import 'package:flutter/material.dart';
import '../res/constants.dart';

class MyConstrainedView extends StatelessWidget {
  final Widget child;
  final bool withScroll;
  final EdgeInsets padding;
  const MyConstrainedView({Key? key, required this.child, this.withScroll = true, this.padding = const EdgeInsets.all(10)}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus!.unfocus(),
      child: SafeArea(
        top: false,
        bottom: false,
        child: withScroll
            ? SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: kMaxWidth),
                    child: Padding(
                      padding: padding,
                      child: child,
                    ),
                  ),
                ),
              )
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: kMaxWidth),
                  child: Padding(
                    padding: padding,
                    child: child,
                  ),
                ),
              ),
      ),
    );
  }
}
