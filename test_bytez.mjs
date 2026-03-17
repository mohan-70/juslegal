import https from 'https';

const data = JSON.stringify({
  model: 'meta-llama/Meta-Llama-3-8B-Instruct',
  messages: [{ role: 'user', content: 'Say hello' }]
});

const req = https.request('https://api.bytez.com/v1/chat/completions', {
  method: 'POST',
  headers: {
    'Authorization': 'eaf07f8f4ab7d5b5b16c56d786baf843',
    'Content-Type': 'application/json'
  }
}, res => {
  let body = '';
  res.on('data', chunk => body += chunk);
  res.on('end', () => {
    console.log('Response Status:', res.statusCode);
    console.log('Response Headers:', res.headers);
    console.log('Response Body:', body);
  });
});

req.on('error', (e) => {
    console.error('Request Error:', e);
});
req.write(data);
req.end();
