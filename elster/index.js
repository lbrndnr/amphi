const mpdf = require("./mpdf.js");
const Crawler = require('crawler');
const axios = require("axios");
const fs = require("fs");
const stream = require("stream");
const util = require("util");
const { MongoClient, ServerApiVersion } = require("mongodb");

const finished = util.promisify(stream.finished);
async function downloadFile(fileUrl, outputLocationPath) {
  const writer = fs.createWriteStream(outputLocationPath);
  return axios({
    method: 'get',
    url: fileUrl,
    responseType: 'stream',
    headers: { 'User-Agent': 'amphibot' },
  }).then(response => {
    response.data.pipe(writer);
    return finished(writer); //this is a Promise
  });
}

async function connect(uri) {
  const client = new MongoClient(uri,  {
    serverApi: {
        version: ServerApiVersion.v1,
        strict: true,
        deprecationErrors: true,
    }
  });

  await client.connect();

  // Send a ping to confirm a successful connection
  await client.db("amphi").command({ ping: 1 });
  console.log("Connected to DB.");

  return client;
}

function pdfURLFromURL(url) {
  if (!url.includes("abs")) { return null; }

  const comps = url.split("/")
  const id = comps.pop() || comps.pop(); // in case there is a trailing slash

  return `https://arxiv.org/pdf/${id}.pdf`
}

// const url = "https://arxiv.org/abs/2001.01653";
// const pdfURL = pdfURLFromURL(url);
// const path = "/Users/Laurin/Desktop/test.pdf";

// downloadFile(pdfURL, path).then(res => {
//   console.log("downloaded");
//   mpdf.readPDF(path).then(async meta => {
//       console.log(meta.text);

//       fs.unlinkSync(path);
//   });
// });

async function main() {
  const uri = "mongodb://amphi:amphi@localhost:27017?authSource=amphi";
  const client = await connect(uri);
  const db = client.db("amphi");
  const coll = db.collection("papers");

  const c = new Crawler({
      maxConnections: 10,
      userAgent: "amphibot",
      callback: (error, res, done) => {
          if (error) {
              console.log(error);
              done();
          }
          else {
            const $ = res.$;
            const appendix = $(".download-pdf").attr("href");
            const pdfURL = `https://arxiv.org${appendix}.pdf`;
            const path = "/Users/Laurin/Desktop/test.pdf";

            downloadFile(pdfURL, path).then(res => {
              mpdf.readPDF(path).then(async meta => {
                  const result = await coll.insertOne(meta);
                  console.log(`Inserted ${meta.title}`);

                  fs.unlinkSync(path);
                  done();
              });
            });
          }
      }
  });

  c.queue("https://arxiv.org/abs/2001.01653");

  c.on("drain", async () => {
    await client.close();
  });
}

main();
