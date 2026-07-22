const mongoose = require('mongoose');

const AnalyticsSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  predictionId: { type: mongoose.Schema.Types.ObjectId, ref: 'Prediction', required: true },
  accuracy: { type: Number, default: 0 },
  roi: { type: Number, default: 0 },
  successRate: { type: Number, default: 0 },
  totalPredictions: { type: Number, default: 0 },
  completedPredictions: { type: Number, default: 0 },
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model('Analytics', AnalyticsSchema);
