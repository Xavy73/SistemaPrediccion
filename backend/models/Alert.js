const mongoose = require('mongoose');

const AlertSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  type: { type: String, enum: ['prediction_approved', 'prediction_completed', 'prediction_rejected', 'system'], default: 'system' },
  title: { type: String, required: true },
  message: { type: String, required: true },
  relatedPredictionId: { type: mongoose.Schema.Types.ObjectId, ref: 'Prediction' },
  read: { type: Boolean, default: false },
  createdAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model('Alert', AlertSchema);
