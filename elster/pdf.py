import re
import numpy as np
import jellyfish as jf

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