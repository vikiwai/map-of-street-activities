
const express = require('express');

const uuidv4 = require('uuid/v4');

const MongoClient = require('mongodb').MongoClient

const app = express();
app.use(express.urlencoded());
app.use(express.json());

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
  console.log("/users:", req.body);

  db.collection('users').find({ email: req.body.email }).count().then(result => {
    if(result) {
      res.send(`{"status": "ALREADY_EXISTS"}`);
    }
    else {
      const authToken = uuidv4();

      db.collection('users').insertOne(Object.assign({}, req.body, { token: authToken }));

      res.send({ status: "OK", token: authToken });
    }
  }).catch(err => {
    console.log(err);
  });
});

app.post('/auth', (req, res) => {
  console.log("/auth:", req.body);

  db.collection('users').findOne({ email: req.body.email, password: req.body.password }).then(result => {
    if(result) {
      const authToken = uuidv4();

      db.collection('users').updateOne(
        { email: req.body.email },
        { $set: { token: authToken }}
      ).then(() => {
        res.send({ result: "OK", token: authToken });
      });
    }
    else {
      res.send({ result: "INVALID_CREDENTIALS" });
    }
  })
});

app.get('/activities', (req, res) => {
  res.send({ something: "orOther" });
});

app.post('/activities', (req, res) => {
  console.log("/activities:", req.body);


});

MongoClient.connect('mongodb://localhost:27017/viker', { useNewUrlParser: true }, (err, client) => {
  if(err) {
    throw err;
  }

  db = client.db('viker');

  app.listen(80);
});
