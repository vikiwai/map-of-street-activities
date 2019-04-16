
const request = require('request');

const MongoClient = require('mongodb').MongoClient
let db;

const kudagoCats = [
  'ball',
  'business-events',
  'cinema',
  'circus',
  'comedy-club',
  'concert',
  'dance-trainings',
  'education',
  'evening',
  'exhibition',
  'fashion',
  'festival',
  'flashmob',
  'games',
  'global',
  'holiday',
  'kids',
  'kvn',
  'magic',
  'masquerade',
  'meeting',
  'night',
  'open',
  'other',
  'party',
  'permanent-exhibitions',
  'photo',
  'presentation',
  'quest',
  'show',
  'social-activity',
  'speed-dating',
  'sport',
  'stand-up',
  'theater',
  'tour',
  'yarmarki-razvlecheniya-yarmarki'
];

const saveKudagoEvents = (nPage) => {
  console.log("Requesting page", nPage, "of events from KugaGo...");

  let reqUrl = 'https://kudago.com/public-api/v1.4/events/'
  reqUrl += '?fields=' + ['id', 'title', 'description', 'dates', 'place', 'images'].join(',');
  reqUrl += '&expand=place';
  reqUrl += '&page_size=100';
  reqUrl += '&page='+ nPage;
  reqUrl += '&location=msk';
  reqUrl += '&categories=' + kudagoCats.join(',');

  request(reqUrl, { json: true }, (err, res) => {
    if(err) {
      console.error(err);
      return;
    }

    const { count, results } = res.body;

    console.log("Got", results.length, "events of the total", count);

    results.forEach(eventInfo => {
      if(!eventInfo.place) {
        console.log("No place:", eventInfo.id, eventInfo.title);
        return;
      }

      const tStart = eventInfo.dates[0].start;
      const tEnd = eventInfo.dates[0].end;

      let [startDate, startTime] = new Date(tStart * 1000).toISOString().split('T');

      startTime = startTime.substr(0, startTime.lastIndexOf(':'));

      const activityRecord = {
        titleA: eventInfo.title,
        locationName: eventInfo.place.address,
        coordsLat: eventInfo.place.coords.lat,
        coordsLon: eventInfo.place.coords.lon,
        company: eventInfo.place.title,
        wholeDescription: eventInfo.description,
        date: startDate,
        timeStart: startTime,
        durationHours: (tEnd - tStart) / 3600,
        creatorEmail: 'kudago',
        kudagoId: eventInfo.id
      };

      const dbActivites = db.collection('activities');

      dbActivites.findOne({ creatorEmail: 'kudago', kudagoId: eventInfo.id }).then(result => {
        if(result) {
            console.log("Already known:", eventInfo.id, eventInfo.title);
            return;
        }

        db.collection('activities').insertOne(activityRecord).then(result => {
          console.log("New event:", eventInfo.id, eventInfo.title);
        });
      });
    });

  });
};

MongoClient.connect('mongodb://localhost:27017/', { useNewUrlParser: true }, (err, client) => {
  if(err) {
    throw err;
  }

  db = client.db('viker');

  console.log("Database connection OK");

  saveKudagoEvents(2);
});
