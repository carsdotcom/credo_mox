# CredoMox

Credo Checks to ensure correct usage of the Mox library.

Provides a Credo check that ensures tests that have imported Mox and use the `Mox.expect/4` function
are verifying those expectations. See the `CredoMox.Checks.UnverifiedMox` module for more details.

## Usage

To add the `CredoMox.Checks.UnverifiedMox` check to your Credo configuration, in your `.credo.exs` file
add the `UnverifiedMox` module to your checks and configure it to only include test files:

```elixir
# ... .credo.exs
  checks: [
    ## other Credo checks...
    {CredoMox.Checks.UnverifiedMox, files: %{included: ["**/*_test.exs"]}},
  ]
```

## Installation

The package can be installed by adding `credo_mox` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:credo_mox, "~> 0.1", only: [:dev, :test], runtime: false},
  ]
end
```

Docs can be found at <https://hexdocs.pm/credo_mox>.

