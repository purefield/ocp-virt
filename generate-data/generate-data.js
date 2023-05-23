const elasticsearch = require('@elastic/elasticsearch');
const express = require('express');
const socketIO = require('socket.io');
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

var size  = process.env.DATA_SIZE  || 5;
var rate  = process.env.DATA_RATE  || 10;
var batch = process.env.DATA_BATCH || 100; // Number of inserts per batch
var logs  = true;
var start = new Date().getTime();
var totalBytes = 0;
var intervalId;
var emitted = start;
var randomDoc = {};

// Serve static files
app.use(express.static('public'));

// Handle HTTP GET request to the root URL
app.get('/', (req, res) => {
  res.sendFile(__dirname + '/public/index.html');
});

// Socket.IO connection
io.on('connection', (socket) => {
  console.log('A user connected.');

  socket.on('updateValues', (data) => {
    var rateChange = data.rate != rate;
    size  = data.size  ? data.size * 1 : size;
    rate  = data.rate  ? data.rate     : rate;
    batch = data.batch ? data.batch    : batch;
    logs  = data.logs && true;
    if (rateChange) updateInterval();
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
  if (intervalId)
    clearInterval(intervalId);
  if (rate > 0) {
    var intervalMs = Math.round(1000 / rate);
    intervalId = setInterval(insertBatch, intervalMs);
  }
}

// Generate a random document
function generateRandomDocument() {
  if (!randomDoc.data) {
    var data = {
      timestamp: new Date(),
      message: lorem.generateSentences(size),
      data: lorem.generateParagraphs(size),
      bytes: 0
    };
    var bytes = v8.serialize(data).length;
    data.bytes= bytes % 10 + bytes;
    randomDoc = data;
  }
  return randomDoc;
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
      var now = new Date().getTime();
      if (now - emitted > 100){
       io.emit('data', data);
       emitted = now;
      }
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
