const axios = require('axios');
const cheerio = require('cheerio');

const url = 'https://quote.kapook.com/';

axios.get(url).then((response) => {
  const html = response.data;
  const $ = cheerio.load(html);
  const quotes = [];

  $('.quote-text').each((index, element) => {
    const text = $(element).text();
    const author = $(element).next('.quote-author').text();
    quotes.push({
      quote: text.trim(),
      author: author.trim(),
    });
  });

  console.log(quotes); // แสดงผลคำคมที่ดึงมาได้
}).catch((error) => {
  console.error('Error:', error);
});
