import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import 'profile.dart';

class AboutPage extends StatelessWidget {
  final Map<String, dynamic> user; // ← Le user connecté

  const AboutPage({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange, Colors.deepOrange],
            ),
          ),
        ),
        elevation: 0,
      ),
      drawer: AppDrawer(
        onItemSelected: (index) {
          Navigator.pop(context); // fermer le drawer

          // Navigation selon l'index
          if (index == 0) Navigator.pushNamed(context, "/home");
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfilePage(user: user), // ← passe le user ici
              ),
            );
          }
          if (index == 2) Navigator.pushNamed(context, "/settings");
          if (index == 3) Navigator.pop(context); // reste sur About
          if (index == 4) Navigator.pop(context); // Logout, à gérer selon ton app
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section with Logo
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.orange, Colors.orange.shade50],
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.home_work,
                      size: 80,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Estately',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),

            // About Content
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('About Us'),
                  const SizedBox(height: 10),
                  _buildInfoCard(
                    'Estately is your trusted companion for finding and managing properties. Whether you\'re buying, selling, or renting, we make real estate simple and accessible.',
                  ),
                  const SizedBox(height: 25),
                  _buildSectionTitle('Features'),
                  const SizedBox(height: 10),
                  _buildFeatureItem(
                    Icons.search_rounded,
                    'Smart Search',
                    'Find properties that match your needs',
                  ),
                  _buildFeatureItem(
                    Icons.favorite_rounded,
                    'Save Favorites',
                    'Keep track of properties you love',
                  ),
                  _buildFeatureItem(
                    Icons.notifications_rounded,
                    'Real-time Updates',
                    'Get notified about new listings',
                  ),
                  _buildFeatureItem(
                    Icons.verified_rounded,
                    'Verified Listings',
                    'All properties are verified and authentic',
                  ),
                  const SizedBox(height: 25),
                  _buildSectionTitle('Contact Us'),
                  const SizedBox(height: 10),
                  _buildContactCard(Icons.email_rounded, 'Email', 'support@estately.com'),
                  const SizedBox(height: 10),
                  _buildContactCard(Icons.phone_rounded, 'Phone', '+(216) 22085249 '),
                  const SizedBox(height: 10),
                  _buildContactCard(Icons.language_rounded, 'Website', 'www.estately.com'),
                  const SizedBox(height: 30),

                  // Footer
                  Center(
                    child: Column(
                      children: [
                        Text(
                          '© 2024 Estately. All rights reserved.',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: () {},
                              child: const Text('Privacy Policy'),
                            ),
                            const Text('•', style: TextStyle(color: Colors.grey)),
                            TextButton(
                              onPressed: () {},
                              child: const Text('Terms of Service'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade800,
      ),
    );
  }

  Widget _buildInfoCard(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15,
          color: Colors.grey.shade700,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.orange, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.orange, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
