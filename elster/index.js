const mpdf = require("./mpdf.js");
const Crawler = require('crawler');
const axios = require("axios");
const fs = require("fs");
const stream = require("stream");
const util = require("util");
const Pool = require('pg').Pool

var pool = new Pool({
  database: "amphi_dev",
  user: "postgres",
  password: "docker",
  host: "localhost",
  port: 5432,
});

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

function pdfURLFromURL(url) {
  if (!url.includes("abs")) { return null; }

  const comps = url.split("/")
  const id = comps.pop() || comps.pop(); // in case there is a trailing slash

  return `https://arxiv.org/pdf/${id}.pdf`
}

async function paperExists(title) {
  const res = await pool.query("select id from papers where p.title like $1", [title]);
  return res.rowCount > 0;
}

async function insert(meta) {
  const pdfURL = pdfURLFromURL(meta.url);
  await pool.query("insert into papers (title, url, pdf_url, abstract, text) values ($1, $2, $3, $4, $5) returning *", [meta.title, meta.url, pdfURL, meta.abstract, meta.text]);
  console.log(`Successfully inserted ${meta.title}.`);
}

async function main() {
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
                  await insert(meta);
                  fs.unlinkSync(path);
                  done();
              });
            });
          }
      }
  });

  c.queue("https://arxiv.org/abs/2001.01653");

  c.on("drain", async () => {
    await pool.end();
  });
}

main();
