const express = require("express");
const multer = require("multer");
const User = require("../models/user");
const bcrypt = require("bcrypt");
const router = express.Router();

// upload photo
const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, "uploads/"),
  filename: (req, file, cb) =>
    cb(null, Date.now() + "-" + file.originalname),
});
const upload = multer({ storage });

// Helper function to add full photo URL
const addFullUserPhotoUrl = (user, req) => {
  const userObj = user.toObject ? user.toObject() : user;
  
  if (userObj.photo && !userObj.photo.startsWith('http')) {
    const baseUrl = `${req.protocol}://${req.get('host')}`;
    userObj.photo = `${baseUrl}/uploads/${userObj.photo}`;
  }
  
  return userObj;
};

//signup
router.post("/signup", upload.single("photo"), async (req, res) => {
  try {
    const { firstName, lastName, email, password, phone } = req.body;
    const hashedPassword = await bcrypt.hash(password, 10);
    const newUser = await User.create({
      firstName, 
      lastName,
      email,
      phone,
      password: hashedPassword,
      photo: req.file ? req.file.filename : null,
    });

    // Transform user to include full photo URL
    const userWithFullUrl = addFullUserPhotoUrl(newUser, req);

    res.json({ 
      success: true, 
      user: {
        id: userWithFullUrl._id,
        firstName: userWithFullUrl.firstName,
        lastName: userWithFullUrl.lastName,
        email: userWithFullUrl.email,
        phone: userWithFullUrl.phone,
        photo: userWithFullUrl.photo,
      },
    });
  } catch (err) {
    console.log(err);
    res.json({ success: false, error: err.message });
  }
});

//login
router.post("/login", async (req, res) => {
  const { email, password } = req.body;

  try {
    const user = await User.findOne({ email });

    if (!user)
      return res
        .status(404)
        .json({ success: false, message: "User not found" });

    const isMatch = await bcrypt.compare(password, user.password);

    if (!isMatch)
      return res.status(401).json({
        success: false,
        message: "incorrect password",
      });

    // Transform user to include full photo URL
    const userWithFullUrl = addFullUserPhotoUrl(user, req);

    res.json({
      success: true,
      user: {
        id: userWithFullUrl._id,
        firstName: userWithFullUrl.firstName, 
        lastName: userWithFullUrl.lastName,
        email: userWithFullUrl.email,
        phone: userWithFullUrl.phone,
        photo: userWithFullUrl.photo,
      },
    });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

//profile
router.get("/profile/:id", async (req, res) => {
  try {
    const user = await User.findById(req.params.id);

    if (!user)
      return res
        .status(404)
        .json({ success: false, message: "user not found" });

    // Transform user to include full photo URL
    const userWithFullUrl = addFullUserPhotoUrl(user, req);

    res.json({
      success: true,
      user: {
        id: userWithFullUrl._id,
        firstName: userWithFullUrl.firstName, 
        lastName: userWithFullUrl.lastName,
        email: userWithFullUrl.email,
        phone: userWithFullUrl.phone,
        photo: userWithFullUrl.photo,
      },
    });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

//update profile
router.put("/profile/:id", upload.single("photo"), async (req, res) => {
  try {
    const { firstName,lastName, email, phone, password } = req.body;

    let updateData = {
      firstName,
      lastName,
      email,
      phone,
    };

    if (password) {
      updateData.password = await bcrypt.hash(password, 10);
    }

    if (req.file) {
      updateData.photo = req.file.filename;
    }

    const updatedUser = await User.findByIdAndUpdate(
      req.params.id,
      updateData,
      { new: true }
    );

    if (!updatedUser)
      return res
        .status(404)
        .json({ success: false, message: "user not found" });

    // Transform user to include full photo URL
    const userWithFullUrl = addFullUserPhotoUrl(updatedUser, req);

    res.json({
      success: true,
      user: {
        id: userWithFullUrl._id,
        firstName: userWithFullUrl.firstName,
        lastName: userWithFullUrl.lastName,
        email: userWithFullUrl.email,
        phone: userWithFullUrl.phone,
        photo: userWithFullUrl.photo,
      },
    });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

module.exports = router;