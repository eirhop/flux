defmodule Flux.RefTest do
  use ExUnit.Case, async: true

  alias Flux.Ref

  test "builds a canonical ref" do
    assert Ref.new(Example.Assets, :normalize_orders) ==
             {Example.Assets, :normalize_orders}
  end
end
