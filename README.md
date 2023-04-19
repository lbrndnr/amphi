# Amphi

To start the server, run

```
mix setup # to install and setup dependencies
docker run --rm --name pg-docker -e POSTGRES_PASSWORD=docker -d -p 5432:5432 -v $HOME/Documents/Docker/postgres:/var/lib/postgresql/data postgres # to run postgres docker
docker run -it -p 8050:8050 scrapinghub/splash --max-timeout 300 # to run splash (headless browser)
mix ecto.migrate # if any outstanding migrations
mix phx.server
```

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.