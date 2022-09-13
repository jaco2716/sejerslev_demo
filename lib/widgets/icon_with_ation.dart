import 'package:flutter/material.dart';

class IconWithAction extends StatelessWidget {
  final String? title;
  final String? buttonTitle;
  final Icon icon;

  final void Function()? onPressed;
  const IconWithAction({
    Key? key,
    this.title,
    this.buttonTitle,
    this.onPressed,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // if (isEnergyMeter) {
    //   icon = Icons.electric_bolt_rounded;
    //   title = 'Add Energy Meter';
    // } else {
    //   icon = Icons.gas_meter;
    //   title = 'Add Flow Meter';
    // }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon.icon,
          size: 120,
          color: Colors.grey,
        ),
        title != null
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  title!,
                  // style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              )
            : const SizedBox.shrink(),
        onPressed != null
            ? Padding(
                padding: const EdgeInsets.all(20.0),
                child: ElevatedButton(onPressed: onPressed, child: Text(buttonTitle ?? '')),
              )
            : const SizedBox.shrink(),
        const SizedBox(height: kToolbarHeight),
      ],
    );
  }
}
