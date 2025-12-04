const express = require('express');
const router = express.Router();
const Property = require('../models/property');

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

// Get all properties with owner info
router.get('/', async (req, res) => {
  try {
    const properties = await Property.find()
      .populate('owner', 'firstName lastName email phone photo')
      .sort({ createdAt: -1 });
    
    // Transform properties to include full image URLs
    const propertiesWithFullUrls = properties.map(property => 
      addFullPhotoUrls(property, req)
    );
    
    res.status(200).json(propertiesWithFullUrls);
  } catch (error) {
    console.error('Error fetching properties:', error);
    res.status(500).json({ 
      success: false,
      message: 'Error fetching properties', 
      error: error.message 
    });
  }
});

// Get properties by category with owner info
router.get('/category/:category', async (req, res) => {
  try {
    const { category } = req.params;
    
    const properties = await Property.find({ category })
      .populate('owner', 'firstName lastName email phone photo')
      .sort({ createdAt: -1 });
    
    // Transform properties to include full image URLs
    const propertiesWithFullUrls = properties.map(property => 
      addFullPhotoUrls(property, req)
    );
    
    res.status(200).json(propertiesWithFullUrls);
  } catch (error) {
    console.error('Error fetching properties by category:', error);
    res.status(500).json({ 
      success: false,
      message: 'Error fetching properties by category', 
      error: error.message 
    });
  }
});

// Get single property by ID with owner info
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    
    // Validate MongoDB ObjectId
    if (!id.match(/^[0-9a-fA-F]{24}$/)) {
      return res.status(400).json({ 
        success: false,
        message: 'Invalid property ID format' 
      });
    }
    
    const property = await Property.findById(id)
      .populate('owner', 'firstName lastName email phone photo');
    
    if (!property) {
      return res.status(404).json({ 
        success: false,
        message: 'Property not found' 
      });
    }
    
    // Transform property to include full image URLs
    const propertyWithFullUrls = addFullPhotoUrls(property, req);
    
    res.status(200).json(propertyWithFullUrls);
  } catch (error) {
    console.error('Error fetching property:', error);
    res.status(500).json({ 
      success: false,
      message: 'Error fetching property', 
      error: error.message 
    });
  }
});

// Create new property
router.post('/', async (req, res) => {
  try {
    const { userId, owner, ...propertyData } = req.body;
    
    // Get owner ID from either userId or owner field
    const ownerId = userId || owner;
    
    if (!ownerId) {
      return res.status(400).json({ 
        success: false,
        message: 'Owner ID (userId or owner) is required' 
      });
    }
    
    // Create property with owner
    const newProperty = new Property({
      ...propertyData,
      owner: ownerId
    });
    
    const savedProperty = await newProperty.save();
    
    // Populate owner info before sending response
    const populatedProperty = await Property.findById(savedProperty._id)
      .populate('owner', 'firstName lastName email phone photo');
    
    // Transform property to include full image URLs
    const propertyWithFullUrls = addFullPhotoUrls(populatedProperty, req);
    
    res.status(201).json({
      success: true,
      message: 'Property created successfully',
      property: propertyWithFullUrls
    });
  } catch (error) {
    console.error('Error creating property:', error);
    
    // Handle validation errors
    if (error.name === 'ValidationError') {
      const errors = Object.values(error.errors).map(err => err.message);
      return res.status(400).json({ 
        success: false,
        message: 'Validation error', 
        errors 
      });
    }
    
    res.status(500).json({ 
      success: false,
      message: 'Error creating property', 
      error: error.message 
    });
  }
});

// Update property
router.put('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    
    // Validate MongoDB ObjectId
    if (!id.match(/^[0-9a-fA-F]{24}$/)) {
      return res.status(400).json({ 
        success: false,
        message: 'Invalid property ID format' 
      });
    }
    
    // Don't allow updating the owner field directly
    const { owner, ...updateData } = req.body;
    
    const updatedProperty = await Property.findByIdAndUpdate(
      id,
      updateData,
      { new: true, runValidators: true }
    ).populate('owner', 'firstName lastName email phone photo');
    
    if (!updatedProperty) {
      return res.status(404).json({ 
        success: false,
        message: 'Property not found' 
      });
    }
    
    // Transform property to include full image URLs
    const propertyWithFullUrls = addFullPhotoUrls(updatedProperty, req);
    
    res.status(200).json({
      success: true,
      message: 'Property updated successfully',
      property: propertyWithFullUrls
    });
  } catch (error) {
    console.error('Error updating property:', error);
    
    if (error.name === 'ValidationError') {
      const errors = Object.values(error.errors).map(err => err.message);
      return res.status(400).json({ 
        success: false,
        message: 'Validation error', 
        errors 
      });
    }
    
    res.status(500).json({ 
      success: false,
      message: 'Error updating property', 
      error: error.message 
    });
  }
});

// Delete property
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    
    // Validate MongoDB ObjectId
    if (!id.match(/^[0-9a-fA-F]{24}$/)) {
      return res.status(400).json({ 
        success: false,
        message: 'Invalid property ID format' 
      });
    }
    
    const deletedProperty = await Property.findByIdAndDelete(id);
    
    if (!deletedProperty) {
      return res.status(404).json({ 
        success: false,
        message: 'Property not found' 
      });
    }
    
    res.status(200).json({
      success: true,
      message: 'Property deleted successfully',
      property: deletedProperty
    });
  } catch (error) {
    console.error('Error deleting property:', error);
    res.status(500).json({ 
      success: false,
      message: 'Error deleting property', 
      error: error.message 
    });
  }
});

// Search properties
router.get('/search/query', async (req, res) => {
  try {
    const { q, minPrice, maxPrice, bedrooms, bathrooms, category } = req.query;
    
    let query = {};
    
    // Text search
    if (q) {
      query.$or = [
        { title: { $regex: q, $options: 'i' } },
        { description: { $regex: q, $options: 'i' } },
        { address: { $regex: q, $options: 'i' } }
      ];
    }
    
    // Price range
    if (minPrice || maxPrice) {
      query.pricePerNight = {};
      if (minPrice) query.pricePerNight.$gte = parseInt(minPrice);
      if (maxPrice) query.pricePerNight.$lte = parseInt(maxPrice);
    }
    
    // Bedrooms
    if (bedrooms) {
      query.bedrooms = { $gte: parseInt(bedrooms) };
    }
    
    // Bathrooms
    if (bathrooms) {
      query.bathrooms = { $gte: parseInt(bathrooms) };
    }
    
    // Category
    if (category && category !== 'Tous') {
      query.category = category;
    }
    
    const properties = await Property.find(query)
      .populate('owner', 'firstName lastName email phone photo')
      .sort({ createdAt: -1 });
    
    // Transform properties to include full image URLs
    const propertiesWithFullUrls = properties.map(property => 
      addFullPhotoUrls(property, req)
    );
    
    res.status(200).json({
      success: true,
      count: propertiesWithFullUrls.length,
      properties: propertiesWithFullUrls
    });
  } catch (error) {
    console.error('Error searching properties:', error);
    res.status(500).json({ 
      success: false,
      message: 'Error searching properties', 
      error: error.message 
    });
  }
});

// Get properties by owner
router.get('/owner/:ownerId', async (req, res) => {
  try {
    const { ownerId } = req.params;
    
    const properties = await Property.find({ owner: ownerId })
      .populate('owner', 'firstName lastName email phone photo')
      .sort({ createdAt: -1 });
    
    // Transform properties to include full image URLs
    const propertiesWithFullUrls = properties.map(property => 
      addFullPhotoUrls(property, req)
    );
    
    res.status(200).json({
      success: true,
      count: propertiesWithFullUrls.length,
      properties: propertiesWithFullUrls
    });
  } catch (error) {
    console.error('Error fetching properties by owner:', error);
    res.status(500).json({ 
      success: false,
      message: 'Error fetching properties by owner', 
      error: error.message 
    });
  }
});

module.exports = router;