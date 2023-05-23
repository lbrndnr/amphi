const fs = require("fs");
const pdfjs = require("pdfjs-dist/legacy/build/pdf.js");

const getText = async (doc) => {
  var text = ""
  for (i = 1; i <= doc.numPages; i++) {
    const page = await doc.getPage(i);
    const textContent = await page.getTextContent();
    for (item of textContent.items) {
      text += item.str + " ";
    }
  }

  return text
    .replace(/\s+/g, " ") // make all whitespace just one character at most
    .replace(/.(-\s)./g, ""); // remove "- " 
}

const getCitations = (text) => {
  var cs = [];
  const re = /\[[0-9]+\](.+?)\. *[0-9]{4}\.(.+?)\./ig;
  const matches = text.matchAll(re);
  for (const match of matches) {
    const authors = match[1]
      .replace(/, and |, | and /g, ",")
      .split(",")
      .map(e => e.trim());

    cs.push({
      "authors": authors,
      "title": match[2].trim()
    })
  }

  return cs;
}

const readPDF = async (url) => {
  const doc = await pdfjs.getDocument(url).promise;
  metaData = await doc.getMetadata();

  if (!metaData.info.Title) {
    return null;
  }

  const res = {
    title: null,
    keywords: null,
    authors: null,
    text: null,
    citations: null,
  };
  res.text = await getText(doc);
  res.title = metaData.info.Title;

  if (metaData.info.Subject) {
    res.ccs = metaData.info.Subject
      .replace(/[^a-zA-Z ]{1,}/g, ",")
      .split(",")
      .map(s => s.trim())
      .filter(s => s.length > 0);
  }

  if (metaData.info.Keywords) {
    res.keywords = metaData.info.Keywords
      .replace(/[;,]/g, ",")
      .split(",")
      .map(e => e.trim());
  }

  if (metaData.info.Author) {
    const authorNames = metaData.info.Author
      .replace(/, and |, | and /g, ",")
      .split(",")
      .map(e => e.trim());

    if (authorNames.length > 0) {
      res.authors = []
      const re = /\S+[a-z0-9]@[a-z0-9\.]+/img;
      const matches = Array.from(res.text.matchAll(re));
      for (const author of authorNames) {
        const authorIdx = res.text.indexOf(author);
        var bestMatch = null;
        var minDist = Number.MAX_SAFE_INTEGER;
        for (const match of matches) {
          const matchDist = match.index - (authorIdx + author.length);
          if (matchDist < minDist && matchDist > 0) {
            minDist = matchDist;
            bestMatch = match;
          }
        }

        if (!bestMatch) {
          console.log(`Did not find a matching email for ${author}. PDF: ${url}`);
          continue;
        }

        res.authors.push({
          "name": author,
          "email": bestMatch[0]
        });
      }
    }
  }

  res.citations = getCitations(res.text);

  return res;
};

module.exports = { readPDF };
