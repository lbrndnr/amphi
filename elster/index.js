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

const uri = "mongodb://amphi:amphi@localhost:27017";
const client = new MongoClient(uri,  {
  serverApi: {
      version: ServerApiVersion.v1,
      strict: true,
      deprecationErrors: true,
  }
});

client.connect();
// Send a ping to confirm a successful connection
client.db("admin").command({ ping: 1 });
console.log("Pinged your deployment. You successfully connected to MongoDB!");

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
          const path = `downloads${appendix}.pdf`;

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
