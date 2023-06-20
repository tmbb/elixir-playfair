defmodule Playfair.Plot2D.XYAxis do
  alias Playfair.TickManagers.AutoTickManager
  alias Playfair.Typst
  alias Playfair.Config

  alias Playfair.Scales.LinearScale
  import Playfair.Length, only: [sigil_L: 2]

  alias __MODULE__

  defstruct name: nil,
            label: nil,
            label_alignment: :center,
            label_location: :center,
            label_inner_padding: ~L[10pt],
            label_outer_padding: ~L[4pt],
            location: :bottom,
            direction: :none,
            min_value: nil,
            max_value: nil,
            min_value_set_by_user: false,
            max_value_set_by_user: false,
            major_tick_locations: nil,
            major_tick_labels: nil,
            major_tick_size: ~L[7pt],
            start_padding: ~L[0pt],
            start_margin: ~L[0pt],
            end_padding: ~L[0pt],
            end_margin: ~L[0pt],
            spine: true,
            frozen: false,
            scale: LinearScale.init(),
            major_tick_manager: AutoTickManager.init()

  def new(args) do
    struct(__MODULE__, args)
  end

  def apply_scale(%XYAxis{} = axis, value) do
    {scale_module, scale_opts} = axis.scale
    scale_module.scale(value, axis.min_value, axis.max_value, scale_opts)
  end

  def apply_scale_to_many(%XYAxis{} = axis, values) do
    # Save some map lookups (TODO: test whether this is worth it)
    {scale_module, scale_opts} = axis.scale
    min_value = axis.min_value
    max_value = axis.max_value

    Enum.map(values, fn value ->
      scale_module.scale(value, min_value, max_value, scale_opts)
    end)
  end

  def add_ticks(%XYAxis{major_tick_locations: nil} = axis) do
    # The ticks haven't been set already
    {major_tick_manager, options} = axis.major_tick_manager
    apply(major_tick_manager, :add_major_ticks, [axis, options])
  end

  def add_ticks(%XYAxis{} = axis) do
    # The ticks have been set already; return the axis unchanged
    axis
  end

  def freeze(%XYAxis{} = axis) do
    major_tick_locations = axis.major_tick_locations || []
    major_tick_labels = axis.major_tick_labels || []

    # TODO: Get this from somewhere!
    label_text_attrs = []
    base_text_attrs = Config.get_major_tick_label_text_attributes()
    # Merge all attributes
    text_attrs = Keyword.merge(base_text_attrs, label_text_attrs)

    typst_major_tick_labels =
      for label <- major_tick_labels do
        # Apply the options to the label
        Typst.text(label, text_attrs)
      end

    %{axis |
        frozen: true,
        major_tick_locations: major_tick_locations,
        major_tick_labels: typst_major_tick_labels}
  end

  def maybe_update_min_value(%XYAxis{min_value: nil} = axis, new_candidate) do
    %{axis | min_value: new_candidate}
  end

  def maybe_update_min_value(%XYAxis{} = axis, new_candidate) do
    %{axis | min_value: min(axis.min_value, new_candidate)}
  end

  def maybe_update_max_value(%XYAxis{max_value: nil} = axis, new_candidate) do
    %{axis | max_value: new_candidate}
  end

  def maybe_update_max_value(%XYAxis{} = axis, new_candidate) do
    %{axis | max_value: max(axis.max_value, new_candidate)}
  end

  def put_min_value(%XYAxis{} = axis, new_value) do
    %{axis | min_value: new_value}
  end

  def put_max_value(%XYAxis{} = axis, new_value) do
    %{axis | max_value: new_value}
  end

  def put_min_value_if_not_set(%XYAxis{} = axis, new_value) do
    case axis.min_value do
      nil -> put_min_value(axis, new_value)
      _other -> axis
    end
  end

  def put_max_value_if_not_set(%XYAxis{} = axis, new_value) do
    case axis.max_value do
      nil -> put_max_value(axis, new_value)
      _other -> axis
    end
  end

  def put_major_tick_labels(%XYAxis{} = axis, labels) do
    %{axis | major_tick_labels: labels}
  end

  def put_major_tick_locations(%XYAxis{} = axis, locations) do
    %{axis | major_tick_locations: locations}
  end

  def put_label(%XYAxis{} = axis, label, opts \\ []) do
    typst_label =
      if is_binary(label) do
        label_text_attrs = Keyword.get(opts, :text, [])
        base_text_attrs = Config.get_axis_label_text_attributes()
        # Merge all attributes
        text_attrs = Keyword.merge(base_text_attrs, label_text_attrs)
        # Apply the options to the label
        Typst.text(label, text_attrs)
      else
        label
      end

    %{axis | label: typst_label}
  end

  def to_typst(%__MODULE__{} = axis) do
    axis_subset = Map.drop(axis, [
      :__struct__,
      :scale,
      :major_tick_manager,
      :max_value,
      :min_value,
      :frozen,
      :max_value_set_by_user,
      :min_value_set_by_user
    ])

    Typst.function_call(
      Typst.variable("XY-Axis"),
      Typst.map_to_kw_args(axis_subset)
    )
  end
end
