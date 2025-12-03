import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class AddPropertyPage extends StatefulWidget {
  const AddPropertyPage({super.key});

  @override
  State<AddPropertyPage> createState() => _AddPropertyPageState();
}

class _AddPropertyPageState extends State<AddPropertyPage> {
  final Color primaryColor = Colors.orange;
  int currentStep = 1;
  final int totalSteps = 5;

  static const String baseUrl = "http://192.168.185.146:5000";
  static const String propertiesApi = "$baseUrl/properties";
  static const String uploadApi = "$baseUrl/upload";

  // Controllers
  final TextEditingController titleCtrl = TextEditingController();
  final TextEditingController descriptionCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();
  final TextEditingController priceCtrl = TextEditingController();

  // Counters
  int bedrooms = 1;
  int bathrooms = 1;

  // Category
  String selectedCategory = 'Autre';
  final List<String> categories = ['Appartement', 'Maison', 'Villa', 'Autre'];

  // Amenities
  final List<Amenity> amenities = [
    Amenity(icon: Icons.wifi, label: 'Wi-Fi', isSelected: false),
    Amenity(icon: Icons.pool, label: 'Pool', isSelected: false),
    Amenity(icon: Icons.kitchen, label: 'Kitchen', isSelected: false),
    Amenity(icon: Icons.local_parking, label: 'Free Parking', isSelected: false),
    Amenity(icon: Icons.ac_unit, label: 'Air Conditioning', isSelected: false),
  ];

  // Photos
  List<File> selectedPhotos = [];
  bool _isLoading = false;

  // Pick images
  Future<void> pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? images = await picker.pickMultiImage();

    if (images != null && images.isNotEmpty) {
      setState(() {
        selectedPhotos.addAll(images.map((image) => File(image.path)));
      });
    }
  }

  void removeImage(int index) {
    setState(() {
      selectedPhotos.removeAt(index);
    });
  }

  Future<List<String>> uploadImages() async {
    List<String> uploadedUrls = [];

    for (var img in selectedPhotos) {
      try {
        var req = http.MultipartRequest(
          "POST",
          Uri.parse(uploadApi), // Fixed: Using the defined uploadApi constant
        );

        req.files.add(await http.MultipartFile.fromPath("image", img.path));

        var res = await req.send();
        var body = await res.stream.bytesToString();
        final decoded = jsonDecode(body);

        if (decoded["url"] != null) {
          uploadedUrls.add(decoded["url"]);
        } else {
          print("Upload response missing URL: $decoded");
        }
      } catch (e) {
        print("Error uploading image: $e");
      }
    }

    return uploadedUrls;
  }

  Future<void> submitListing() async {
    if (titleCtrl.text.isEmpty ||
        descriptionCtrl.text.isEmpty ||
        addressCtrl.text.isEmpty ||
        priceCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Veuillez remplir tous les champs'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Upload photos
      List<String> photoUrls = await uploadImages();

      final Map<String, dynamic> data = {
        "title": titleCtrl.text,
        "description": descriptionCtrl.text,
        "address": addressCtrl.text,
        "pricePerNight": int.parse(priceCtrl.text),
        "bedrooms": bedrooms,
        "bathrooms": bathrooms,
        "amenities": amenities
            .where((a) => a.isSelected)
            .map((a) => a.label)
            .toList(),
        "photos": photoUrls,
        "category": selectedCategory,
      };

      print("Sending data to: $propertiesApi"); // Debug
      print("Data: $data");

      final response = await http.post(
        Uri.parse(propertiesApi), // Fixed: Using the defined propertiesApi constant
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      setState(() => _isLoading = false);

      if (response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Propriété ajoutée avec succès!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur: ${response.statusCode} - ${response.body}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print("Submit error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur réseau: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ================= UI ====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add Your Property',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          // Step Indicator
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Step $currentStep of $totalSteps',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: currentStep / totalSteps,
                  valueColor: AlwaysStoppedAnimation(primaryColor),
                  backgroundColor: Colors.grey.shade200,
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Property Details
                  _buildSectionTitle('Property Details'),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: titleCtrl,
                    label: 'Listing Title',
                    hint: 'e.g., Cozy Beachfront Cottage',
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: descriptionCtrl,
                    label: 'Description',
                    hint: 'Tell guests about your place...',
                    maxLines: 4,
                  ),
                  const SizedBox(height: 32),

                  // Location
                  _buildSectionTitle('Location'),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: addressCtrl,
                    label: 'Address',
                    hint: 'Enter the property address',
                  ),
                  const SizedBox(height: 32),

                  // Pricing
                  _buildSectionTitle('Pricing & Specs'),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: priceCtrl,
                    label: 'Price per night',
                    hint: '150',
                    keyboardType: TextInputType.number,
                    prefixText: "\$ ",
                  ),
                  const SizedBox(height: 20),

                  // Bedrooms / Bathrooms
                  Row(
                    children: [
                      Expanded(
                        child: _buildCounter(
                          label: 'Bedrooms',
                          value: bedrooms,
                          onIncrement: () => setState(() => bedrooms++),
                          onDecrement: () =>
                              setState(() => bedrooms > 1 ? bedrooms-- : 1),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildCounter(
                          label: 'Bathrooms',
                          value: bathrooms,
                          onIncrement: () => setState(() => bathrooms++),
                          onDecrement: () =>
                              setState(() => bathrooms > 1 ? bathrooms-- : 1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Category
                  _buildSectionTitle('Category'),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    items: categories
                        .map((cat) => DropdownMenuItem(
                              value: cat,
                              child: Text(cat),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => selectedCategory = val);
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Amenities
                  _buildSectionTitle('Amenities'),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children:
                        amenities.map((a) => _buildAmenityChip(a)).toList(),
                  ),
                  const SizedBox(height: 32),

                  // Photos
                  _buildSectionTitle('Photos'),
                  const SizedBox(height: 16),
                  _buildPhotosSection(),
                  const SizedBox(height: 32),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : submitListing,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              "Submit Listing",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widgets ---------------------
  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87));
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? prefixText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            prefixText: prefixText,
            filled: true,
            fillColor: Colors.grey.shade50,
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCounter({
    required String label,
    required int value,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300)),
          child: Row(
            children: [
              IconButton(icon: const Icon(Icons.remove), onPressed: onDecrement),
              Expanded(
                child: Center(
                  child: Text("$value",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              IconButton(icon: const Icon(Icons.add), onPressed: onIncrement),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAmenityChip(Amenity a) {
    return GestureDetector(
      onTap: () => setState(() => a.isSelected = !a.isSelected),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: a.isSelected ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: a.isSelected ? primaryColor : Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(a.icon,
                size: 18,
                color: a.isSelected ? Colors.white : Colors.grey.shade700),
            const SizedBox(width: 8),
            Text(a.label,
                style: TextStyle(
                    color: a.isSelected ? Colors.white : Colors.black87)),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotosSection() {
    return Column(
      children: [
        if (selectedPhotos.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12),
            itemCount: selectedPhotos.length,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      selectedPhotos[index],
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => removeImage(index),
                      child: Container(
                        decoration: const BoxDecoration(
                            color: Colors.red, shape: BoxShape.circle),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(Icons.close,
                            color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: pickImages,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 32),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                Icon(Icons.add_photo_alternate_outlined,
                    size: 48, color: Colors.grey.shade400),
                const SizedBox(height: 8),
                Text("Add more",
                    style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    descriptionCtrl.dispose();
    addressCtrl.dispose();
    priceCtrl.dispose();
    super.dispose();
  }
}

class Amenity {
  final IconData icon;
  final String label;
  bool isSelected;

  Amenity({
    required this.icon,
    required this.label,
    required this.isSelected,
  });
}