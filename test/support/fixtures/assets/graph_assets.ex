defmodule Flux.Test.Fixtures.Assets.Graph.SourceAssets do
  use Flux.Assets

  @doc "Raw orders"
  @asset true
  def raw_orders(_ctx, _deps), do: {:ok, %Flux.Asset.Output{output: [%{id: 1}]}}

  @doc "Raw customers"
  @asset true
  def raw_customers(_ctx, _deps), do: {:ok, %Flux.Asset.Output{output: [%{id: 1}]}}
end

defmodule Flux.Test.Fixtures.Assets.Graph.WarehouseAssets do
  use Flux.Assets

  alias Flux.Test.Fixtures.Assets.Graph.SourceAssets

  @doc "Normalize orders"
  @asset depends_on: [{SourceAssets, :raw_orders}], tags: [:warehouse]
  def normalize_orders(_ctx, deps),
    do: {:ok, %Flux.Asset.Output{output: Map.fetch!(deps, {SourceAssets, :raw_orders})}}

  @doc "Normalize customers"
  @asset depends_on: [{SourceAssets, :raw_customers}], tags: [:warehouse]
  def normalize_customers(_ctx, deps),
    do: {:ok, %Flux.Asset.Output{output: Map.fetch!(deps, {SourceAssets, :raw_customers})}}

  @doc "Build sales fact"
  @asset depends_on: [:normalize_orders, :normalize_customers], tags: [:finance]
  def fact_sales(_ctx, deps) do
    {:ok,
     %Flux.Asset.Output{
       output:
         {Map.fetch!(deps, {__MODULE__, :normalize_orders}),
          Map.fetch!(deps, {__MODULE__, :normalize_customers})}
     }}
  end
end

defmodule Flux.Test.Fixtures.Assets.Graph.ReportingAssets do
  use Flux.Assets

  alias Flux.Test.Fixtures.Assets.Graph.WarehouseAssets

  @doc "Build dashboard"
  @asset depends_on: [{WarehouseAssets, :fact_sales}, {WarehouseAssets, :normalize_orders}]
  def dashboard(_ctx, deps) do
    {:ok,
     %Flux.Asset.Output{
       output:
         {Map.fetch!(deps, {WarehouseAssets, :fact_sales}),
          Map.fetch!(deps, {WarehouseAssets, :normalize_orders})}
     }}
  end
end

defmodule Flux.Test.Fixtures.Assets.Graph.BronzeAssets do
  use Flux.Assets

  @asset true
  def raw_orders(_ctx, _deps), do: {:ok, %Flux.Asset.Output{output: :ok}}

  @asset true
  def raw_customers(_ctx, _deps), do: {:ok, %Flux.Asset.Output{output: :ok}}
end

defmodule Flux.Test.Fixtures.Assets.Graph.SilverAssets do
  use Flux.Assets

  alias Flux.Test.Fixtures.Assets.Graph.BronzeAssets

  @asset depends_on: [{BronzeAssets, :raw_orders}]
  def nightly_orders(_ctx, _deps), do: {:ok, %Flux.Asset.Output{output: :ok}}

  @asset depends_on: [{BronzeAssets, :raw_customers}]
  def monthly_customers(_ctx, _deps), do: {:ok, %Flux.Asset.Output{output: :ok}}
end

defmodule Flux.Test.Fixtures.Assets.Graph.GoldAssets do
  use Flux.Assets

  alias Flux.Test.Fixtures.Assets.Graph.SilverAssets

  @asset depends_on: [{SilverAssets, :nightly_orders}, {SilverAssets, :monthly_customers}]
  def gold_sales(_ctx, _deps), do: {:ok, %Flux.Asset.Output{output: :ok}}

  @asset depends_on: [{SilverAssets, :nightly_orders}]
  def gold_finance(_ctx, _deps), do: {:ok, %Flux.Asset.Output{output: :ok}}
end
