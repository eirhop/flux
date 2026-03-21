defmodule Flux.Assets do
  @moduledoc """
  Compile-time DSL for authoring Flux assets inside a module.

  `use Flux.Assets` lets a module mark public functions with `@asset` so Flux
  can capture canonical `%Flux.Asset{}` metadata for later introspection.
  """

  alias Flux.Asset
  alias Flux.Ref

  @type asset_error :: :not_asset_module | :asset_not_found

  @doc false
  defmacro __using__(_opts) do
    quote do
      Module.register_attribute(__MODULE__, :asset, persist: false)
      Module.register_attribute(__MODULE__, :flux_assets_raw, accumulate: true)

      @on_definition Flux.Assets
      @before_compile Flux.Assets
    end
  end

  @doc false
  def __on_definition__(env, kind, name, args, _guards, _body) do
    asset_opts = Module.get_attribute(env.module, :asset)

    if asset_opts != nil do
      Module.delete_attribute(env.module, :asset)

      case kind do
        :def ->
          arity = length(args || [])

          if not already_recorded?(env.module, name, arity) do
            raw_asset = %{
              module: env.module,
              name: name,
              arity: arity,
              doc: normalize_doc(Module.get_attribute(env.module, :doc)),
              file: normalize_file(env.file),
              line: env.line,
              opts: asset_opts || []
            }

            Module.put_attribute(env.module, :flux_assets_raw, raw_asset)
          end

        :defp ->
          compile_error!(env.file, env.line, "@asset can only be used on public functions")
      end
    end
  end

  @doc false
  defmacro __before_compile__(env) do
    case Module.get_attribute(env.module, :asset) do
      nil ->
        :ok

      _ ->
        compile_error!(
          env.file,
          env.line,
          "@asset must be followed by a public function definition"
        )
    end

    assets =
      env.module
      |> Module.get_attribute(:flux_assets_raw)
      |> Enum.reverse()
      |> validate_unique_names!(env.file)
      |> Enum.map(&build_asset!/1)

    quote do
      @doc false
      @spec __flux_asset_module__() :: true
      def __flux_asset_module__, do: true

      @doc false
      @spec __flux_assets__() :: [Flux.Asset.t()]
      def __flux_assets__, do: unquote(Macro.escape(assets))

      @doc false
      @spec __flux_asset__(atom()) :: Flux.Asset.t() | nil
      def __flux_asset__(name) when is_atom(name) do
        Enum.find(unquote(Macro.escape(assets)), &(&1.name == name))
      end
    end
  end

  @doc """
  Return whether the module exposes Flux asset introspection.
  """
  @spec asset_module?(module()) :: boolean()
  def asset_module?(module) when is_atom(module) do
    function_exported?(module, :__flux_asset_module__, 0) and
      module.__flux_asset_module__() == true
  end

  @doc """
  List all assets defined by a Flux asset module.
  """
  @spec list_assets(module()) :: {:ok, [Asset.t()]} | {:error, asset_error()}
  def list_assets(module) when is_atom(module) do
    if asset_module?(module) do
      {:ok, module.__flux_assets__()}
    else
      {:error, :not_asset_module}
    end
  end

  @doc """
  Fetch one asset from a Flux asset module.
  """
  @spec get_asset(module(), atom()) :: {:ok, Asset.t()} | {:error, asset_error()}
  def get_asset(module, name) when is_atom(module) and is_atom(name) do
    with true <- asset_module?(module),
         %Asset{} = asset <- module.__flux_asset__(name) do
      {:ok, asset}
    else
      false -> {:error, :not_asset_module}
      nil -> {:error, :asset_not_found}
    end
  end

  defp already_recorded?(module, name, arity) do
    module
    |> Module.get_attribute(:flux_assets_raw)
    |> Enum.any?(fn asset -> asset.name == name and asset.arity == arity end)
  end

  defp validate_unique_names!(raw_assets, file) do
    raw_assets
    |> Enum.group_by(& &1.name)
    |> Enum.each(fn {name, assets} ->
      case assets do
        [_single] ->
          :ok

        [first | _rest] ->
          compile_error!(
            file,
            first.line,
            "duplicate asset name #{inspect(name)}; asset names must be unique within a module"
          )
      end
    end)

    raw_assets
  end

  defp build_asset!(raw_asset) do
    opts = normalize_opts!(raw_asset)

    %Asset{
      module: raw_asset.module,
      name: raw_asset.name,
      ref: Ref.new(raw_asset.module, raw_asset.name),
      arity: raw_asset.arity,
      doc: raw_asset.doc,
      file: raw_asset.file,
      line: raw_asset.line,
      kind: opts.kind,
      tags: opts.tags,
      depends_on: opts.depends_on
    }
  end

  defp normalize_opts!(raw_asset) do
    opts = normalize_asset_opts!(raw_asset.opts, raw_asset)

    kind = Keyword.get(opts, :kind, :materialized)
    tags = Keyword.get(opts, :tags, [])
    depends_on = Keyword.get(opts, :depends_on, [])

    validate_kind!(kind, raw_asset)
    validate_tags!(tags, raw_asset)

    %{kind: kind, tags: tags, depends_on: normalize_depends_on!(depends_on, raw_asset)}
  end

  defp validate_kind!(kind, raw_asset) do
    if kind in Asset.valid_kinds() do
      :ok
    else
      compile_error!(raw_asset.file, raw_asset.line, "invalid asset kind #{inspect(kind)}")
    end
  end

  defp validate_tags!(tags, raw_asset) when is_list(tags) do
    Enum.each(tags, fn
      tag when is_atom(tag) or is_binary(tag) ->
        :ok

      tag ->
        compile_error!(
          raw_asset.file,
          raw_asset.line,
          "asset tags must be atoms or strings, got: #{inspect(tag)}"
        )
    end)
  end

  defp validate_tags!(tags, raw_asset) do
    compile_error!(
      raw_asset.file,
      raw_asset.line,
      "asset tags must be a list of atoms or strings, got: #{inspect(tags)}"
    )
  end

  defp normalize_depends_on!(depends_on, raw_asset) when is_list(depends_on) do
    Enum.map(depends_on, fn
      name when is_atom(name) ->
        Ref.new(raw_asset.module, name)

      {module, name} when is_atom(module) and is_atom(name) ->
        Ref.new(module, name)

      dependency ->
        compile_error!(
          raw_asset.file,
          raw_asset.line,
          "invalid depends_on entry #{inspect(dependency)}; expected an asset name or {module, name}"
        )
    end)
  end

  defp normalize_depends_on!(depends_on, raw_asset) do
    compile_error!(
      raw_asset.file,
      raw_asset.line,
      "asset depends_on must be a list, got: #{inspect(depends_on)}"
    )
  end

  defp normalize_doc({_line, false}), do: nil
  defp normalize_doc({_line, doc}) when is_binary(doc), do: doc
  defp normalize_doc(false), do: nil
  defp normalize_doc(doc) when is_binary(doc), do: doc
  defp normalize_doc(_), do: nil

  defp normalize_asset_opts!(nil, _raw_asset), do: []
  defp normalize_asset_opts!(true, _raw_asset), do: []

  defp normalize_asset_opts!(opts, raw_asset) when is_list(opts) do
    if Keyword.keyword?(opts) do
      opts
    else
      compile_error!(
        raw_asset.file,
        raw_asset.line,
        "@asset options must be a keyword list, got: #{inspect(opts)}"
      )
    end
  end

  defp normalize_asset_opts!(opts, raw_asset) do
    compile_error!(
      raw_asset.file,
      raw_asset.line,
      "@asset options must be a keyword list, got: #{inspect(opts)}"
    )
  end

  defp normalize_file(file) do
    file
    |> to_string()
    |> Path.relative_to_cwd()
  end

  defp compile_error!(file, line, description) do
    raise CompileError, file: file, line: line, description: description
  end
end
