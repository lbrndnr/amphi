import db
import pdf
import arxiv
from PyPDF2 import PdfReader
import tempfile
from tqdm import tqdm


def process_arxiv_search_result(res):
    with tempfile.NamedTemporaryFile() as tmp:
        res.download_pdf(filename=tmp.name)

        try:
            reader = PdfReader(tmp.name)
        except:
            print("Failed to load pdf")
            return
            
        page_text = lambda idx: reader.pages[idx].extract_text(0).replace("\x00", "")
        text = "".join(page_text(i) for i in range(len(reader.pages)))

        pdf_url = res.pdf_url
        if ".pdf" not in pdf_url:
            pdf_url += ".pdf"

        author_names = [a.name for a in res.authors]
        author_emails = pdf.extract_emails(author_names, page_text(0))
        authors = [{"name": n, "email": e, "affiliation": None} for (n, e) in zip(author_names, author_emails)]

        references = pdf.extract_references(text)

        return {
            "url": res.entry_id,
            "pdf_url": pdf_url,
            "title": res.title,
            "abstract": res.summary,
            "text": text,
            "doi": res.doi,
            "authors": authors,
            "references": references
        }
        

def search_arxiv(query):
    search = arxiv.Search(
        query=query,
        max_results=float('inf'),
        sort_by=arxiv.SortCriterion.Relevance
    )

    fail_cnt = 0
    with tqdm(search.results()) as t:
        for res in t:
            # try:
                payload = process_arxiv_search_result(res)
                if not payload:
                    continue

                pid = db.insert_paper(payload)
                if not pid:
                    raise RuntimeError("Failed to insert paper")

                for a in payload["authors"]:
                    success = db.insert_author(a)
                    if not success:
                        raise RuntimeError("Failed to insert author")
                    
                
                
            # except KeyboardInterrupt:
            #     break
            # except Exception as e:
            #     print(e)
            #     fail_cnt += 1
            #     t.set_postfix(fail_count=fail_cnt)


if __name__ == "__main__":
    search_arxiv("computer vision")