defmodule AmphiWeb.SearchController do
  use AmphiWeb, :controller
  # use Floki

  def index(conn, command) do
    api_key = "0219851630701e8bf03ad9fd44d1378b"

    if is_map(command) and Map.has_key?(command, "search_query") do
      IO.inspect(command)
      query = command["search_query"]
      search_query = query
      url = "https://api.scraperapi.com/?api_key=#{api_key}&url=https://scholar.google.com/scholar?q=#{URI.encode(search_query)}"
      # response = HTTPoison.get(url, [], timeout: 10000, recv_timeout: :infinity)
      response = {:ok, %HTTPoison.Response{status_code: 200, body: File.read("output.txt") |> elem(1)}}

      case response do
        {:error, %HTTPoison.Error{reason: reason}} ->
          # Handle the error
          IO.puts("Error: #{reason}")
          render(conn, :index, results: [])

        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
            html_body = body
            elements = html_body |> Floki.find("div.gs_r.gs_or.gs_scl") |> Floki.find("h3") |> Floki.find("a")

            names = Enum.map(elements, fn x -> x |> elem(2) end)
            links = Enum.map(elements, fn x -> x |> elem(1) |> Enum.at(1) |> elem(1) end)
            names = names |> Enum.map(fn x -> Enum.map(x, fn
                {"b", _, a} -> a |> Enum.at(0)
                x -> x
              end)|> Enum.join("") end)

            results = Enum.zip(names, links) |> Enum.map(fn {x, y} -> %{name: x, link: y} end)

            render(conn, :index, results: results)
      end
    end
    render(conn, :index, results: [])


  end

end
