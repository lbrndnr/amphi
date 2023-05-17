# Amphi

To start the server, run

```
docker-compose up -d
# install and setup dependencies
mix setup
# if any outstanding migrations
mix ecto.migrate 
mix phx.server
```

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.