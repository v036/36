const fpPromise = import('https://fpcdn.io/v3/nDQd96V5VSW0V679K3o8')
.then(FingerprintJS => FingerprintJS.load());

// Get the visitor identifier when you need it.
fpPromise
.then(fp => fp.get())
//.then(result => $('#response').html(JSON.stringify(result)));
//.then(result => console.log(result.visitorId));
const express = require('express');

const app = express();

app.use(express.json(result)); //This is the line that you want to add