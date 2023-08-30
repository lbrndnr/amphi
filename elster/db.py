from pypika import PostgreSQLQuery, Table
import psycopg2

conn = psycopg2.connect(database="amphi_dev",
                        host="localhost",
                        user="postgres",
                        password="docker",
                        port="5432")
cursor = conn.cursor()

def _execute(query):
    try:
        cursor.execute(str(query))
        conn.commit()
        return cursor.fetchone()[0]
    except Exception as e:
        print(e)

        cursor.execute("ROLLBACK")
        conn.commit()


def insert_paper_author(pid, aid):
    paper_authors = Table("paper_authors")
    columns = ("paper_id", "author_id")
    data = (pid, aid)
    q = PostgreSQLQuery.into(paper_authors).columns(columns).insert(data).returning(paper_authors.id)

    return _execute(q)


def insert_author(author):
    authors = Table("authors")
    columns = ("name", "email", "affiliation")
    data = tuple(author[c] for c in columns)
    q = PostgreSQLQuery.into(authors).columns(columns).insert(data).returning(authors.id)

    return _execute(q)


def insert_paper(paper):
    papers = Table("papers")
    columns = ("url", "pdf_url", "title", "abstract", "text")
    data = tuple(paper[c] for c in columns)
    q = PostgreSQLQuery.into(papers).columns(columns).insert(data).returning(papers.id)

    return _execute(q)
