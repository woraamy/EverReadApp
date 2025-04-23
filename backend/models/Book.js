const mongoose = require('mongoose');

const BookStatus = ["want to read", "currently reading", "finished"];

const bookSchema = new mongoose.Schema({
  api_id: { 
    type: String, 
    required: true,
    index: true,
  },
  user_id: { 
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: [true, 'User ID is required'],
    index: true,
  },
  name: { 
    type: String,
    required: [true, 'Book name/title is required'],
    trim: true,
  },
  author: { 
    type: String,
    required: [true, 'Book author is required'],
    trim: true,
  },
  page_count: {
    type: Number,
    min: [0, 'Page count cannot be negative'],
  },
  current_page: {
    type: Number,
    default: 0,
    min: [0, 'Current page cannot be negative'],
    validate: {
        validator: function(value) {
            return this.page_count == null || value <= this.page_count;
        },
        message: props => `Current page (${props.value}) cannot exceed total page count (${this.page_count}).`
    }
  },
  status: {
    type: String,
    required: true,
    enum: {
        values: BookStatus,
        message: props => `${props.value} is not a valid status. Must be one of: ${BookStatus.join(', ')}`
    },
    default: 'want to read',
  },
});

bookSchema.index({ user_id: 1, api_id: 1 });

module.exports = mongoose.model('Book', bookSchema);