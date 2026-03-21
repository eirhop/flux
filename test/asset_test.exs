defmodule Flux.AssetTest do
  use ExUnit.Case, async: true

  alias Flux.Asset
  alias Flux.Ref

  require Logger

  test "defaults optional fields" do
    asset = %Asset{
      module: Example.Assets,
      name: :normalize_orders,
      ref: Ref.new(Example.Assets, :normalize_orders),
      arity: 1,
      file: "lib/example/assets.ex",
      line: 12
    }

    Logger.debug("default asset metadata: #{inspect(asset, pretty: true)}")

    assert asset.kind == :materialized
    assert asset.tags == []
    assert asset.depends_on == []
    assert asset.doc == nil
  end

  test "stores the canonical metadata shape" do
    asset = %Asset{
      module: Example.Assets,
      name: :fact_sales,
      ref: Ref.new(Example.Assets, :fact_sales),
      arity: 1,
      doc: "Builds the sales fact table",
      file: "lib/example/assets.ex",
      line: 27,
      kind: :view,
      tags: [:warehouse, "finance"],
      depends_on: [Ref.new(Example.Assets, :normalize_orders)]
    }

    Logger.debug("canonical asset metadata: #{inspect(asset, pretty: true)}")

    assert asset.module == Example.Assets
    assert asset.name == :fact_sales
    assert asset.ref == {Example.Assets, :fact_sales}
    assert asset.arity == 1
    assert asset.doc == "Builds the sales fact table"
    assert asset.file == "lib/example/assets.ex"
    assert asset.line == 27
    assert asset.kind == :view
    assert asset.tags == [:warehouse, "finance"]
    assert asset.depends_on == [{Example.Assets, :normalize_orders}]
  end
end
