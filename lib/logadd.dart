import 'package:flutter/material.dart';

class LogAdd extends StatelessWidget {
  const LogAdd({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, 
      padding: const EdgeInsets.all(16), 

      child: Column(
        mainAxisSize: MainAxisSize.min, 
        crossAxisAlignment:
            CrossAxisAlignment.stretch, 

        children: [
          
          ListTile(
            leading: const Icon(
              Icons.rice_bowl,
              color: Color.fromRGBO(24, 2, 12, 121),
            ),
            title: const Text(
              "Food and Water Log",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            onTap: () {
              Navigator.pop(context); 
              Navigator.pushReplacementNamed(
                context,
                '/food&water',
              ); 
            },
          ),
          const Divider(thickness: 1),

        
          ListTile(
            leading: const Icon(
              Icons.local_activity,
              color: Color.fromRGBO(24, 2, 12, 121),
            ),
            title: const Text(
              "Activity Log",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            onTap: () {
              Navigator.pop(context); 
              Navigator.pushReplacementNamed(
                context,
                '/activity',
              ); 
            },
          ),
          const Divider(thickness: 1),
        ],
      ),
    );
  }
}
