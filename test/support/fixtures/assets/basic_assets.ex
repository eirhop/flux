defmodule Flux.Test.Fixtures.Assets.Basic.SampleAssets do
  use Flux.Assets

  @doc "Extract raw orders"
  @asset true
  def extract_orders(_ctx, _deps), do: {:ok, %Flux.Asset.Output{output: [%{id: 1}]}}

  @doc "Normalize extracted orders"
  @asset depends_on: [:extract_orders], tags: [:sales]
  def normalize_orders(_ctx, deps),
    do: {:ok, %Flux.Asset.Output{output: Map.fetch!(deps, {__MODULE__, :extract_orders})}}
end

defmodule Flux.Test.Fixtures.Assets.Basic.CrossModuleAssets do
  use Flux.Assets

  alias Flux.Test.Fixtures.Assets.Basic.SampleAssets

  @doc "Publish normalized orders"
  @asset depends_on: [{SampleAssets, :normalize_orders}], tags: [:reporting]
  def publish_orders(_ctx, deps),
    do: {:ok, %Flux.Asset.Output{output: Map.fetch!(deps, {SampleAssets, :normalize_orders})}}
end

defmodule Flux.Test.Fixtures.Assets.Basic.SpoofedAssets do
  def __flux_assets__, do: :oops
end

defmodule Flux.Test.Fixtures.Assets.Basic.AdditionalAssets do
  use Flux.Assets

  alias Flux.Test.Fixtures.Assets.Basic.CrossModuleAssets

  @doc "Archive published orders"
  @asset depends_on: [{CrossModuleAssets, :publish_orders}]
  def archive_orders(_ctx, deps),
    do: {:ok, %Flux.Asset.Output{output: Map.fetch!(deps, {CrossModuleAssets, :publish_orders})}}
end
