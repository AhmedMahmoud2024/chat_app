import 'package:flutter/material.dart';

class CallButton extends StatelessWidget {
  final IconData icon ;
  final Color color ;
  final Color iconColor ;
  final VoidCallback onPressed ;
  final double size ;
  const CallButton({super.key, 
  required this.icon, required this.color,
   required this.iconColor,
    required this.onPressed,
    this.size = 55});

  @override
  Widget build(BuildContext context) {
      return RawMaterialButton(onPressed: onPressed,
    shape: const CircleBorder(),
    fillColor: color,
    constraints: BoxConstraints.tightFor(
      width: size,height: size
    ),
    child: Icon(icon,color: iconColor,size: size*5,),
    );
  }
}
