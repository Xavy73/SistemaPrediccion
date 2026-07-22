const dns = require('dns');
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const dotenv = require('dotenv');

// Use public DNS servers for Atlas SRV lookups when the local resolver refuses connection.
dns.setServers(['8.8.8.8', '8.8.4.4']);

dotenv.config();

const User = require('./models/User');
const authRoutes = require('./routes/auth');
const userRoutes = require('./routes/users');
const predictionRoutes = require('./routes/predictions');
const dashboardRoutes = require('./routes/dashboard');
const alertRoutes = require('./routes/alerts');
const analyticsRoutes = require('./routes/analytics');

const app = express();
app.use(cors());
app.use(express.json());

const mongoUri = process.env.MONGODB_URI;
if (!mongoUri) {
  console.error('Error: MONGODB_URI no está definido en .env');
  process.exit(1);
}

const createInitialAdmin = async () => {
  try {
    const existingAdmin = await User.findOne({ role: 'admin' });
    if (!existingAdmin) {
      const bcrypt = require('bcryptjs');
      const password = process.env.DEFAULT_ADMIN_PASSWORD || 'Admin1234';
      const hashedPassword = await bcrypt.hash(password, 10);
      const adminEmail = process.env.DEFAULT_ADMIN_EMAIL || 'admin@fintech.com';
      const adminUser = new User({
        name: 'Administrador',
        email: adminEmail,
        password: hashedPassword,
        role: 'admin',
      });
      await adminUser.save();
      console.log(`Usuario administrador inicial creado: ${adminEmail}`);
    }
  } catch (error) {
    console.error('Error creando usuario administrador inicial:', error.message);
  }
};

mongoose
  .connect(mongoUri, {
    useNewUrlParser: true,
    useUnifiedTopology: true,
  })
  .then(async () => {
    console.log('MongoDB Atlas conectado');
    await createInitialAdmin();
  })
  .catch((error) => {
    console.error('Error conectando a MongoDB Atlas:', error.message);
    process.exit(1);
  });

app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/predictions', predictionRoutes);
app.use('/api/dashboard', dashboardRoutes);
app.use('/api/alerts', alertRoutes);
app.use('/api/analytics', analyticsRoutes);

app.get('/', (req, res) => {
  res.json({ status: 'OK', message: 'SistemaPredicciones backend activo' });
});

const PORT = process.env.PORT || 4000;
const server = app.listen(PORT, '0.0.0.0', () => {
  console.log(`Backend escuchando en 0.0.0.0:${PORT} (Accesible desde móvil 172.30.115.72, emulador 10.0.2.2 y 127.0.0.1)`);
});

server.on('error', (err) => {
  if (err.code === 'EADDRINUSE') {
    console.log(`\n⚠️  El puerto ${PORT} ya está en uso. El servidor backend ya se encuentra activo y listo en el puerto 4000.`);
  } else {
    console.error('Error en el servidor backend:', err);
  }
});
