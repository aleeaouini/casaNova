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

    res.json({ success: true, 
      user:{
        id: newUser._id,
        firstName: newUser.firstName,
        lastName: newUser.lastName,
        email: newUser.email,
        phone: newUser.phone,
        photo: newUser.photo,
      } ,
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

    res.json({
      success: true,
      user: {
        id: user._id,
        firstName: user.firstName, 
        lastName: user.lastName,
        email: user.email,
        phone: user.phone,
        photo: user.photo,
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

    res.json({
      success: true,
      user: {
        id: user._id,
        firstName: user.firstName, 
        lastName: user.lastName,
        email: user.email,
        phone: user.phone,
        photo: user.photo,
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

    res.json({
      success: true,
      user: {
        id: updatedUser._id,
        firstName: updatedUser.firstName,
        lastName: updatedUser.lastName,
        email: updatedUser.email,
        phone: updatedUser.phone,
        photo: updatedUser.photo,
      },
    });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

module.exports = router;
