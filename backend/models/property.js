// Example of what should be in models/property.js
const mongoose = require('mongoose');

const propertySchema = new mongoose.Schema({
  title: { type: String, required: true },
  description: String,
  address: String,
  pricePerNight: Number,
  bedrooms: Number,
  bathrooms: Number,
  amenities: [String],
  photos: [String],
  category: String,
  owner: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  createdAt: { type: Date, default: Date.now }
});

// Make sure you're exporting as a model
module.exports = mongoose.model('Property', propertySchema);