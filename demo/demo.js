const namespace = process.env.NAMESPACE || 'next-gen-virt';
const express = require('express');
const port  = process.env.PORT || 8080;
const host = process.env.HOST;

const app = express();
const server = require('http').Server(app);
// Handle HTTP GET request to the root URL
app.get('/', (req, res) => {
  res.send(frames);
});
// Start the server
server.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});

let frames = `
<!DOCTYPE html>
<html>
   <head>
      <title>Next Gen Virt Demo</title>
   </head>
   <frameset rows = "80%,20%">
      <frame name = "listings" src = "https://${host}/k8s/ns/${namespace}/kubevirt.io~v1~VirtualMachine" />
      <frame name = "terminal" src = "https://${host}/k8s/ns/${namespace}/pods/ubi9/terminal" />
   </frameset>
</html>`;
