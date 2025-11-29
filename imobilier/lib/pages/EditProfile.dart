import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'profile.dart';
import '../widgets/app_drawer.dart';
import 'about.dart';
import 'map_page.dart';


class EditProfile extends StatefulWidget {
  final Map<String, dynamic> user;

  const EditProfile({Key? key, required this.user}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  late TextEditingController firstNameCtrl;
  late TextEditingController lastNameCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController passwordCtrl;
  late TextEditingController confirmPasswordCtrl;
  File? newImage;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  
  final Color primaryColor = Colors.orange;

  @override
  void initState() {
    super.initState();
    firstNameCtrl = TextEditingController(text: widget.user['firstName']);
    lastNameCtrl = TextEditingController(text: widget.user['lastName']);
    emailCtrl = TextEditingController(text: widget.user['email']);
    phoneCtrl = TextEditingController(text: widget.user['phone']);
    passwordCtrl = TextEditingController();
    confirmPasswordCtrl = TextEditingController();
  }

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        newImage = File(picked.path);
      });
    }
  }

  Future<void> updateProfile() async {
    if (firstNameCtrl.text.isEmpty || lastNameCtrl.text.isEmpty || emailCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez remplir tous les champs obligatoires"),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (passwordCtrl.text.isNotEmpty) {
      if (passwordCtrl.text.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Le mot de passe doit contenir au moins 6 caractères"),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      if (passwordCtrl.text != confirmPasswordCtrl.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Les mots de passe ne correspondent pas"),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      var request = http.MultipartRequest(
        "PUT",
        Uri.parse("http://192.168.185.146:5000/auth/profile/${widget.user['id']}"),
      );

      request.fields['firstName'] = firstNameCtrl.text;
      request.fields['lastName'] = lastNameCtrl.text;
      request.fields['email'] = emailCtrl.text;
      request.fields['phone'] = phoneCtrl.text;

      // Ajouter le mot de passe seulement s'il est saisi
      if (passwordCtrl.text.isNotEmpty) {
        request.fields['password'] = passwordCtrl.text;
      }

      if (newImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath("photo", newImage!.path)
        );
      }

      var response = await request.send();
      var body = await response.stream.bytesToString();
      print("UPDATE RESPONSE: $body");

      if (response.statusCode == 200) {
        
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur: $body"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print("Erreur updateProfile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur: $e"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: AppDrawer(
        user: widget.user, // ← correction ici
        onItemSelected: (index) {
  Navigator.pop(context); // fermer le drawer
  switch (index) {
    case 0:
      Navigator.pushNamed(context, "/home");
      break;
    case 1:
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProfilePage(user: widget.user)),
      );
      break;
    case 2:
      Navigator.pushNamed(context, "/settings");
      break;
    case 3:
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MapPage(user: widget.user)),
      );
      break;
    case 4:
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AboutPage(user: widget.user)),
      );
      break;
    case 5:
      // Gestion logout ici
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Déconnexion"),
          content: const Text("Êtes-vous sûr ?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // ferme le dialogue
                Navigator.pop(context); // revient à la page précédente
              },
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              child: const Text("Déconnexion", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
      break;
  }
},

      ),


      appBar: AppBar(
        title: const Text(
          "Modifier le profil",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
       
        actions: [
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Photo de profil
            Stack(
              children: [
                GestureDetector(
                  onTap: pickImage,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: primaryColor,
                        width: 3,
                      ),
                      color: Colors.grey.shade100,
                    ),
                    child: ClipOval(
                      child: newImage != null
                          ? Image.file(newImage!, fit: BoxFit.cover)
                          : (widget.user['photo'] != null
                              ? Image.network(
                                  "http://192.168.180.146:5000/uploads/${widget.user['photo']}",
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.grey.shade400,
                                    );
                                  },
                                )
                              : Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.grey.shade400,
                                )),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: pickImage,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Cliquer pour changer la photo",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 32),

            // Champ nom prenom
            _buildTextField(
              controller: firstNameCtrl,
              label: "Nom",
              hint: "Entrez votre nom",
              icon: Icons.person_outline,
              isRequired: true,
            ),
            const SizedBox(height: 20),
             _buildTextField(
              controller: lastNameCtrl,
              label: "Prénom",
              hint: "Entrez votre prènom",
              icon: Icons.person_outline,
              isRequired: true,
            ),
            const SizedBox(height: 20),

            // Champ Email
            _buildTextField(
              controller: emailCtrl,
              label: "Adresse email",
              hint: "Entrez votre email",
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              isRequired: true,
            ),
            const SizedBox(height: 20),

            // Champ Téléphone
            _buildTextField(
              controller: phoneCtrl,
              label: "Numéro de téléphone",
              hint: "Entrez votre numéro",
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),

            // Section changement de mot de passe
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Changer le mot de passe",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Laissez vide pour conserver le mot de passe actuel",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Champ Nouveau mot de passe
                  _buildPasswordField(
                    controller: passwordCtrl,
                    label: "Nouveau mot de passe",
                    hint: "Entrez le nouveau mot de passe",
                    obscureText: _obscurePassword,
                    onToggleVisibility: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Champ Confirmer le mot de passe
                  _buildPasswordField(
                    controller: confirmPasswordCtrl,
                    label: "Confirmer le mot de passe",
                    hint: "Confirmez le nouveau mot de passe",
                    obscureText: _obscureConfirmPassword,
                    onToggleVisibility: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Bouton Enregistrer
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  disabledBackgroundColor: primaryColor.withOpacity(0.6),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save_outlined, size: 20),
                          SizedBox(width: 8),
                          Text(
                            "Enregistrer les modifications",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Bouton Annuler
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Annuler",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

       // ================== NAVBAR ==================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Profile is active
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, "/home");
          }else if (index == 1) {
      // Aller à Profile
      // Ici, on remplace la page EditProfile par ProfilePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(user: widget.user),
        ),
      );
    }else if (index == 2) {
            Navigator.pushNamed(context, "/settings");
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profil",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Paramètres",
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isRequired = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            if (isRequired)
              Text(
                " *",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            prefixIcon: Icon(icon, color: Colors.grey.shade600, size: 20),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: primaryColor, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            prefixIcon: Icon(Icons.lock_outline, color: Colors.grey.shade600, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: Colors.grey.shade600,
                size: 20,
              ),
              onPressed: onToggleVisibility,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: primaryColor, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}