const express = require('express');
const request = require('request');
const app = express();
const PORT = 3000;

app.get('/randomquote', (req, res) => {
  const apiURL = 'https://zenquotes.io/api/random';
  
  // ส่งคำขอไปยัง API ของ ZenQuotes
  request(apiURL, (error, response, body) => {
    if (error) {
      return res.status(500).send('Error occurred: ' + error);
    }
    res.setHeader('Access-Control-Allow-Origin', '*'); // แก้ปัญหา CORS
    res.send(body);
  });
});

// เริ่มเซิร์ฟเวอร์ที่พอร์ต 3000
app.listen(PORT, '127.0.0.1',() => {
  console.log(`Proxy server is running on http://127.0.0.1:${PORT}`);
});
