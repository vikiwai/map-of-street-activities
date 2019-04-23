
const path = require('path');

const express = require('express');
const fileUpload = require('express-fileupload');

const uuidv4 = require('uuid/v4');

const mongodb = require('mongodb');

const app = express();
app.use(express.urlencoded({ extended: true }));
app.use(express.json());
app.use(fileUpload({ limits: { fileSize: 1 * 1024 * 1024 } }));

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
          <option>Rather not say</option>
        </select>
      <p>
        <input name="email" placeholder="@.com" />
      <p>
        <input type="password" name="password" placeholder="Пароль" />
      <p>
        <label><input type="checkbox" name="isAdmin"/> isAdmin</label>
      <p>
        <button type="submit">Отправить!</button>
    </form>
    <hr />
    <form action="/auth" method="POST">
      <p>
        <input name="email" placeholder="@.com" />
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
        <select multiple name="categories">
          <option>ball</option>
          <option>business-events</option>
          <option>cinema</option>
          <option>circus</option>
          <option>comedy-club</option>
          <option>concert</option>
          <option>dance-trainings</option>
          <option>education</option>
          <option>evening</option>
          <option>exhibition</option>
          <option>fashion</option>
          <option>festival</option>
          <option>flashmob</option>
          <option>games</option>
          <option>global</option>
          <option>holiday</option>
          <option>kids</option>
          <option>kvn</option>
          <option>magic</option>
          <option>masquerade</option>
          <option>meeting</option>
          <option>night</option>
          <option>open</option>
          <option>other</option>
          <option>party</option>
          <option>permanent-exhibitions</option>
          <option>photo</option>
          <option>presentation</option>
          <option>quest</option>
          <option>show</option>
          <option>social-activity</option>
          <option>speed-dating</option>
          <option>sport</option>
          <option>stand-up</option>
          <option>theater</option>
          <option>tour</option>
        </select>
      <p>
        <textarea name="description"></textarea>
      <p>
        <input name="date" placeholder="2018-01-18" />
      <p>
        <input name="timeStart" placeholder="10:00" />
      <p>
        <input name="durationHours" placeholder="4.5" />
      <p>
        <input name="authToken" placeholder="deadbeef-1337-abad-babe-aaaabbbbcccc" />
      <p>
        <button type="submit">Отправить!</button>
    </form>
    <hr />
    <form action="/userpic" method="POST" enctype="multipart/form-data">
      <p>
        <input name="authToken" placeholder="deadbeef-1337-abad-babe-aaaabbbbcccc" />
      <p>
        <input type="file" name="userpic" />
      <p>
        <button type="submit">Отправить!</button>
    </form>
    <hr />
    <form action="/publishing-rights-applications" method="POST">
      <p>
        Заявка на права публикации:
      <p>
        <input name="authToken" placeholder="deadbeef-1337-abad-babe-aaaabbbbcccc" />
      <p>
        <button type="submit">Отправить!</button>
    </form>
    <hr />
    <form action="/publishing-rights" method="POST">
      <p>
        Права публикации:
      <p>
        <input name="authToken" placeholder="deadbeef-1337-abad-babe-aaaabbbbcccc" />
      <p>
        <input name="email" placeholder="ebich@govno.com" />
      <p>
        <label><input type="checkbox" name="canPublish" /> canPublish</label>
      <p>
        <button type="submit">Отправить!</button>
    </form>
    <hr />
    <form action="/favourites/q" method="POST">
      <p>
        <input name="authToken" placeholder="deadbeef-1337-abad-babe-aaaabbbbcccc" />
      <p>
        <input name="id" placeholder="5cb914088f049745521bbf70" />
      <p>
        <button type="submit">Отправить!</button>
    </form>
    <hr />
    <form action="/password" method="POST">
      <p>
        <input name="authToken" placeholder="deadbeef-1337-abad-babe-aaaabbbbcccc" />
      <p>
        <input name="password" placeholder="qwerty123" />
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

      const newUser = Object.assign({}, req.body, {
        favouriteIds: [],
        token: authToken,
        canPublish: false,
        isAdmin: req.body.isAdmin ? true : false
      });

      db.collection('users').insertOne(newUser);

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
      res.send(activities.map(activity => Object.assign({}, activity, { _id: undefined, id: activity._id })));
    }
  });
});

app.post('/activities', (req, res) => {
  console.log("POST /activities:", req.body);

  db.collection('users').findOne({ token: req.body.authToken }).then(user => {
    if(user) {
      let categories = req.body.categories;

      if(!Array.isArray(categories)) {
        categories = [categories];
      }


      db.collection('activities').insertOne({
          titleA: req.body.title,
          locationName: req.body.locationName,
          coordsLat: parseFloat(req.body.coordsLat),
          coordsLon: parseFloat(req.body.coordsLon),
          company: req.body.company,
          categories: categories,
          wholeDescription: req.body.description,
          date: req.body.date,
          timeStart: req.body.timeStart,
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

app.post('/check-publishing-rights', (req, res) => {
  console.log("POST /check-publishing-rights:", req.body);

  db.collection('users').findOne({ token: req.body.authToken }).then(user => {
    res.send({ canPublish: (user && (user.canPublish || user.isAdmin)) || false });
  });
});

app.post('/userpic', (req, res) => {
  console.log("POST /userpic", req.body);

  db.collection('users').findOne({ token: req.body.authToken }).then(user => {
    if(!user) {
      res.status(403).send({ status: 'INVALID_AUTH' });
    }
    else {
      const filename = user.email + '.jpg';

      req.files.userpic.mv(path.join(__dirname, 'img', filename));

      db.collection('users').updateOne({ email: user.email }, { $set: { userpicFilename: filename } }).then(result => {
        if(result) {
          res.send({status: 'OK' });
        }
        else {
          res.send({status: 'ERROR' });
        }
      });
    }
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
      if(user.gender === 'Female') {
        userpicFilename = 'default-female.png';
      }
      else if(user.gender === 'Male') {
        userpicFilename = 'default-male.png';
      }
      else {
        userpicFilename = 'default-transgender.png';
      }
    }

    res.sendFile(path.join(__dirname, 'img', userpicFilename));
  });
});

app.get('/profile/:authToken', (req, res) => {
  console.log("GET /profile/" + req.params.authToken);

  db.collection('users').findOne({ token: req.params.authToken }).then(user => {
    delete user._id;
    delete user.token;
    delete user.userpicFilename;

    res.send(user);
  });
});

app.post('/publishing-rights-applications', (req, res) => {
  console.log("POST /publishing-rights-applications:", req.body);

  db.collection('users').findOne({ token: req.body.authToken }).then(user => {
    if(!user) {
      res.status(403).send({ status: 'INVALID_AUTH' });
      return;
    }

    db.collection('applications').findOne({ email: user.email }).then(application => {
      if(application) {
        res.status(400).send({ status: 'ALREADY_APPLIED' });
        return;
      }

      const newApplication = {
        email: user.email,
        isOpen: true
      };

      db.collection('applications').insertOne(newApplication).then(result => {
        if(result) {
          res.send({ status: 'OK' });
        }
        else {
          res.send({ status: 'ERROR' });
        }
      });
    });
  });
});

app.get('/publishing-rights-applications', (req, res) => {
  db.collection('applications').find({ isOpen: true }).toArray((err, applications) => {
    if(err) {
      console.log(err);
      res.send([]);
    }
    else {
      res.send(applications.map(application => application.email));
    }
  })
});

app.post('/publishing-rights', (req, res) => {
  console.log("POST /publishing-rights:", req.body);

  db.collection('users').findOne({ token: req.body.authToken }).then(user => {
    if(!user) {
      res.status(403).send({ status: 'INVALID_AUTH' });
      return;
    }
    else if(!user.isAdmin) {
      res.status(403).send({ status: 'NOT_AN_ADMIN' });
      return;
    }

    const newCanPublish = req.body.canPublish ? true : false;

    db.collection('applications').updateOne({ email: req.body.email }, { $set: { isOpen: false } }).then(result => {
      db.collection('users').updateOne({ email: req.body.email }, { $set: { canPublish: newCanPublish } }).then(result => {
        if(result) {
          res.send({ status: 'OK' });
        }
        else {
          res.send({ status: 'ERROR' });
        }
      });
    });
  });
});

app.get('/favourites/:email', (req, res) => {
  console.log("GET /favourites/" + req.params.email);

  db.collection('users').findOne({ email: req.params.email }).then(user => {
    if(user) {
      const favouriteIds =( user.favouriteIds || []).map(id => mongodb.ObjectId(id));

      db.collection('activities').find({ _id : { $in : favouriteIds } }).toArray((err, activities) => {
        if(!activities) {
          if(err) {
            console.log(err);
          }

          res.send([]);
          return;
        }

        const favActivities = activities.map(activity => {
          const newActivity = Object.assign({}, activity);

          newActivity.id = newActivity._id;
          delete newActivity._id;

          return newActivity;
        });

        res.send(favActivities);
      });
    }
    else {
      res.status(404).send("User not found");
    }
  });
});

app.post('/favourites/:email', (req, res) => {
  console.log("POST /favourites/" + req.params.email + ":", req.body);

  db.collection('users').findOne({ token: req.body.authToken }).then(user => {
    if(!user || user.email !== req.params.email) {
      res.send({ status: "INVALID_AUTH" });
    }
    else {
      db.collection('users').updateOne(
        { email: req.params.email },
        { $addToSet: { favouriteIds: req.body.id } }
      ).then(result => {
        res.send({ status: "OK" });
      });
    }
  });
});

app.delete('/favourites/:email', (req, res) => {
  console.log("DELETE /favourites/" + req.params.email + ":", req.body);

  db.collection('users').findOne({ token: req.body.authToken }).then(user => {
    if(!user || user.email !== req.params.email) {
      res.send({ status: "INVALID_AUTH" });
    }
    else {
      db.collection('users').updateOne(
        { email: req.params.email },
        { $pull: { favouriteIds: req.body.id } }
      ).then(result => {
        res.send({ status: "OK" });
      });
    }
  });
});

app.post('/password', (req, res) => {
  console.log("POST /password:", req.body);

  db.collection('users').findOne({ token: req.body.authToken }).then(user => {
    if(!user) {
      res.send({ status: "INVALID_AUTH" });
      return;
    }

    db.collection('users').updateOne(
      { email: user.email },
      { $set: { password: req.body.password } }
    ).then(result => {
      if(result) {
        res.send({ status: "OK" });
      }
      else {
        res.send({ status: "ERROR" });
      }
    });

  });
});

const loadData = require('./loadData');

mongodb.MongoClient.connect('mongodb://localhost:110/map-of-street-activities', { useNewUrlParser: true }, (err, client) => {
  if(err) {
    throw err;
  }

  db = client.db('map-of-street-activities');

  const port = 81;

  console.log(`Will listen on port ${port}...`)

  //setTimeout(async() => loadData(db), 1);
  setInterval(async() => loadData(db), 10 * 60 * 1000);

  app.listen(port);
});
