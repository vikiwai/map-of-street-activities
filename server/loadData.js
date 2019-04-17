
const request = require('request');

const MongoClient = require('mongodb').MongoClient;

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

const selectDate = eventDates => {
  for(let i = 0; i < eventDates.length; i++) {
    const date = {
      start: new Date(eventDates[i].start * 1000),
      end: new Date(eventDates[i].end * 1000)
    };

    if(new Date() < date.end) {
      return date;
    }
  }

  return null;
};

const saveAnEvent = (db, eventInfo) => {
  return new Promise((resolve, reject) => {
    if(!eventInfo.place) {
      resolve(0);
      return;
    }

    const date = selectDate(eventInfo.dates);

    if(!date) {
      console.log(eventInfo.id + ":", "no dates or all have passed");
      resolve(0);
      return;
    }

    let [startDate, startTime] = date.start.toISOString().split('T');
    startTime = startTime.substr(0, startTime.lastIndexOf(':'));

    const durationHours = (date.end - date.start) / 3600 / 1000;

    const activityRecord = {
      titleA: eventInfo.title,
      locationName: eventInfo.place.address,
      coordsLat: eventInfo.place.coords.lat,
      coordsLon: eventInfo.place.coords.lon,
      company: eventInfo.place.title,
      wholeDescription: eventInfo.description,
      date: startDate,
      timeStart: startTime,
      durationHours: durationHours,
      creatorEmail: 'kudago',
      kudagoId: eventInfo.id
    };

    db.collection('activities').findOne({ creatorEmail: 'kudago', kudagoId: eventInfo.id }).then(result => {
      if(result) {
          resolve(0);
      }
      else {
        db.collection('activities').insertOne(activityRecord).then(result => {
          if(result.result.ok) {
            resolve(1);
          }
          else {
            resolve(0);
          }
        });
      }
    });
  });
};

let nTotal = null;

const savePageOfEvents = (db, nPage) => {
  return new Promise((resolve, reject) => {
    let reqUrl = 'https://kudago.com/public-api/v1.4/events/'
    reqUrl += '?fields=' + ['id', 'title', 'description', 'dates', 'place', 'images'].join(',');
    reqUrl += '&expand=place';
    reqUrl += '&page_size=100';
    reqUrl += '&page='+ nPage;
    reqUrl += '&location=msk';
    reqUrl += '&order_by=-publication_date';
    reqUrl += '&actual_since=' + parseInt(Date.now() / 1000);
    reqUrl += '&categories=' + kudagoCats.join(',');

    request(reqUrl, { json: true }, (err, res) => {
      if(err) {
        console.error(err);
        return;
      }

      const { count, results } = res.body;

      if(!nTotal) {
        console.log("There seems to be a total of", nTotal = count, "events");
      }

      Promise.all(results.map(result => saveAnEvent(db, result))).then(xs => {
        resolve(xs.reduce((x, y) => x + y));
      });
    });
  });
};

const saveNewEvents = async(db) => {
  console.log("Will now load the current events from KudaGo...")

  let nTotalSaved = 0;

  for(let i = 1; !nTotal || (i - 1) * 100 < nTotal; i++) {
    console.log("Requesting page", i + "...");

    const nSaved = await savePageOfEvents(db, i);

    // console.log("Loaded", nSaved, "new events.");

    nTotalSaved += nSaved;
  }

  console.log("Processed", nTotal, "events,", nTotalSaved, "of them new.");
};

module.exports = saveNewEvents;
