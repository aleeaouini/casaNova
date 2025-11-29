import 'package:flutter/material.dart';
import 'package:imobilier/pages/profile.dart';
import 'package:imobilier/pages/about.dart';
import 'package:imobilier/pages/map_page.dart';

class AppDrawer extends StatelessWidget {
  final Function(int) onItemSelected;
  final Map<String, dynamic> user;

  const AppDrawer({Key? key, required this.onItemSelected, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.orange.shade50, Colors.white],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.orange, Colors.deepOrange]),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.3),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(Icons.home_work, size: 50, color: Colors.white),
                  ),
                  SizedBox(height: 15),
                  Text(
                    "Estately Menu",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(context, icon: Icons.home_rounded, title: "Home", index: 0),
            _buildDrawerItem(context, icon: Icons.person_rounded, title: "Profile", index: 1),
            _buildDrawerItem(context, icon: Icons.settings_rounded, title: "Settings", index: 2),
            Divider(height: 30, thickness: 1, indent: 20, endIndent: 20),
            _buildDrawerItem(context, icon: Icons.map_rounded, title: "Map", index: 3),
            _buildDrawerItem(context, icon: Icons.info_rounded, title: "About", index: 4),
            _buildDrawerItem(context, icon: Icons.logout_rounded, title: "Logout", index: 5, isDestructive: true),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context,
      {required IconData icon, required String title, required int index, bool isDestructive = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDestructive ? Colors.red.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: isDestructive ? Colors.red : Colors.orange),
        ),
        title: Text(
          title,
          style: TextStyle(color: isDestructive ? Colors.red : Colors.grey.shade800),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
        onTap: () {
          Navigator.pop(context);
          onItemSelected(index);
        },
      ),
    );
  }
}
