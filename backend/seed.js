const path = require('path');
const dns = require('dns');
const dotenv = require('dotenv');
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

dns.setServers(['8.8.8.8', '8.8.4.4']);
dotenv.config({ path: path.resolve(__dirname, '.env') });

const User = require('./models/User');
const Prediction = require('./models/Prediction');
const Alert = require('./models/Alert');
const Analytics = require('./models/Analytics');
const Portfolio = require('./models/Portfolio');

const mongoUri = process.env.MONGODB_URI;

if (!mongoUri) {
  console.error('Error: debes definir MONGODB_URI en backend/.env');
  process.exit(1);
}

const createUsers = async () => {
  const adminEmail = process.env.DEFAULT_ADMIN_EMAIL || 'admin@fintech.com';
  const adminPassword = process.env.DEFAULT_ADMIN_PASSWORD || 'Admin1234';
  const clientEmail = process.env.SAMPLE_CLIENT_EMAIL || 'cliente@fintech.com';
  const clientPassword = process.env.SAMPLE_CLIENT_PASSWORD || 'Cliente1234';

  // Admin
  let admin = await User.findOne({ email: adminEmail });
  if (!admin) {
    const hashedPassword = await bcrypt.hash(adminPassword, 10);
    admin = new User({
      name: 'Administrador Principal',
      email: adminEmail,
      password: hashedPassword,
      role: 'admin',
      company: 'Fintech Systems',
      active: true,
    });
    await admin.save();
    console.log(`✅ Admin creado: ${adminEmail}`);
  } else {
    console.log(`ℹ️  Admin ya existe: ${adminEmail}`);
  }

  // Clientes
  const clientsData = [
    { name: 'Cliente Demo', email: clientEmail, password: clientPassword, company: 'Demo Inc' },
    { name: 'Juan Pérez', email: 'juan@fintech.com', password: 'Juan1234', company: 'Inversiones Pérez' },
    { name: 'María García', email: 'maria@fintech.com', password: 'Maria1234', company: 'Trading García' },
    { name: 'Carlos López', email: 'carlos@fintech.com', password: 'Carlos1234', company: 'FinTrade Corp' },
  ];

  const clients = [];
  for (const clientData of clientsData) {
    let client = await User.findOne({ email: clientData.email });
    if (!client) {
      const hashedPassword = await bcrypt.hash(clientData.password, 10);
      client = new User({
        name: clientData.name,
        email: clientData.email,
        password: hashedPassword,
        role: 'client',
        company: clientData.company,
        active: true,
      });
      await client.save();
      console.log(`✅ Cliente creado: ${clientData.email}`);
    } else {
      console.log(`ℹ️  Cliente ya existe: ${clientData.email}`);
    }
    clients.push(client);
  }

  return { admin, clients };
};

const createPredictions = async (clients) => {
  const predictionTemplates = [
    { title: 'BTC Rally Q4', description: 'Bitcoin muestra patrón de consolidación con proyección alcista para fin de año.', amount: 15000, probability: 82, trend: 'alcista', category: 'Cryptos', targetReturn: 28.5, riskLevel: 'Alto', status: 'approved' },
    { title: 'Nvidia (NVDA) IA Growth', description: 'Demanda de procesadores de IA impulsará ingresos récord en el próximo trimestre.', amount: 22000, probability: 78, trend: 'alcista', category: 'Acciones', targetReturn: 19.4, riskLevel: 'Medio', status: 'approved' },
    { title: 'Ajuste en Tasas EUR/USD', description: 'Políticas del Banco Central Europeo podrían debilitar el Euro frente al Dólar.', amount: 8500, probability: 65, trend: 'bajista', category: 'Forex', targetReturn: 8.2, riskLevel: 'Bajo', status: 'pending' },
    { title: 'Oro Cobertura Inflacionaria', description: 'El Oro físico actúa como reserva de valor ante tensión geopolítica.', amount: 11000, probability: 70, trend: 'alcista', category: 'Commodities', targetReturn: 12.0, riskLevel: 'Bajo', status: 'completed' },
    { title: 'Petróleo Brent Volatilidad', description: 'Incertidumbre en la producción mantendrá precios flotando en rango lateral.', amount: 9500, probability: 55, trend: 'neutral', category: 'Commodities', targetReturn: 5.0, riskLevel: 'Medio', status: 'pending' },
    { title: 'ETH L2 Expansion', description: 'Migración a redes de capa 2 incrementará el volumen de transacciones de Ethereum.', amount: 18000, probability: 74, trend: 'alcista', category: 'Cryptos', targetReturn: 24.0, riskLevel: 'Alto', status: 'approved' },
  ];

  for (const client of clients) {
    for (let i = 0; i < predictionTemplates.length; i++) {
      const template = predictionTemplates[i];
      const existingPred = await Prediction.findOne({ title: `${template.title} (${client.name})` });
      if (!existingPred) {
        const prediction = new Prediction({
          title: `${template.title} (${client.name})`,
          description: template.description,
          amount: template.amount + (i * 1200),
          probability: template.probability,
          trend: template.trend,
          category: template.category,
          targetReturn: template.targetReturn,
          riskLevel: template.riskLevel,
          status: template.status,
          createdBy: client._id,
          history: [
            { date: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000), value: template.amount * 0.92 },
            { date: new Date(), value: template.amount },
          ],
        });
        await prediction.save();
      }
    }
  }
  console.log(`✅ Predicciones completas creadas para todos los clientes`);
};

const createAlerts = async (clients) => {
  for (const client of clients) {
    const existingAlert = await Alert.findOne({ userId: client._id });
    if (!existingAlert) {
      const alerts = [
        new Alert({
          userId: client._id,
          type: 'prediction_approved',
          title: 'Predicción Aprobada',
          message: 'Tu predicción sobre BTC ha sido aprobada por el equipo',
          read: false,
        }),
        new Alert({
          userId: client._id,
          type: 'system',
          title: 'Bienvenida',
          message: 'Bienvenido al sistema de predicciones. Comienza creando tu primera predicción.',
          read: true,
        }),
      ];
      await Alert.insertMany(alerts);
    }
  }
  console.log(`✅ Alertas creadas`);
};

const createAnalytics = async (clients) => {
  for (const client of clients) {
    const predictions = await Prediction.find({ createdBy: client._id });
    
    for (const prediction of predictions) {
      const existingAnalytics = await Analytics.findOne({ predictionId: prediction._id });
      if (!existingAnalytics) {
        const completed = predictions.filter((p) => p.status === 'completed').length;
        const successRate = predictions.length > 0 ? (completed / predictions.length) * 100 : 0;

        const analytics = new Analytics({
          userId: client._id,
          predictionId: prediction._id,
          accuracy: Math.random() * 100,
          roi: Math.random() * 50,
          successRate,
          totalPredictions: predictions.length,
          completedPredictions: completed,
        });
        await analytics.save();
      }
    }
  }
  console.log(`✅ Analytics creados`);
};

const createPortfolios = async (clients) => {
  for (const client of clients) {
    const existingPortfolio = await Portfolio.findOne({ userId: client._id });
    if (!existingPortfolio) {
      const predictions = await Prediction.find({ createdBy: client._id });
      const totalValue = predictions.reduce((sum, p) => sum + p.amount, 0);

      const portfolio = new Portfolio({
        userId: client._id,
        totalValue,
        currency: 'USD',
        predictions: predictions.map((p) => p._id),
        performanceHistory: [
          { date: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000), value: totalValue * 0.95, changePercent: -5 },
          { date: new Date(), value: totalValue, changePercent: 5.26 },
        ],
      });
      await portfolio.save();
    }
  }
  console.log(`✅ Portfolios creados`);
};

const seed = async () => {
  try {
    await mongoose.connect(mongoUri, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });

    console.log('✅ Conectado a MongoDB Atlas.\n');

    const { admin, clients } = await createUsers();
    await createPredictions(clients);
    await createAlerts(clients);
    await createAnalytics(clients);
    await createPortfolios(clients);

    console.log('\n✅ Seed completado exitosamente!');
    console.log('\nPuedes iniciar sesión con:');
    console.log(`  Admin: ${process.env.DEFAULT_ADMIN_EMAIL || 'admin@fintech.com'} / ${process.env.DEFAULT_ADMIN_PASSWORD || 'Admin1234'}`);
    console.log(`  Cliente: ${process.env.SAMPLE_CLIENT_EMAIL || 'cliente@fintech.com'} / ${process.env.SAMPLE_CLIENT_PASSWORD || 'Cliente1234'}`);
  } catch (error) {
    console.error('Error en seed:', error);
  } finally {
    await mongoose.disconnect();
    process.exit(0);
  }
};

seed();
