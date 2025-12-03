const mongoose = require('mongoose');

const PropertySchema = new mongoose.Schema(
  {
    title: {
      type: String,
      required: [true, 'Title is required'],
      trim: true,
      minlength: [3, 'Title must be at least 3 characters'],
    },

    description: {
      type: String,
      required: [true, 'Description is required'],
      trim: true,
      minlength: [10, 'Description must be at least 10 characters'],
    },

    address: {
      type: String,
      required: [true, 'Address is required'],
      trim: true,
    },

    pricePerNight: {
      type: Number,
      required: [true, 'Price per night is required'],
      min: [0, 'Price cannot be negative'],
    },

    bedrooms: {
      type: Number,
      default: 1,
      min: [1, 'Bedrooms must be at least 1'],
    },

    bathrooms: {
      type: Number,
      default: 1,
      min: [1, 'Bathrooms must be at least 1'],
    },

    amenities: [
      {
        type: String,
        enum: ["Wi-Fi", "Pool", "Kitchen", "Free Parking", "Air Conditioning"],
      },
    ],

    photos: [
      {
        type: String,
        validate: {
          validator: function (v) {
            return v.match(/^https?:\/\/.+/); // Vérifie que c'est une URL valide
          },
          message: props => `${props.value} is not a valid URL!`,
        },
      },
    ],

    category: {
      type: String,
      enum: ['Appartement', 'Maison', 'Villa', 'Autre'],
      default: 'Autre',
    },

    createdAt: {
      type: Date,
      default: Date.now,
    },
  },
  {
    timestamps: true, 
  }
);

module.exports = mongoose.model("Property", PropertySchema);
