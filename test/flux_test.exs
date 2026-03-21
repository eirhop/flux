defmodule FluxTest do
  use ExUnit.Case
  doctest Flux

  defmodule SampleAssets do
    use Flux.Assets

    @doc "Extract raw orders"
    @asset []
    def extract_orders, do: [%{id: 1}]

    @doc "Normalize extracted orders"
    @asset depends_on: [:extract_orders], tags: [:sales]
    def normalize_orders(orders), do: orders
  end

  test "lists assets for a module through the public facade" do
    assert {:ok, assets} = Flux.list_assets(SampleAssets)
    assert Enum.map(assets, & &1.name) == [:extract_orders, :normalize_orders]
  end

  test "fetches an asset through the public facade" do
    assert {:ok, asset} = Flux.get_asset({SampleAssets, :normalize_orders})
    assert asset.depends_on == [{SampleAssets, :extract_orders}]

    assert {:error, :asset_not_found} = Flux.get_asset({SampleAssets, :missing})
    assert {:error, :not_asset_module} = Flux.get_asset({Enum, :map})
  end
end
