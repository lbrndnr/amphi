import db
import arxiv
import re
from pypdf import PdfReader
import tempfile
import jellyfish as jf
import numpy as np
from tqdm import tqdm

def extract_emails(author_names, text):
    # remove any whitespace
    text = re.sub(r"[\n\r\s]+", "", text)

    # match any emails
    pattern = re.compile("(([-!#-'*+/-9=?A-Z^-~]+(\.[-!#-'*+/-9=?A-Z^-~]+)*|\"([]!#-[^-~ \t]|(\\[\t -~]))+\")@([-!#-'*+/-9=?A-Z^-~]+(\.[-!#-'*+/-9=?A-Z^-~]+)*|\[[\t -Z^-~]*]))")

    # match is a tuple (whole email address, prefix before @)
    matches = re.findall(pattern, text)

    ds = np.zeros([len(author_names), len(matches)], np.int32)
    for i, a in enumerate(author_names):
        for j, m in enumerate(matches):
            ds[i, j] = jf.levenshtein_distance(a.lower(), m[1].lower())

    es = [None] * len(author_names)
    d_max = np.amax(ds)
    for _ in range(len(es)):
        i, j = np.unravel_index(np.argmin(ds), ds.shape)
        es[i] = matches[j][0] 
        ds[i, :] = d_max

    return es


def extract_references(text):
    # matches a citation
    pattern = re.compile("\[[0-9]+\](.+?)\. *[0-9]{4}\.(.+?)\.", re.I)

    # match is a tuple (author list, reference title)
    matches = re.findall(pattern, text)
    
    return matches


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
        author_emails = extract_emails(author_names, page_text(0))
        authors = [{"name": n, "email": e} for (n, e) in zip(author_names, author_emails)]

        references = extract_references(text)

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
            try:
                paper = process_arxiv_search_result(res)
                success = db.insert_paper(paper)

                if not success:
                    raise RuntimeError("Failed to insert paper")
            except KeyboardInterrupt:
                break
            except:
                fail_cnt += 1
                t.set_postfix(fail_count=fail_cnt)


if __name__ == "__main__":
    search_arxiv("computer vision")