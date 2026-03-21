defmodule Flux.Asset do
  @moduledoc """
  Canonical asset metadata captured from an authored Flux asset.

  `Flux.Asset` is the normalized shape used by the rest of Flux for
  introspection, dependency resolution, and execution planning.
  """

  alias Flux.Ref

  @typedoc """
  Supported asset kinds.

  These kinds describe how an asset should be treated by the runtime.
  """
  @type kind :: :materialized | :view | :ephemeral

  @typedoc """
  Tag attached to an asset.
  """
  @type tag :: atom() | String.t()

  @type t :: %__MODULE__{
          module: module(),
          name: atom(),
          ref: Ref.t(),
          arity: non_neg_integer(),
          doc: String.t() | nil,
          file: String.t(),
          line: pos_integer(),
          kind: kind(),
          tags: [tag()],
          depends_on: [Ref.t()]
        }

  defstruct [
    :module,
    :name,
    :ref,
    :arity,
    :doc,
    :file,
    :line,
    kind: :materialized,
    tags: [],
    depends_on: []
  ]
end
