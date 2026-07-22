const mongoose = require('mongoose');

const HistoryItemSchema = new mongoose.Schema({
  date: { type: Date, required: true },
  value: { type: Number, required: true },
});

const PredictionSchema = new mongoose.Schema({
  title: { type: String, required: true },
  description: { type: String, required: true },
  amount: { type: Number, required: true },
  probability: { type: Number, required: true },
  trend: { type: String, enum: ['alcista', 'neutral', 'bajista'], required: true },
  category: { type: String, enum: ['Cryptos', 'Acciones', 'Forex', 'Commodities'], default: 'Acciones' },
  targetReturn: { type: Number, default: 0 },
  riskLevel: { type: String, enum: ['Bajo', 'Medio', 'Alto'], default: 'Medio' },
  status: { type: String, enum: ['pending', 'approved', 'completed'], default: 'pending' },
  createdBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  history: { type: [HistoryItemSchema], default: [] },
  createdAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model('Prediction', PredictionSchema);
