const express = require("express");
const mongoose = require("mongoose");
const router = express.Router();

// IMPORT des modèles avec le bon chemin
const Property = require("../models/property");
const Favorite = require("../models/favorite");

// Helper function to add full URLs to photos
const addFullPhotoUrls = (property, req) => {
  const propertyObj = property.toObject ? property.toObject() : property;
  
  if (propertyObj.photos && Array.isArray(propertyObj.photos)) {
    propertyObj.photos = propertyObj.photos.map(photo => {
      if (photo && !photo.startsWith('http')) {
        // For locally stored images, construct full URL
        const baseUrl = `${req.protocol}://${req.get('host')}`;
        // Check if photo already has 'uploads/' prefix
        if (photo.startsWith('uploads/')) {
          return `${baseUrl}/${photo}`;
        } else {
          return `${baseUrl}/uploads/${photo}`;
        }
      }
      return photo;
    });
  }
  
  // Also fix owner photo URL if it exists
  if (propertyObj.owner && propertyObj.owner.photo && 
      !propertyObj.owner.photo.startsWith('http')) {
    const baseUrl = `${req.protocol}://${req.get('host')}`;
    propertyObj.owner.photo = `${baseUrl}/uploads/${propertyObj.owner.photo}`;
  }
  
  return propertyObj;
};

// GET ALL FAVORITES FOR A USER
router.get("/:userId", async (req, res) => {
  try {
    const { userId } = req.params;

    // Vérifier que l'ID est valide
    if (!mongoose.Types.ObjectId.isValid(userId)) {
      return res.status(400).json({ error: "Invalid user ID" });
    }

    // Récupérer tous les favoris de l'utilisateur
    const favorites = await Favorite.find({ userId }).sort({ addedAt: -1 });

    // Extraire seulement les propriétés
    const propertyIds = favorites.map(fav => fav.propertyId);
    
    // Récupérer les propriétés complètes
    const properties = await Property.find({ _id: { $in: propertyIds } })
      .populate('owner', 'firstName lastName email phone photo');

    // Transform properties to include full image URLs
    const propertiesWithFullUrls = properties.map(property => 
      addFullPhotoUrls(property, req)
    );

    res.status(200).json(propertiesWithFullUrls);
  } catch (error) {
    console.error("Error fetching favorites:", error);
    res.status(500).json({ error: error.message });
  }
});

// ADD TO FAVORITES
router.post("/", async (req, res) => {
  try {
    const { userId, propertyId } = req.body;

    // Validation
    if (!userId || !propertyId) {
      return res.status(400).json({ 
        error: "User ID and Property ID are required" 
      });
    }

    // Vérifier si les IDs sont valides
    if (!mongoose.Types.ObjectId.isValid(userId) || 
        !mongoose.Types.ObjectId.isValid(propertyId)) {
      return res.status(400).json({ error: "Invalid ID format" });
    }

    // Vérifier si la propriété existe
    const property = await Property.findById(propertyId);
    if (!property) {
      return res.status(404).json({ error: "Property not found" });
    }

    // Vérifier si déjà en favoris
    const existingFavorite = await Favorite.findOne({ userId, propertyId });
    if (existingFavorite) {
      return res.status(200).json({
        message: "Already in favorites",
        favorite: existingFavorite
      });
    }

    // Créer le favori
    const favorite = new Favorite({
      userId,
      propertyId
    });

    await favorite.save();

    res.status(201).json({
      message: "Added to favorites successfully",
      favorite
    });

  } catch (error) {
    console.error("Error adding to favorites:", error);
    
    // Gérer les erreurs de duplication
    if (error.code === 11000) {
      return res.status(400).json({ 
        error: "This property is already in favorites" 
      });
    }
    
    res.status(500).json({ error: error.message });
  }
});

// REMOVE FROM FAVORITES
router.delete("/:userId/:propertyId", async (req, res) => {
  try {
    const { userId, propertyId } = req.params;

    // Vérifier que les IDs sont valides
    if (!mongoose.Types.ObjectId.isValid(userId) || 
        !mongoose.Types.ObjectId.isValid(propertyId)) {
      return res.status(400).json({ error: "Invalid ID format" });
    }

    // Supprimer le favori
    const deletedFavorite = await Favorite.findOneAndDelete({ 
      userId, 
      propertyId 
    });

    if (!deletedFavorite) {
      return res.status(404).json({ 
        error: "Favorite not found" 
      });
    }

    res.status(200).json({
      message: "Removed from favorites successfully",
      deletedFavorite
    });

  } catch (error) {
    console.error("Error removing from favorites:", error);
    res.status(500).json({ error: error.message });
  }
});

// CHECK IF PROPERTY IS IN FAVORITES
router.get("/:userId/check/:propertyId", async (req, res) => {
  try {
    const { userId, propertyId } = req.params;

    const favorite = await Favorite.findOne({ userId, propertyId });

    res.status(200).json({
      isFavorite: !!favorite,
      favorite: favorite || null
    });

  } catch (error) {
    console.error("Error checking favorite:", error);
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;