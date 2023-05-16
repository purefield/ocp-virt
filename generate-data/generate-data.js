const elasticsearch = require('@elastic/elasticsearch');
const express = require('express');
const socketIO = require('socket.io');
const morgan = require('morgan');

const host  = process.env.ES_NODE   || 'elasticsearch:443';
const index = process.env.ES_INDEX  || 'generated';
const size  = process.env.DATA_SIZE || 1024;
const rate  = process.env.DATA_RATE || 10;
const port  = process.env.UI_PORT   || 3000;

const app = express();
const server = require('http').Server(app);
const io = socketIO(server);

// Middleware to log HTTP requests
app.use(morgan('dev'));

// Serve static files
app.use(express.static('public'));

// Handle HTTP GET request to the root URL
app.get('/', (req, res) => {
  res.sendFile(__dirname + '/public/index.html');
});

// Socket.IO connection
io.on('connection', (socket) => {
  console.log('A user connected.');

  // Log message event
  socket.on('log', (data) => {
    console.log(data); // Log the data received from the client
    io.emit('log', data); // Broadcast the log to all connected clients
  });

  // Disconnect event
  socket.on('disconnect', () => {
    console.log('A user disconnected.');
  });
});

// Start the server
server.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});

// Elasticsearch configuration
const client = new elasticsearch.Client({
  node: "https://" + host,
  tls: {
    rejectUnauthorized: false
  }
});

// Parameters
const batchSize = 100; // Number of inserts per batch

// Generate a random document
function generateRandomDocument() {
  return {
    timestamp: new Date(),
    message: 'abc',
    data: 'abcde'
  };
}

// Insert batch of documents into Elasticsearch
async function insertBatch() {
  const documents = Array.from({ length: batchSize }, generateRandomDocument);
  const body = documents.flatMap((doc) => [{ index: { _index: index } }, doc]);

  try {
    const response = await client.bulk({ body });
    if (response.errors) {
      const errorItems = response.items.filter((item) => item.index && item.index.error);
      console.error('Error inserting documents:', errorItems);
    } else {
      console.log(`Inserted ${batchSize} documents into ${index} on ${host}`);
    }
  } catch (error) {
    console.error('Error inserting documents:', error);
  }
}

// Generate inserts at the specified interval
const intervalMs = Math.round(1000 / rate);
setInterval(insertBatch, intervalMs);
