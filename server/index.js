
const express = require('express');

const MongoClient = require('mongodb').MongoClient

const app = express();
app.use(express.urlencoded());

let db;

app.get('/', (req, res) => {
  res.send(`
    <form action="/users" method="POST">
      <p>
        <input name="firstName" placeholder="Виктория" />
      <p>
        <input name="lastName" placeholder="Буняева" />
      <p>
        <input name="birthDate" placeholder="1998-02-04" />
      <p>
        <select name="gender">
          <option>Male</option>
          <option>Female</option>
          <option>Huilo</option>
        </select>
      <p>
        <input name="email" placeholder="ebich@govno.com" />
      <p>
        <input type="password" name="password" placeholder="Пароль" />
      <p>
        <button type="submit">Отправить!</button>
    </form>
    <hr />
    <form action="/auth" method="POST">
      <p>
        <input name="email" placeholder="ebich@govno.com" />
      <p>
        <input type="password" name="password" placeholder="Пароль" />
      <p>
        <button type="submit">Отправить!</button>
    </form>`);
});

app.post('/users', (req, res) => {
  db.collection('users').find({ email: req.body.email }).count().then(result => {
    console.log(result);
    if(result) {
      res.send(`{"status": "ALREADY_EXISTS"}`);
    }
    else {
      db.collection('users').insertOne(req.body);

      res.send(`{"status": "OK"}`);
      // res.send(`<pre>${JSON.stringify(req.body, null, 4)}</pre>`);
    }
  });
});

app.post('/auth', (req, res) => {
  db.collection('users').findOne({ email: req.body.email, password: req.body.password }).then(result => {
    if(result) {
      res.send(`{"result": "OK", "token": "deafbeef"}`);
    }
    else {
      res.send(`{"result": "INVALID_CREDENTIALS"}`);
    }
  })
});

MongoClient.connect('mongodb://localhost:27017/viker', { useNewUrlParser: true }, (err, client) => {
  if(err) {
    throw err;
  }

  db = client.db('viker');

  app.listen(80);
});
