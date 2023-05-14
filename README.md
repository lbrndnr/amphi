# Amphi

To start the server, run

```
mix setup # to install and setup dependencies
docker run --rm --name amphi-pg -d -p 5432:5432 -e POSTGRES_PASSWORD=docker -v $HOME/Documents/Docker/postgres:/var/lib/postgresql/data postgres # to run postgres docker
amphi % docker run --rm --name amphi-mongodb -d -p 27017:27017 -e MONGO_INITDB_ROOT_USERNAME=amphi -e MONGO_INITDB_ROOT_PASSWORD=amphi -v $HOME/Documents/Docker/mongodb:/data/db mongo # to run mongodb docker
docker run --rm --name amphi-splash -d -p 8050:8050 scrapinghub/splash --max-timeout 300 # to run splash (headless browser)
mix ecto.migrate # if any outstanding migrations
mix phx.server
```

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.