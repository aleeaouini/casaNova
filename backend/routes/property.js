const express = require("express");
const router = express.Router();
const Property = require("../models/Property");

// CREATE PROPERTY
router.post("/", async (req, res) => {
  try {
    const {
      title,
      description,
      address,
      pricePerNight,
      bedrooms,
      bathrooms,
      amenities,
      photos,
      category
    } = req.body;

    // Validation simple côté serveur
    if (!title || !description || !address || !pricePerNight) {
      return res.status(400).json({ error: "Title, description, address and price are required" });
    }

    const property = new Property({
      title,
      description,
      address,
      pricePerNight,
      bedrooms: bedrooms || 1,
      bathrooms: bathrooms || 1,
      amenities: amenities || [],
      photos: photos || [],
      category: category || "Autre",
    });

    await property.save();

    res.status(201).json({
      message: "Property created successfully",
      property
    });

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET ALL PROPERTIES
router.get("/", async (req, res) => {
  try {
    const properties = await Property.find().sort({ createdAt: -1 });
    res.status(200).json(properties);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});


router.get("/category/:category", async (req, res) => {
  try {
    const { category } = req.params;
    const properties = await Property.find({ category });
    res.status(200).json(properties);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
