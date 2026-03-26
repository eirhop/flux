defmodule Flux.PlannerTest do
  use ExUnit.Case

  alias Flux.Test.Fixtures.Assets.Graph.BronzeAssets
  alias Flux.Test.Fixtures.Assets.Graph.GoldAssets
  alias Flux.Test.Fixtures.Assets.Graph.SilverAssets

  setup do
    state = Flux.TestSetup.capture_state()

    :ok =
      Flux.TestSetup.setup_asset_modules([BronzeAssets, SilverAssets, GoldAssets],
        reload_graph?: true
      )

    on_exit(fn ->
      Flux.TestSetup.restore_state(state, reload_graph?: true)
    end)

    :ok
  end

  test "builds multi-target plans with shared dependency dedup and stage grouping" do
    assert {:ok, plan} =
             Flux.plan_run([
               {GoldAssets, :gold_sales},
               {GoldAssets, :gold_finance}
             ])

    assert Map.keys(plan.nodes) |> MapSet.new() ==
             MapSet.new([
               {BronzeAssets, :raw_customers},
               {BronzeAssets, :raw_orders},
               {SilverAssets, :monthly_customers},
               {SilverAssets, :nightly_orders},
               {GoldAssets, :gold_finance},
               {GoldAssets, :gold_sales}
             ])

    assert plan.stages == [
             [{BronzeAssets, :raw_customers}, {BronzeAssets, :raw_orders}],
             [{SilverAssets, :monthly_customers}, {SilverAssets, :nightly_orders}],
             [{GoldAssets, :gold_finance}, {GoldAssets, :gold_sales}]
           ]

    assert plan.nodes[{SilverAssets, :nightly_orders}].downstream == [
             {GoldAssets, :gold_finance},
             {GoldAssets, :gold_sales}
           ]
  end

  test "supports dependencies: :none for target-only planning" do
    assert {:ok, plan} = Flux.plan_run({GoldAssets, :gold_sales}, dependencies: :none)

    assert plan.topo_order == [{GoldAssets, :gold_sales}]
    assert plan.stages == [[{GoldAssets, :gold_sales}]]
    assert plan.nodes[{GoldAssets, :gold_sales}].upstream == []
  end

  test "returns errors for invalid planner input" do
    assert {:error, :empty_targets} = Flux.plan_run([])

    assert {:error, {:invalid_dependencies_mode, :invalid}} =
             Flux.plan_run({GoldAssets, :gold_sales}, dependencies: :invalid)

    assert {:error, :asset_not_found} = Flux.plan_run({GoldAssets, :missing})
  end

  test "normalizes duplicate targets into deterministic sorted order" do
    assert {:ok, plan} =
             Flux.plan_run([
               {GoldAssets, :gold_sales},
               {GoldAssets, :gold_finance},
               {GoldAssets, :gold_sales}
             ])

    assert plan.target_refs == [
             {GoldAssets, :gold_finance},
             {GoldAssets, :gold_sales}
           ]
  end
end
