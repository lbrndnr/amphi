const mpdf = require("./mpdf.js");
const db = require("./db.js");
const Crawler = require("crawler");
const axios = require("axios");
const fs = require("fs");
const stream = require("stream");
const util = require("util");
const tmp = require("tmp");

const finished = util.promisify(stream.finished);
async function downloadFile(fileUrl, outputLocationPath) {
  const writer = fs.createWriteStream(outputLocationPath);
  return axios({
    method: "get",
    url: fileUrl,
    responseType: "stream",
    headers: { "User-Agent": "amphibot" },
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

async function processURL(url) {
  const tmpobj = tmp.fileSync();
  const path = tmpobj.name;
  const pdfURL = pdfURLFromURL(url);
  try {
    await downloadFile(pdfURL, path);
    const meta = await mpdf.readPDF(path);
    if (meta && meta.title && meta.authors) {
      meta.url = url;
      meta.pdfURL = pdfURL;
  
      const authorIDs = await Promise.all(meta.authors.map(db.getOrInsertAuthor));
      const paperID = await db.insertPaper(meta);
      authorIDs.forEach(aID => db.insertPaperAuthor(paperID, aID));
    
      console.log(`Successfully inserted ${meta.title}.`);
    }

    return meta;
  }
  finally {
    tmpobj.removeCallback();
  }
}

async function main() {
  const c = new Crawler({
    maxConnections: 10,
    userAgent: "amphibot",
    callback: async (error, res, done) => {
      if (error) {
          console.log(error);
          done();
          return;
      }

      const re = /"(https:\/\/arxiv.org\/abs\/.*?)"/ig;
      const matches = res.body.matchAll(re);
      for (const match of matches) {
        const url = match[1];
        const meta = await processURL(url);
        if (meta) {
          const urls = meta.citations
            .map(c => {
              const query = encodeURIComponent(c);
              return `https://arxiv.org/search/?query=${query}&searchtype=all`
            })
          c.queue(urls);
        }
        else {
          console.log(`Could not process ${url}`);
        }
      }
      done();
    }
  });

  // c.queue("https://arxiv.org/abs/2001.01653");
  c.queue("https://arxiv.org/search/?query=cache&searchtype=all")
}

main();
