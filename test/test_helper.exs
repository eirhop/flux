Code.require_file("support/fixtures/assets/basic_assets.ex", __DIR__)
Code.require_file("support/fixtures/assets/graph_assets.ex", __DIR__)
Code.require_file("support/fixtures/assets/runner_assets.ex", __DIR__)
Code.require_file("support/flux_test_setup.ex", __DIR__)

trace? = "--trace" in System.argv()

ExUnit.start(capture_log: !trace?)
Logger.configure(level: if(trace?, do: :debug, else: :warning))
