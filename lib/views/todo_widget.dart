import 'package:flutter/material.dart';

class TodoWidget extends StatelessWidget {
  final String text;
  final bool isDone;

  TodoWidget({this.text, @required this.isDone});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 24.0),
      child: Row(
        children: [
          Container(
            width: 20.0,
            height: 20.0,
            margin: EdgeInsets.only(right: 12.0),
            decoration: BoxDecoration(
                color: isDone ? Color(0xFF7349FE) : Colors.transparent,
                border: isDone ? null : Border.all(
                  color: Color(0xFF86829D),
                  width: 1.5
                ),
                borderRadius: BorderRadius.circular(5.0)
            ),
            child: Image(image: AssetImage('assets/images/check_icon.png')),
          ),
          Flexible(
            child: Text(
              text ?? '(Unnamed Todo)',
              style: TextStyle(
                  color: isDone ? Color(0xFF211551) : Color(0xFF86829D),
                  fontSize: 16.0,
                  fontWeight: isDone ? FontWeight.bold : FontWeight.w500
              ),
            ),
          ),
        ],
      ),
    );
  }
}
