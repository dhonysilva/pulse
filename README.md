# Pulse

Application created during the process of learning how to Streaming OpenAI in Elixir and Phoenix.


## Learn more
I walked through this tutorial's series by [Ben Reinhart](https://benreinhart.com/blog/openai-streaming-elixir-phoenix/) following each step to build this project.


Typed below the sequence tutorial's parts:

- [Part 01](url)
- [Part 02](url)
- [Part 03](url)

In other to develop this project, you will need to create an OpenAI account and get your API key.

I'm storing my API key in a `.env` file in the root of the project. You can create your own `.env` file and add the following content:

```bash
OPENAI_API_KEY="your-openai-key"
```

Add the following dependencies to your `mix.exs` file:

```elixir
{:dotenv_parser, "~> 2.0"},
```

And these instructions to your `runtime.exs`:

```elixir
if config_env() == :dev do
  DotenvParser.load_file(".env")
end
```

```elixir
config :pulse, :openai, api_key: System.fetch_env!("OPENAI_API_KEY")
```


### Setting up the project
To start this Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

### Working with data

```
{:ok, %{body: response}} = Pulse.Openai.chat_completion(%{ model: "gpt-3.5-turbo", messages: [%{role: "user", content: "Hello 3.5!"}] })
```

```
{:ok, %{body: response}} =

Pulse.Openai.chat_completion(
  %{
    model: "gpt-3.5-turbo",
    messages: [%{role: "user", content: "Hello 3.5!"}]
  },
  &IO.puts/1
)
```

### Dealing with building artifacts problems

Sometimes there's some incompatibilies with the files on `_build` folder. In this case, proceed with one of the steps below.

Clear and recompile modules with:

```bash
mix compile --force
```

Clear build artifacts and compile:

```bash
rm -rf _build
mix deps.compile
mix compile
```
