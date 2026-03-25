defmodule Flux.Asset.Output do
  @moduledoc """
  Canonical success envelope returned by Flux assets.

  Assets should return one of:

    * `{:ok, %Flux.Asset.Output{}}`
    * `{:error, reason}`
  """

  @enforce_keys [:output]
  defstruct output: nil, meta: %{}

  @type t :: %__MODULE__{
          output: term(),
          meta: map()
        }
end
