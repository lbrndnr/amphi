# Amphi

To start the server, run

```
# install and setup dependencies
mix setup
# run postgres docker
docker run --rm --name amphi-pg -d -p 5432:5432 -e POSTGRES_PASSWORD=docker -v $HOME/Documents/Docker/postgres:/var/lib/postgresql/data postgres
# to run splash (headless browser)
docker run --rm --name amphi-splash -d -p 8050:8050 scrapinghub/splash --max-timeout 300
# if any outstanding migrations
mix ecto.migrate 
mix phx.server
```

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.