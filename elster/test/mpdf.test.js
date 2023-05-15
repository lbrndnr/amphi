const mpdf = require("../mpdf");
const fs = require("fs");

filenames = [
  "3582016.3582041",
  "2001.01653"
]

describe("mpdf", () => {
  for (file of filenames) {
    test(file, async () => {
      [meta, gt] = await load(file);

      expect(meta.title).toEqual(gt["title"]);
      expect(meta.keywords).toEqual(gt["keywords"]);
      expect(meta.ccs).toEqual(gt["ccs"]);
      expect(meta.authors.map(a => a.name)).toEqual(gt.authors.map(a => a.name));
      expect(meta.authors.map(a => a.email)).toEqual(gt.authors.map(a => a.email));
    });
  }
});

async function load(name) {
  const meta = await mpdf.readPDF(`test/res/${name}.pdf`);
  const raw = fs.readFileSync(`test/res/${name}.json`);
  const gt = JSON.parse(raw);

  return [meta, gt];
}
