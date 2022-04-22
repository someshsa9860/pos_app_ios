import 'package:flutter/material.dart';

Widget MyTextFormInput(
        BuildContext context,
        String? value,
        TextInputAction action,
        FocusNode focus,
        TextInputType keyboard,
        FocusNode? next,
        void Function(String?)? key,
        String label) =>
    TextFormField(
      initialValue: value,
      textInputAction: action,
      focusNode: focus,
      keyboardType: keyboard,
      onFieldSubmitted: next!=null?null:(v) {

        FocusScope.of(context).requestFocus(next);
      },
      validator: (v) {
        return null;
      },
      onSaved: key,
      decoration: InputDecoration(
        labelText: label,
        border: InputBorder.none,
      ),
    );
