
const path = require('path');

const express = require('express');

const uuidv4 = require('uuid/v4');

const MongoClient = require('mongodb').MongoClient

const app = express();
app.use(express.urlencoded({ extended: true }));
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
    </form>
    <hr />
    <form action="/activities" method="POST">
      <p>
        <input name="title" placeholder="Honey festival" />
      <p>
        <input name="locationName" placeholder="ул. Маковского, 2" />
      <p>
        <input name="coordsLat" placeholder="13.37" />
        <input name="coordsLon" placeholder="14.77" />
      <p>
        <input name="company" placeholder="ООО «Розетка-кофе»" />
      <p>
        <textarea name="description"></textarea>
      <p>
        <input name="date" placeholder="2018-01-18" />
      <p>
        <input name="timeStart" placeholder="10:00" />
      <p>
        <input name="durationHours" placeholder="4.5" />
      <p>
        <input name="authToken" placeholder="deadbeef1998" />
      <p>
        <button type="submit">Отправить!</button>
    </form>
    `);
});

app.post('/users', (req, res) => {
  console.log("POST /users:", req.body);

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
  console.log("POST /auth:", req.body);

  db.collection('users').findOne({ email: req.body.email, password: req.body.password }).then(result => {
    if(result) {
      const authToken = uuidv4();

      db.collection('users').updateOne(
        { email: req.body.email },
        { $set: { token: authToken }}
      ).then(() => {
        res.send({ status: "OK", token: authToken });
      });
    }
    else {
      res.send({ status: "INVALID_CREDENTIALS" });
    }
  })
});

app.get('/activities', (req, res) => {
  console.log("GET /activities");

  db.collection('activities').find().toArray((err, activities) => {
    if(err) {
      console.log(err);
      res.send([]);
    }
    else {
      res.send(activities.map(activity => Object.assign(activity, { _id: undefined })));
    }
  });
});

app.post('/activities', (req, res) => {
  console.log("POST /activities:", req.body);

  db.collection('users').findOne({ token: req.body.authToken }).then(user => {
    if(user) {
      db.collection('activities').insertOne({
          titleA: req.body.title,
          locationName: req.body.locationName,
          coordsLat: parseFloat(req.body.coordsLat),
          coordsLon: parseFloat(req.body.coordsLon),
          company: req.body.company,
          wholeDescription: req.body.description,
          date: req.body.date,
          timeStart: req.body.timeStart,
          durationHours: parseFloat(req.body.durationHours),
          creatorEmail: user.email
      }).then(result => {
        res.send({ status: "OK" });
      });
    }
    else {
      res.send({ status: "INVALID_AUTH" });
    }
  }).catch(err => {
    console.log(err);
  });
});

app.get('/check-publishing-rights', (req, res) => {
  console.log("POST /check-publishing-rights:", req.body);

  db.collection('users').findOne({ token: req.body.authToken }).then(user => {
    res.send({ canPublish: (user && (user.canPublish || user.isAdmin)) || false });
  });
});

app.get('/userpic/:email', (req, res) => {
  console.log("GET /userpic/" + req.params.email);

  db.collection('users').findOne({ email: req.params.email }).then(user => {
    if(!user) {
      res.status(404).send("");
      return;
    }

    let { userpicFilename } = user;

    if(!userpicFilename) {
      if(user.gender === 'female') {
        userpicFilename = 'default-female.png';
      }
      else {
        userpicFilename = 'default-male.png';
      }
    }

    res.sendFile(path.join(__dirname, 'img', userpicFilename));
  });
});

const loadData = require('./loadData');

MongoClient.connect('mongodb://localhost:27017/viker', { useNewUrlParser: true }, (err, client) => {
  if(err) {
    throw err;
  }

  db = client.db('viker');

  const port = 80;

  console.log(`Will listen on port ${port}...`)

  setInterval(async() => loadData(db), 10 * 60 * 1000);

  app.listen(port);
});
