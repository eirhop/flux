defmodule Flux.RefTest do
  use ExUnit.Case, async: true

  alias Flux.Ref

  require Logger

  test "builds a canonical ref" do
    ref = Ref.new(Example.Assets, :normalize_orders)

    Logger.debug("built ref: #{inspect(ref)}")

    assert ref == {Example.Assets, :normalize_orders}
  end
end
