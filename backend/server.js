const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
require("dotenv").config();

const app = express();
app.use(cors());
app.use(express.json());
app.use('/uploads', express.static('uploads')); 
// server.js - Update CORS
app.use(cors({
  origin: '*', // For development only
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type']
}));
// Import routes
const authRoute = require("./routes/auth");
app.use("/auth", authRoute);
const propertyRoute = require("./routes/property");
app.use("/properties", propertyRoute);

// Connect to MongoDB
mongoose.connect(process.env.MONGO_URI,
  {
  serverSelectionTimeoutMS: 5000,
  socketTimeoutMS: 45000, 
  maxPoolSize: 10, 
})

  .then(() => console.log("MongoDB connected"))
  .catch(err => console.log(err));

const PORT = process.env.PORT || 5000;
app.listen(PORT, '0.0.0.0', () => console.log(`Server running on port ${PORT}`));
