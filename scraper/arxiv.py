import requests
from bs4 import BeautifulSoup
import psycopg2
from datetime import datetime
from tqdm import tqdm


def handle_paper(paper, link):
    global id
    title = paper.select_one('.list-title.mathjax').text.strip().replace('Title: ', '')
    author = [t.text.strip() for t in paper.find_all('a')]
    response = requests.get(link)
    soup = BeautifulSoup(response.content, 'html.parser')
    abstract = soup.select_one('.abstract.mathjax').text.strip().replace('Abstract: ', '')
    
    query_paper = "INSERT INTO papers (id, title, abstract, url, inserted_at, updated_at, post_id) VALUES (%s, %s, %s, %s, %s, %s, %s)"
    query_post = "INSERT INTO posts (id, user_id, likes, inserted_at, updated_at) VALUES (%s, %s, %s, %s, %s)"
    
    now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    values = (id, 1, 0, now, now)
    curr.execute(query_post, values)
    
    values = (id, title, abstract, link, now, now, id)
    curr.execute(query_paper, values)
    id += 1

    
def handle_link(link):
    response = requests.get(url+link.get('href'))
    soup = BeautifulSoup(response.content, 'html.parser') 
    links = soup.find_all('a', string='all')
    
    response = requests.get(url+links[0].get('href'))
    soup = BeautifulSoup(response.content, 'html.parser') 
    papers = soup.find_all('dd')
    paper_links = soup.find_all('dt')
    paper_links = [l.find_all('a', title='Abstract')[0] for l in paper_links]
    
    for i in tqdm(range(len(paper_links))):
        handle_paper(papers[i], url+paper_links[i].get('href'))


conn = psycopg2.connect(
    database="amphi_dev",
    user="postgres",
    password="docker",
    host="localhost",
    port="5432"
)

curr = conn.cursor()

url = 'https://arxiv.org/'
response = requests.get(url)

soup = BeautifulSoup(response.content, 'html.parser')
links = soup.select('a[href^="/list/cs."]')
id = 0
handle_link(links[0])

conn.commit()
curr.close()
conn.close()

# print(links)
