defmodule Favn.Asset.Output do
  @moduledoc """
  Canonical success envelope returned by Favn assets.

  Assets should return one of:

    * `{:ok, %Favn.Asset.Output{}}`
    * `{:error, reason}`
  """

  @enforce_keys [:output]
  defstruct output: nil, meta: %{}

  @type t :: %__MODULE__{
          output: term(),
          meta: map()
        }
end
