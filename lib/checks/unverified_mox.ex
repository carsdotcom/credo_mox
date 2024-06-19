if Code.ensure_loaded?(Credo.Check) do
  defmodule CredoMox.Checks.UnverifiedMox do
    @moduledoc """
    #{__MODULE__} looks for test files that import Mox and use
    the `expect/4` function, but do not enforce any assertions that
    the expectations have been called or not either by running `verify_on_exit`
    from a setup block or calling `verify!/0` or `verify!/1` inline
    in a test block.
    """

    @message """
    Credo found a test file that imports Mox and uses expect/4, but no verifications were found, which means the test will never fail if the function isn't called.
    You can verify expectations in one of two ways. The most common is to add:
        setup :verify_on_exit!
    at the top level of your test file. Alternatively, you can explicitly call verify!/0 or verify!/1 in each test that uses expect/4.
    """

    @exit_status 32
    # Set up the behaviour and make this module a "check":
    use Credo.Check,
      base_priority: :high,
      category: :warning,
      param_defaults: [],
      explanations: [
        check: """
        Ensures that Mox expectations are always verified. Without either setting up
        `:verify_on_exit!` or manually calling `verify!` after your expectations, calls to
        `Mox.expect/4` within your test will never fail, so the test will pass regardless
        of whether your expected function was called.
        """,
        params: []
      ],
      exit_status: @exit_status

    @doc """
    Inspects test files for the use of `Mox.expect/4` where the expectations being made are unverified.

    If unverified expectations are found, this check will flag the test file as an issue.
    The offending file will be displayed in the resulting issue when running `mix credo --strict`,
    and the line number indicated in the issue will point to the first use of `expect` in that file
    where the expectation has not been verified.
    """
    @impl Credo.Check
    def run(source_file, params \\ []) do
      issue_meta = IssueMeta.for(source_file, params)

      walked_directives =
        source_file
        |> Credo.Code.ast()
        |> then(fn {:ok, ast} -> Macro.postwalker(ast) end)

      module_directives =
        for directive <- walked_directives,
            match?({:defmodule, _, [{_, _, [_]} | _]}, directive),
            do: directive

      Enum.reduce(module_directives, [], fn module, issues_per_file ->
        module
        |> Macro.postwalker()
        |> issues_per_module(issue_meta)
        |> Enum.concat(issues_per_file)
      end)
    end

    defp issues_per_module(module_ast, issue_meta) do
      with true <-
             Enum.any?(module_ast, fn ast_node ->
               match?({:import, _, [{_, _, [:Mox]}]}, ast_node)
             end),
           {:expect, context, _} <-
             find_unverified_expect(module_ast),
           false <-
             Enum.any?(module_ast, &setup_contains_verify_on_exit?/1) do
        [issue_for("Missing verify_on_exit!", context, issue_meta)]
      else
        _ -> []
      end
    end

    defp find_unverified_expect(walked_directives) do
      Enum.find_value(walked_directives, fn ast_node ->
        with test_block when not is_nil(test_block) <- find_test_body(ast_node),
             {:expect, _context, _} = expect_tuple <-
               Enum.find(test_block, &match?({:expect, _, _}, &1)),
             false <- Enum.any?(test_block, &match?({:verify!, _, _}, &1)) do
          expect_tuple
        else
          _ -> false
        end
      end)
    end

    defp find_test_body(ast_node) do
      case ast_node do
        # multiline test without context
        {:test, _, [_, [do: {:__block__, _context, test_body}]]} ->
          test_body

        # multiline test with context
        {:test, _, [_, _, [do: {:__block__, _context, test_body}]]} ->
          test_body

        # singleline test without context
        {:test, _, [_, [do: {:expect, _, _} = test_body]]} ->
          [test_body]

        # singleline test with context
        {:test, _, [_, _, [do: {:expect, _, _} = test_body]]} ->
          [test_body]

        _ ->
          nil
      end
    end

    defp setup_contains_verify_on_exit?({:setup, _context, [:verify_on_exit!]}), do: true

    defp setup_contains_verify_on_exit?({:setup, _context, [[do: block_ast]]}) do
      Enum.any?(Macro.prewalker(block_ast), fn node ->
        match?({:verify_on_exit!, _, _}, node)
      end)
    end

    defp setup_contains_verify_on_exit?({:setup, _context, [_, [do: block_ast]]}) do
      Enum.any?(Macro.postwalker(block_ast), fn node ->
        match?({:verify_on_exit!, _, _}, node)
      end)
    end

    defp setup_contains_verify_on_exit?({:setup, _context, [arguments]})
         when is_list(arguments) do
      Enum.member?(arguments, :verify_on_exit!)
    end

    defp setup_contains_verify_on_exit?(_), do: false

    defp issue_for(name, context, issues_meta) do
      format_issue(
        issues_meta,
        message: @message,
        trigger: name,
        line_no: context[:line]
      )
    end
  end
end
