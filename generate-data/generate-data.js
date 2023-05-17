const elasticsearch = require('@elastic/elasticsearch');
const express = require('express');
const socketIO = require('socket.io');
const morgan = require('morgan');
const LoremIpsum = require('lorem-ipsum').LoremIpsum;
const v8 = require('v8');

const host  = process.env.ES_NODE   || 'elasticsearch:443';
const index = process.env.ES_INDEX  || 'generated';
const port  = process.env.UI_PORT   || 3000;

const app = express();
const server = require('http').Server(app);
const io = socketIO(server);
const lorem = new LoremIpsum({
  sentencesPerParagraph: { max: 8, min: 4 },
  wordsPerSentence: { max: 16, min: 4 }
});


var size  = process.env.DATA_SIZE  || 1;
var rate  = process.env.DATA_RATE  || 10;
var batch = process.env.DATA_BATCH || 100; // Number of inserts per batch
var logs  = true;
var start = new Date().getTime();
var totalBytes = 0;
var intervalId;

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
  socket.on('updateValues', (data) => {
    size  = data.size  ? data.size * 1 : size;
    rate  = data.rate  ? data.rate     : rate;
    batch = data.batch ? data.batch    : batch;
    logs  = data.logs && true;
    updateInterval();
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

// Update interval
function updateInterval(){
  var intervalMs = Math.round(1000 / rate);
  if (intervalId)
    clearInterval(intervalId);
  intervalId = setInterval(insertBatch, intervalMs);
}

// Generate a random document
function generateRandomDocument() {
  var data = {
    timestamp: new Date(),
    message: lorem.generateSentences(size),
    data: lorem.generateParagraphs(size),
    bytes: 0,
    ram: process.memoryUsage()
  };
  var bytes = v8.serialize(data).length;
  data.bytes= bytes % 10 + bytes;
  return data;
}

// Insert batch of documents into Elasticsearch
async function insertBatch() {
  const documents = Array.from({ length: batch }, generateRandomDocument);
  const body = documents.flatMap((doc) => [{ index: { _index: index } }, doc]);

  try {
    const response = await client.bulk({ body });
    if (response.errors) {
      const errorItems = response.items.filter((item) => item.index && item.index.error);
      console.error('Error inserting documents:', errorItems);
    } else {
      var bytes = v8.serialize(body).length;
      var duration = new Date().getTime() - start;
      totalBytes += bytes;
      bytes = humanBytes(bytes);
      var msg = `Inserted ${batch} documents ${bytes} into ${index} on ${host} (s:${size} r:${rate})`
      var data = { 
        bytes: humanBytes(totalBytes),
        rate: humanBytes(parseInt(totalBytes/(duration/1000/60)))      };
      if (logs) {
        console.log(msg);
	data.log = msg; 
      }
      io.emit('data', data);
    }
  } catch (error) {
    console.error('Error inserting documents:', error);
  }
}

function humanBytes(size) {
    var i = size == 0 ? 0 : Math.floor(Math.log(size) / Math.log(1024));
    return (size / Math.pow(1024, i)).toFixed(2) * 1 + ' ' + ['B', 'kB', 'MB', 'GB', 'TB'][i];
}
updateInterval();
