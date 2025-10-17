import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class MyAppDropDownMenu<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final String? hint;
  final ValueChanged<T?>? onChanged;
  final Color? borderColor;
  final Color? textColor;
  final Color? dropdownColor;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final List<BoxShadow>? boxShadow;

  const MyAppDropDownMenu({
    super.key,
    required this.items,
    this.value,
    this.hint,
    this.onChanged,
    this.borderColor,
    this.textColor,
    this.dropdownColor,
    this.borderRadius = 12,
    this.padding,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final primaryTextColor = textColor ?? Colors.black87;
    final primaryDropdownColor = dropdownColor ?? Colors.white;
    final primaryBorderColor = borderColor ?? Theme.of(context).primaryColor;

    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: primaryDropdownColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: primaryBorderColor, width: 1.2),
        boxShadow:
            boxShadow ??
            [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<T>(
          isExpanded: true,
          value: value,
          hint: hint != null
              ? Text(
                  hint!,
                  style: TextStyle(
                    color: primaryTextColor.withOpacity(0.7),
                    fontSize: 15,
                  ),
                )
              : null,
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item.value,
              child: DefaultTextStyle.merge(
                style: TextStyle(color: primaryTextColor),
                child: item.child,
              ),
            );
          }).toList(),
          onChanged: onChanged,
          dropdownStyleData: DropdownStyleData(
            decoration: BoxDecoration(
              color: primaryDropdownColor,
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow:
                  boxShadow ??
                  [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
            ),
          ),
        ),
      ),
    );
  }
}
