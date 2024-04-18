# CredoMox

Credo Checks for the Mox library.

Provides a Credo check that ensures tests that have imported Mox and use the `expect` function
are verifying those expectations. See the `CredoMox.UnverifiedMox` module for more details.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `unverified_mox` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:unverified_mox, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/unverified_mox>.

