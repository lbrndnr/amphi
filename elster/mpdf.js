const fs = require("fs");
const pdfjs = require("pdfjs-dist/legacy/build/pdf.js");

const readPDF = async (url) => {
  const doc = await pdfjs.getDocument(url).promise;
  const res = {
    title: null,
    keywords: null,
    authors: null,
    text: null
  };

  var text = ""
  for (i = 1; i <= 1; i++) {
    const page = await doc.getPage(i);
    const textContent = await page.getTextContent();
    for (item of textContent.items) {
      text += item.str + " ";
    }
  }

  // make all whitespace just one character at most
  text = text.replace(/\s+/g, " ");
  // remove "- " 
  text = text.replace(/.(-\s)./g, "");
  res.text = text;

  metaData = await doc.getMetadata();
  res.title = metaData.info.Title;

  var subject = metaData.info.Subject;
  subject = subject.substring(0, subject.indexOf(";"));
  subject = subject.replace(/[->\.]{1,3}/g, ",");
  res.ccs = subject.split(",").map(s => s.trim()).filter(s => s.length > 0);

  var keywords = metaData.info.Keywords;
  keywords = keywords.split(";").map(e => e.trim());
  res.keywords = keywords;

  var authorNames = metaData.info.Author;
  authorNames = authorNames.split(",").map(e => e.replace("and", "").trim());

  if (authorNames.length > 0) {
    res.authors = []
    const re = /\S+[a-z0-9]@[a-z0-9\.]+/img;
    const matches = Array.from(text.matchAll(re));
    for (const author of authorNames) {
      const authorIdx = text.indexOf(author);
      var bestMatch = null;
      var minDist = Number.MAX_SAFE_INTEGER;
      for (const match of matches) {
        const matchDist = Math.abs(match.index - authorIdx);
        if (matchDist < minDist) {
          minDist = matchDist;
          bestMatch = match;
        }
      }

      res.authors.push({
        "name": author,
        "email": bestMatch[0]
      });
    }
  }

  return res;
};

module.exports = { readPDF };
