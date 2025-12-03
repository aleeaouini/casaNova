import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'createCart.dart';
import 'listpage.dart';
import 'profile.dart';
import 'favorites.dart'; // Add this import
import 'map_page.dart';
import 'package:imobilier/widgets/PropertyMapPage.dart';

// =================== MODEL ===================
class Property {
  final String id;
  final String title;
  final String description;
  final String address;
  final int pricePerNight;
  final int bedrooms;
  final int bathrooms;
  final List<String> amenities;
  final List<String> photos;
  final String category;

  Property({
    required this.id,
    required this.title,
    required this.description,
    required this.address,
    required this.pricePerNight,
    required this.bedrooms,
    required this.bathrooms,
    required this.amenities,
    required this.photos,
    required this.category,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      address: json['address'],
      pricePerNight: json['pricePerNight'],
      bedrooms: json['bedrooms'] ?? 1,
      bathrooms: json['bathrooms'] ?? 1,
      amenities: List<String>.from(json['amenities'] ?? []),
      photos: List<String>.from(json['photos'] ?? []),
      category: json['category'] ?? 'Autre',
    );
  }

  // Override equals and hashCode for proper comparison
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Property && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const String apiUrl = "http://192.168.185.146:5000/properties";

Future<List<Property>> fetchProperties({String? category}) async {
  final uri = category != null && category != 'Tous'
      ? Uri.parse("$apiUrl/category/$category")
      : Uri.parse(apiUrl);

  final response = await http.get(uri);
  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);
    return data.map((json) => Property.fromJson(json)).toList();
  } else {
    throw Exception("Failed to fetch properties");
  }
}

// =================== HOME SCREEN ===================
class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategory = 0;
  int _selectedNavIndex = 0;
  final Color primaryColor = Colors.orange;
  final List<String> categories = ['Tous', 'Appartement', 'Maison', 'Villa'];

  late Future<List<Property>> futureProperties;
  List<Property> favoriteProperties = []; // Track favorite properties

  @override
  void initState() {
    super.initState();
    futureProperties = fetchProperties();
  }

  void selectCategory(int index) {
    setState(() {
      _selectedCategory = index;
      futureProperties = fetchProperties(
        category: categories[index],
      );
    });
  }

  void toggleFavorite(Property property) {
    setState(() {
      if (favoriteProperties.contains(property)) {
        favoriteProperties.remove(property);
      } else {
        favoriteProperties.add(property);
      }
    });
  }

  void removeFavorite(Property property) {
    setState(() {
      favoriteProperties.remove(property);
    });
  }

  bool isFavorite(Property property) {
    return favoriteProperties.contains(property);
  }

  Widget _buildNavItem(IconData icon, IconData activeIcon, String label, int index) {
    final isSelected = _selectedNavIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedNavIndex = index);
          
          if (label == 'Profil') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfilePage(user: widget.user),
              ),
            );
          } else if (label == 'Favoris') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FavoritesPage(
                  favoriteProperties: favoriteProperties,
                  primaryColor: primaryColor,
                  onRemoveFavorite: removeFavorite,
                ),
              ),
            );
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isSelected ? activeIcon : icon,
                color: isSelected ? primaryColor : Colors.grey.shade600, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                  fontSize: 11,
                  color: isSelected ? primaryColor : Colors.grey.shade600,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black87),
          onPressed: () {},
        ),
        title: const Text(
          'Trouvez votre prochain séjour',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfilePage(user: widget.user),
                  ),
                );
              },
              child: CircleAvatar(
                backgroundColor: Colors.orange.shade200,
                radius: 20,
                backgroundImage: widget.user['photo'] != null
                    ? NetworkImage('http://192.168.1.221:5000/uploads/${widget.user['photo']}')
                    : null,
                child: widget.user['photo'] == null
                    ? const Icon(Icons.person, color: Colors.white, size: 24)
                    : null,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300)),
              child: TextField(
                style: const TextStyle(fontSize: 14, color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Rechercher une destination, ville...',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade600, size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                ),
              ),
            ),
          ),

          SizedBox(
            height: 45,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedCategory == index;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () => selectCategory(index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                          color: isSelected ? primaryColor : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isSelected ? primaryColor : Colors.grey.shade300)),
                      child: Center(
                        child: Text(
                          categories[index],
                          style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w600,
                              fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Propriétés en vedette',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                InkWell(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AllPropertiesPage()));
                  },
                  child: Text('Voir tout',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: primaryColor)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: FutureBuilder<List<Property>>(
              future: futureProperties,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Aucune propriété trouvée'));
                } else {
                  final properties = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: properties.length,
                    itemBuilder: (context, index) {
                      return PropertyCard(
                        property: properties[index],
                        primaryColor: primaryColor,
                        isFavorite: isFavorite(properties[index]),
                        onFavoriteToggle: () => toggleFavorite(properties[index]),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddPropertyPage()),
          );
        },
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        child: Container(
          height: 65,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(Icons.home_outlined, Icons.home, 'Accueil', 0),
              _buildNavItem(Icons.favorite_border, Icons.favorite, 'Favoris', 1),
              const SizedBox(width: 48),
              _buildNavItem(Icons.message_outlined, Icons.message, 'Messages', 2),
              _buildNavItem(Icons.person_outline, Icons.person, 'Profil', 3),
            ],
          ),
        ),
      ),
    );
  }
}

// =================== PROPERTY CARD ===================
class PropertyCard extends StatelessWidget {
  final Property property;
  final Color primaryColor;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  const PropertyCard({
    super.key,
    required this.property,
    required this.primaryColor,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = property.photos.isNotEmpty
        ? property.photos[0]
        : "https://via.placeholder.com/400x200.png?text=No+Image";

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Icon(Icons.home, size: 50, color: Colors.grey),
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 200,
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: onFavoriteToggle,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? primaryColor : Colors.grey.shade700,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  property.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        property.address,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${property.pricePerNight} / nuit',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryColor,
                        side: BorderSide(color: primaryColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: const Text(
                        'Réserver',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // --- MAP BUTTON ---
 ElevatedButton.icon(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PropertyMapPage(
          address: property.address, // Pass only the address
        ),
      ),
    );
  },
  icon: const Icon(Icons.map_outlined, size: 20),
  label: const Text("Map"),
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.blueGrey.shade800,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),
),





                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}