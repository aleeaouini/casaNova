import 'package:flutter/material.dart';
import 'home.dart';

class ReservationPage extends StatelessWidget {
  final Property property;
  final Color primaryColor;

  const ReservationPage({
    super.key,
    required this.property,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = property.photos.isNotEmpty && property.photos[0].isNotEmpty
        ? property.photos[0]
        : "https://via.placeholder.com/400x200.png?text=No+Image";

    final owner = property.owner;
    final ownerPhotoUrl = owner?.photo != null 
        ? 'http://172.20.10.2:5000/uploads/${owner!.photo}'
        : null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Détails de réservation',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image de la propriété
            Stack(
              children: [
                ClipRRect(
                  child: Image.network(
                    imageUrl,
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 300,
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: Icon(Icons.home, size: 80, color: Colors.grey),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '\$${property.pricePerNight} / nuit',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre et catégorie
                  Text(
                    property.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.category_outlined, size: 18, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Text(
                        property.category,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Adresse
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 20, color: Colors.grey.shade600),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          property.address,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    property.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Caractéristiques
                  const Text(
                    'Caractéristiques',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildFeatureItem(
                        icon: Icons.bed_outlined,
                        text: '${property.bedrooms} Chambre${property.bedrooms > 1 ? 's' : ''}',
                      ),
                      const SizedBox(width: 20),
                      _buildFeatureItem(
                        icon: Icons.bathtub_outlined,
                        text: '${property.bathrooms} Salle${property.bathrooms > 1 ? 's' : ''} de bain',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Équipements
                  if (property.amenities.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Équipements',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: property.amenities.map((amenity) {
                            return Chip(
                              label: Text(amenity),
                              backgroundColor: Colors.grey.shade100,
                              side: BorderSide.none,
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),

                  // Informations de l'annonceur (real owner data)
                  const Text(
                    'Informations de l\'annonceur',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  if (owner != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.orange,
                            backgroundImage: ownerPhotoUrl != null 
                                ? NetworkImage(ownerPhotoUrl)
                                : null,
                            child: ownerPhotoUrl == null
                                ? const Icon(
                                    Icons.person,
                                    size: 30,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  owner.fullName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  owner.email,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (owner.phone != null && owner.phone!.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.phone, size: 14, color: Colors.grey.shade600),
                                      const SizedBox(width: 4),
                                      Text(
                                        owner.phone!,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              // Show contact options
                              showModalBottomSheet(
                                context: context,
                                builder: (context) => Container(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ListTile(
                                        leading: Icon(Icons.email, color: primaryColor),
                                        title: const Text('Envoyer un email'),
                                        subtitle: Text(owner.email),
                                        onTap: () {
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Email: ${owner.email}'),
                                              duration: const Duration(seconds: 3),
                                            ),
                                          );
                                        },
                                      ),
                                      if (owner.phone != null && owner.phone!.isNotEmpty)
                                        ListTile(
                                          leading: Icon(Icons.phone, color: primaryColor),
                                          title: const Text('Appeler'),
                                          subtitle: Text(owner.phone!),
                                          onTap: () {
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Téléphone: ${owner.phone}'),
                                                duration: const Duration(seconds: 3),
                                              ),
                                            );
                                          },
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            icon: Icon(Icons.message_outlined, color: primaryColor),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.grey,
                            child: Icon(
                              Icons.person,
                              size: 30,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Informations du propriétaire non disponibles',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  const SizedBox(height: 30),

                  // Bouton de réservation
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Logique de réservation
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirmer la réservation'),
                            content: Text(
                              'Voulez-vous confirmer la réservation de "${property.title}" ?'
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Annuler'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Réservation confirmée !'),
                                      backgroundColor: Colors.green,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                ),
                                child: const Text('Confirmer', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Réserver maintenant',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
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

  Widget _buildFeatureItem({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}