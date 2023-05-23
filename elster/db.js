const knex = require('knex')({
  client: "pg",
  connection: {
    database: "amphi_dev",
    user: "postgres",
    password: "docker",
    host: "localhost",
    port: 5432,
  }
});

async function paperExists(url) {
  const res = await knex
    .select("id")
    .from("papers")
    .whereLike("url", url)
    .limit(1);

  return res.length > 0;
}

async function insertPaper(paper) {
  const row = clean(paper);
  const res = await knex
    .insert({
      title: row.title,
      abstract: row.abstract,
      text: row.text,
      url: row.url,
      pdf_url: row.pdfURL
    })
    .into("papers")
    .returning("id");

  return res[0].id;
}

async function getOrInsertAuthor(author) {
  await knex
    .insert({
      name: author.name,
      email: author.email,
      affiliation: author.affiliation
    })
    .into("authors")
    .onConflict("email")
    .ignore();

  const res = await knex
    .select("id")
    .from("authors")
    .where("email", author.email)
    .limit(1);

  return res[0].id;
}

async function insertPaperAuthor(paperID, authorID) {
  return await knex
    .insert({
      paper_id: paperID,
      author_id: authorID
    })
    .into("paper_authors");
}

async function tryInsertCitation(paperID, citation) {
  var citationID = await knex
    .select("id")
    .from("papers")
    .whereILike("title", citation.title)
    .limit(1);

  if (citationID) {
    await knex
    .insert({
      reference_id: paperID,
      citation_id: citationID
    })
    .into("paper_references");
  }
}

module.exports = {
  paperExists,
  insertPaper,
  getOrInsertAuthor,
  insertPaperAuthor,
  tryInsertCitation
};