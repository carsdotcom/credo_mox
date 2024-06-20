defmodule CredoMox.Checks.UnverifiedMoxTest do
  use Credo.Test.Case

  alias CredoMox.Checks.UnverifiedMox

  describe "UnverifiedMox Check" do
    test "does NOT warn when a mock is verified" do
      """
      defmodule CredoSampleModuleTest do
        import Mox
        setup :verify_on_exit!
        describe "something" do
          test "the thing" do
            expect MockModule, :function, fn -> :foo end
          end
        end
      end
      """
      |> to_source_file()
      |> run_check(UnverifiedMox)
      |> refute_issues()
    end

    test "warns about test files without verify_on_exit if `expect` is present " do
      """
      defmodule CredoSampleModuleTest do
        import Mox
        describe "something" do
          test "the thing" do
            expect MockModule, :function, fn -> :foo end
            expect MockModule, :function, fn -> :foo end
            expect MockModule, :function, fn -> :foo end
          end
        end
      end
      """
      |> to_source_file()
      |> run_check(UnverifiedMox)
      |> assert_issue(fn issue -> assert issue.trigger == "Missing verify_on_exit!" end)
    end

    test "warns about modules with nested names missing verify_on_exit" do
      """
      defmodule MyApp.MyContext.MyModuleTest do
        import Mox

        test "this one's fine" do
          assert 1 + 1 == 2
        end

        describe "more stuff that's fine" do
          test "math works" do
            assert 1 + 1 == 2
          end
        end

        describe "something" do
          test "the thing" do
            expect MockModule, :function, fn -> :foo end
          end
        end
      end
      """
      |> to_source_file()
      |> run_check(UnverifiedMox)
      |> assert_issue(fn issue -> assert issue.trigger == "Missing verify_on_exit!" end)
    end

    test "does not warn about test files with verify_on_exit! inside of a setup list" do
      """
      defmodule CredoSampleModuleTest do
        import Mox
        setup [:set_mox_from_context, :verify_on_exit!]

        describe "something" do
          test "the thing" do
            expect MockModule, :function, fn -> :foo end
            expect MockModule, :function, fn -> :foo end
            expect MockModule, :function, fn -> :foo end
          end
        end
      end
      """
      |> to_source_file()
      |> run_check(UnverifiedMox)
      |> refute_issues()
    end

    test "does not warn about test files with verify_on_exit! inside of a setup block that takes a context" do
      """
      defmodule CredoSampleModuleTest do
        import Mox

        setup context do
          _ = my_function(context)

          _ = verify_on_exit!(context)

          {:ok, data: 1}
        end

        describe "something" do
          test "the thing" do
            expect MockModule, :function, fn -> :foo end
          end
        end
      end
      """
      |> to_source_file()
      |> run_check(UnverifiedMox)
      |> refute_issues()
    end

    test "does not warn about test files with verify_on_exit! inside of a setup block that doesn't take a context" do
      """
      defmodule CredoSampleModuleTest do
        import Mox

        setup do
          _ = my_function()

          _ = verify_on_exit!()

          {:ok, data: 1}
        end

        describe "something" do
          test "the thing" do
            expect MockModule, :function, fn -> :foo end
          end
        end
      end
      """
      |> to_source_file()
      |> run_check(UnverifiedMox)
      |> refute_issues()
    end

    test "does not warn about test files without verify_on_exit if no `expect` call is present" do
      """
      defmodule CredoSampleModuleTest do
        import Mox
        describe "something" do
          test "the thing" do
          end
        end
      end
      """
      |> to_source_file()
      |> run_check(UnverifiedMox)
      |> refute_issues()
    end

    test "does not warn about tests with an `expect` call if the test itself calls verify!/0" do
      """
      defmodule CredoSampleModuleTest do
        import Mox
        describe "something" do
          test "the thing" do
            expect MockModule, :function, fn -> :foo end
            verify!()
          end
        end
      end
      """
      |> to_source_file()
      |> run_check(UnverifiedMox)
      |> refute_issues()
    end

    test "does not warn about tests with an `expect` call if the test itself calls verify!/1" do
      """
      defmodule CredoSampleModuleTest do
        import Mox
        describe "something" do
          test "the thing" do
            expect MockModule, :function, fn -> :foo end
            verify!(MockModule)
          end
        end
      end
      """
      |> to_source_file()
      |> run_check(UnverifiedMox)
      |> refute_issues()
    end

    test "warns about tests with an `expect` call but no call to `verify` when the test has context" do
      """
      defmodule CredoSampleModuleTest do
        import Mox
        describe "something" do
          test "the thing", %{foo: bar} do
            "not a single line test anymore"
            expect MockModule, :function, fn -> :foo end
          end
        end
      end
      """
      |> to_source_file()
      |> run_check(UnverifiedMox)
      |> assert_issue()
    end

    test "warns about tests with an `expect` and no `verify` when the test is a single line" do
      """
      defmodule CredoSampleModuleTest do
        import Mox
        describe "something" do
          test "the thing" do
            expect MockModule, :function, fn -> :foo end
          end
        end
      end
      """
      |> to_source_file()
      |> run_check(UnverifiedMox)
      |> assert_issue()
    end

    test "warns about tests with a call to `expect` but no `verify` when the test is a single line and has context" do
      """
      defmodule CredoSampleModuleTest do
        import Mox
        describe "something" do
          test "the thing", %{foo: bar} do
            expect MockModule, :function, fn -> :foo end
          end
        end
      end
      """
      |> to_source_file()
      |> run_check(UnverifiedMox)
      |> assert_issue()
    end
  end

  test "warns about files with multiple modules where one module is missing verify_on_exit" do
    """
    defmodule CredoSampleModule1Test do
      import Mox
      setup :verify_on_exit!
      describe "something" do
        test "the thing" do
          expect MockModule, :function, fn -> :foo end
        end
      end
    end

    defmodule CredoSampleModule2Test do
      import Mox
      describe "something" do
        test "the thing" do
          expect MockModule, :function, fn -> :foo end
          expect MockModule, :function, fn -> :foo end
          expect MockModule, :function, fn -> :foo end
        end
      end
    end
    """
    |> to_source_file()
    |> run_check(UnverifiedMox)
    |> assert_issue(fn issue -> assert issue.trigger == "Missing verify_on_exit!" end)
  end
end
