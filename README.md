# CredoMox

Credo Checks for the Mox library.

Provides a Credo check that ensures tests that have imported Mox and use the `expect` function
are verifying those expectations. See the `CredoMox.UnverifiedMox` module for more details.

## Usage

To add the `CredoMox.Checks.UnverifiedMox` check to your Credo configuration, in your `.credo.exs` file
add the `UnverifiedMox` module to your checks and configure it to only include test files:

```elixir
# ... .credo.exs
  checks: [
    ## other Credo checks...
    {CredoMox.Checks.UnverifiedMocks, files: %{included: ["**/*_test.exs"]}},
  ]
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `credo_mox` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:credo_mox, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/unverified_mox>.

