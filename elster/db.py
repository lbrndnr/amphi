from pypika import Query, Table, Field
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
        return True
    except Exception as e:
        print(e)

        cursor.execute("ROLLBACK")
        conn.commit()
        
        return False


def insert_author(author):
    pass


def insert_paper(paper):
    papers = Table("papers")
    columns = ("url", "pdf_url", "title", "abstract", "text")
    data = tuple(paper[c] for c in columns)
    q = Query.into(papers).columns(columns).insert(data)
    return _execute(q)
