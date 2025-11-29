import 'package:flutter/material.dart';
import 'EditProfile.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/app_drawer.dart';
import 'about.dart';
import 'map_page.dart';
class ProfilePage extends StatefulWidget {
  final Map<String, dynamic> user;

  const ProfilePage({Key? key, required this.user}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Map<String, dynamic> user;
  final Color primaryColor = Colors.orange;

  @override
  void initState() {
    super.initState();
    user = widget.user;
  }

  Future<void> reloadUser() async {
    try {
      final response = await http.get(
        Uri.parse("http://192.168.185.146:5000/auth/profile/${user['id']}"),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          user = data['user'];
        });
      }
    } catch (e) {
      print("Erreur reloadUser: $e");
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Déconnexion"),
        content: const Text("Êtes-vous sûr ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            child: const Text("Déconnexion", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // 👉 Drawer added here
      drawer: AppDrawer(
  user: user,
  onItemSelected: (index) {
    Navigator.pop(context);
    switch (index) {
      case 0:
        Navigator.pushNamed(context, "/home");
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProfilePage(user: user)),
        );
        break;
      case 2:
        Navigator.pushNamed(context, "/settings");
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MapPage(user: user)),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AboutPage(user: user)),
        );
        break;
      case 5:
        _logout(); // si tu veux gérer logout ici
        break;
    }
  },
),


      appBar: AppBar(
        title: const Text("Profil",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [

            // ---------------- PHOTO DE PROFIL ----------------
            Stack(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: primaryColor, width: 3),
                    color: Colors.grey.shade100,
                  ),
                  child: ClipOval(
                    child: user['photo'] != null
                        ? Image.network(
                            "http://192.168.180.146:5000/uploads/${user['photo']}",
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(Icons.person, size: 50, color: Colors.grey),
                          )
                        : Icon(Icons.person, size: 50, color: Colors.grey),
                  ),
                ),

                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: const Icon(Icons.verified, size: 18, color: Colors.white),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Text(
              user['firstName'] ?? "Utilisateur",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 5),

            Text(
              "Membre Estately",
              style: TextStyle(color: Colors.grey.shade600),
            ),

            const SizedBox(height: 30),

            // ---------------- INFORMATIONS ----------------
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildProfileItem(
                    icon: Icons.email_outlined,
                    title: "Email",
                    value: user['email'] ?? "Non renseigné",
                  ),
                  Divider(height: 1, color: Colors.grey.shade200),
                  _buildProfileItem(
                    icon: Icons.phone_outlined,
                    title: "Téléphone",
                    value: user['phone'] ?? "Non renseigné",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () async {
                final updated = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditProfile(user: user),
                  ),
                );

                if (updated == true) await reloadUser();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                minimumSize: const Size(double.infinity, 52),
              ),
              child: const Text("Modifier le profil"),
            ),

            const SizedBox(height: 15),

            OutlinedButton(
              onPressed: _logout,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: BorderSide(color: Colors.red.shade300),
                minimumSize: const Size(double.infinity, 52),
              ),
              child: const Text("Se déconnecter"),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
