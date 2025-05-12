const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  username: {
    type: String,
    required: [true, 'Username is required'],
    unique: true,
    trim: true,
    index: true,
  },
  password: {
    type: String,
    required: [true, 'Password is required'],
  },
  email: {
    type: String,
    required: [true, 'Email is required'],
    unique: true,
    trim: true,
    lowercase: true,
    index: true,
    match: [/.+\@.+\..+/, 'Please fill a valid email address'],
  },
  yearly_goal: {
    type: Number,
    min: [0, 'Yearly goal cannot be negative'],
  },
  month_goal: { 
    type: Number,
    min: [0, 'Monthly goal cannot be negative'],
  },
  profile_img:{
    type: String,
    required: false
  },
  bio:{
    type: String,
    required: false
  },
  created_at: {
    type: Date,
    default: Date.now,
  },
});

// hash password
const bcrypt = require('bcrypt');
userSchema.pre('save', async function(next) {
  if (!this.isModified('password')) return next();

  try {
    const salt = await bcrypt.genSalt(10);
    this.password = await bcrypt.hash(this.password, salt);
    next();
  } catch (err) {
    next(err);
  }
});

module.exports = mongoose.model('User', userSchema);