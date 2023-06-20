defmodule Playfair.Config do
  defstruct text_font: nil,
            text_style: nil,
            text_weight: nil,
            text_stretch: nil,
            text_size: nil,
            text_fill: nil,
            text_ligatures: nil,
            text_discretionary_ligatures: nil,
            text_historical_ligatures: nil,
            text_number_type: nil,
            text_number_width: nil,
            text_slashed_zero: nil,
            text_fractions: nil,
            text_features: nil,
            text_escape: false,
            # Title attributes
            plot_title_font: nil,
            plot_title_style: nil,
            plot_title_weight: nil,
            plot_title_stretch: nil,
            plot_title_size: nil,
            plot_title_fill: nil,
            plot_title_ligatures: nil,
            plot_title_discretionary_ligatures: nil,
            plot_title_historical_ligatures: nil,
            plot_title_number_type: nil,
            plot_title_number_width: nil,
            plot_title_slashed_zero: nil,
            plot_title_fractions: nil,
            plot_title_features: nil,
            plot_title_escape: false,
            # Axis label attributes
            axis_label_font: nil,
            axis_label_style: nil,
            axis_label_weight: nil,
            axis_label_stretch: nil,
            axis_label_size: nil,
            axis_label_fill: nil,
            axis_label_ligatures: nil,
            axis_label_discretionary_ligatures: nil,
            axis_label_historical_ligatures: nil,
            axis_label_number_type: nil,
            axis_label_number_width: nil,
            axis_label_slashed_zero: nil,
            axis_label_fractions: nil,
            axis_label_features: nil,
            axis_label_escape: false,
            # Major tick labels
            major_tick_label_font: nil,
            major_tick_label_style: nil,
            major_tick_label_weight: nil,
            major_tick_label_stretch: nil,
            major_tick_label_size: nil,
            major_tick_label_fill: nil,
            major_tick_label_ligatures: nil,
            major_tick_label_discretionary_ligatures: nil,
            major_tick_label_historical_ligatures: nil,
            major_tick_label_number_type: nil,
            major_tick_label_number_width: nil,
            major_tick_label_slashed_zero: nil,
            major_tick_label_fractions: nil,
            major_tick_label_features: nil,
            major_tick_label_escape: false

  def with_options(attrs, fun) do
    # We'll use nil instead of a default value
    # It doesn't really make a difference, though
    old_config = Process.get(:playfair_config)
    attrs_as_map = Enum.into(attrs, %{})

    try do
      # Here we want an actual config, not nil
      base_config = get_config()
      full_config = Map.merge(base_config, attrs_as_map)
      # Stor the new config in the process dictionary
      put_config(full_config)
      # Run the actual body with the new config available
      fun.()
    after
      put_config(old_config)
    end
  end

  def get_config() do
    Process.get(:playfair_config, %__MODULE__{})
  end

  defp put_config(%__MODULE__{} =  config) do
    Process.put(:playfair_config, config)
  end

  defp put_config(nil) do
    Process.put(:playfair_config, nil)
  end

  def get_plot_title_text_attributes() do
    plot_title_text_attributes(get_config())
  end

  def get_axis_label_text_attributes() do
    axis_label_text_attributes(get_config())
  end

  def get_major_tick_label_text_attributes() do
    major_tick_label_text_attributes(get_config())
  end

  def plot_title_text_attributes(%__MODULE__{} = config) do
    get_many_with_fallbacks(config,
      font: {:plot_title_font, [:text_font]},
      style: {:plot_title_style, [:text_style]},
      weight: {:plot_title_weight, [:text_weight]},
      stretch: {:plot_title_stretch, [:text_stretch]},
      size: {:plot_title_size, [:text_size]},
      fill: {:plot_title_fill, [:text_fill]},
      ligatures: {:plot_title_ligatures, [:text_ligatures]},
      discretionary_ligatures: {:plot_title_discretionary_ligatures, [:text_discretionary_ligatures]},
      historical_ligatures: {:plot_title_historical_ligatures, [:text_historical_ligatures]},
      number_type: {:plot_title_number_type, [:text_number_type]},
      number_width: {:plot_title_number_width, [:text_number_width]},
      slashed_zero: {:plot_title_slashed_zero, [:text_slashed_zero]},
      fractions: {:plot_title_fractions, [:text_title_fractions]},
      features: {:plot_title_features, [:text_features]},
      escape: {:plot_title_escape, [:text_escape]}
    )
  end

  def axis_label_text_attributes(%__MODULE__{} = config) do
    get_many_with_fallbacks(config,
      font: {:axis_label_font, [:text_font]},
      style: {:axis_label_style, [:text_style]},
      weight: {:axis_label_weight, [:text_weight]},
      stretch: {:axis_label_stretch, [:text_stretch]},
      size: {:axis_label_size, [:text_size]},
      fill: {:axis_label_fill, [:text_fill]},
      ligatures: {:axis_label_ligatures, [:text_ligatures]},
      discretionary_ligatures: {:axis_label_discretionary_ligatures, [:text_discretionary_ligatures]},
      historical_ligatures: {:axis_label_historical_ligatures, [:text_historical_ligatures]},
      number_type: {:axis_label_number_type, [:text_number_type]},
      number_width: {:axis_label_number_width, [:text_number_width]},
      slashed_zero: {:axis_label_slashed_zero, [:text_slashed_zero]},
      fractions: {:axis_label_fractions, [:text_title_fractions]},
      features: {:axis_label_features, [:text_features]},
      escape: {:axis_label_escape, [:text_escape]}
    )
  end

  def major_tick_label_text_attributes(%__MODULE__{} = config) do
    get_many_with_fallbacks(config,
      font: {:major_tick_label_font, [:text_font]},
      style: {:major_tick_label_style, [:text_style]},
      weight: {:major_tick_label_weight, [:text_weight]},
      stretch: {:major_tick_label_stretch, [:text_stretch]},
      size: {:major_tick_label_size, [:text_size]},
      fill: {:major_tick_label_fill, [:text_fill]},
      ligatures: {:major_tick_label_ligatures, [:text_ligatures]},
      discretionary_ligatures: {:major_tick_label_discretionary_ligatures, [:text_discretionary_ligatures]},
      historical_ligatures: {:major_tick_label_historical_ligatures, [:text_historical_ligatures]},
      number_type: {:major_tick_label_number_type, [:text_number_type]},
      number_width: {:major_tick_label_number_width, [:text_number_width]},
      slashed_zero: {:major_tick_label_slashed_zero, [:text_slashed_zero]},
      fractions: {:major_tick_label_fractions, [:text_title_fractions]},
      features: {:major_tick_label_features, [:text_features]},
      escape: {:major_tick_label_escape, [:text_escape]}
    )
  end

  defp fetch_with_fallbacks(config, key, fallbacks) do
    # TODO: simplify this... Maybe with get instead of fetch?
    Enum.reduce_while(fallbacks, Map.fetch(config, key), fn new_key, current_value ->
      case current_value do
        {:ok, value} when value != nil ->
          {:halt, {:ok, value}}

        _other ->
          case Map.fetch(config, new_key) do
            {:ok, value} when value != nil ->
              {:halt, {:ok, value}}

            _other ->
              {:cont, Map.fetch(config, new_key)}
          end
      end
    end)
  end

  defp get_many_with_fallbacks(config, keys_and_fallbacks) do
    for {attr_key, {key, fallbacks}} <- keys_and_fallbacks do
      {attr_key, get_with_fallbacks(config, key, fallbacks)}
    end
  end

  defp get_with_fallbacks(config, key, fallbacks, opts \\ []) do
    default = Keyword.get(opts, :default, nil)
    case fetch_with_fallbacks(config, key, fallbacks) do
      {:ok, value} -> value
      :error -> default
    end
  end

  def example() do
    with_options([text_font: "Ubuntu"], fn ->
      get_config().text_font
      get_plot_title_text_attributes()
    end)
  end
end

defmodule Playfair.Config2 do
  defstruct axes_autolimit_mode: "data",
            axes_axisbelow: "line",
            axes_edgecolor: "black",
            axes_facecolor: "white",
            axes_formatter_limits: [-5, 6],
            axes_formatter_min_exponent: 0,
            axes_formatter_offset_threshold: 4,
            axes_formatter_use_locale: false,
            axes_formatter_use_mathtext: false,
            axes_formatter_useoffset: true,
            axes_grid: false,
            axes_grid_axis: "both",
            axes_grid_which: "major",
            axes_labelcolor: "black",
            axes_labelpad: 4.0,
            axes_labelsize: "medium",
            axes_labelweight: "normal",
            axes_linewidth: 0.8,
            axes_prop_cycle:
              {:cycler, "color",
               [
                 "#1f77b4",
                 "#ff7f0e",
                 "#2ca02c",
                 "#d62728",
                 "#9467bd",
                 "#8c564b",
                 "#e377c2",
                 "#7f7f7f",
                 "#bcbd22",
                 "#17becf"
               ]},
            axes_spines_bottom: true,
            axes_spines_left: true,
            axes_spines_right: true,
            axes_spines_top: true,
            axes_titlecolor: :auto,
            axes_titlelocation: "center",
            axes_titlepad: 6.0,
            axes_titlesize: "large",
            axes_titleweight: "normal",
            axes_titley: None,
            axes_unicode_minus: true,
            axes_xmargin: 0.05,
            axes_ymargin: 0.05,
            axes_zmargin: 0.05,
            axes3d_grid: true,
            boxplot_bootstrap: None,
            boxplot_boxprops_color: "black",
            boxplot_boxprops_linestyle: "-",
            boxplot_boxprops_linewidth: 1.0,
            boxplot_capprops_color: "black",
            boxplot_capprops_linestyle: "-",
            boxplot_capprops_linewidth: 1.0,
            boxplot_flierprops_color: "black",
            boxplot_flierprops_linestyle: nil,
            boxplot_flierprops_linewidth: 1.0,
            boxplot_flierprops_marker: "o",
            boxplot_flierprops_markeredgecolor: "black",
            boxplot_flierprops_markeredgewidth: 1.0,
            boxplot_flierprops_markerfacecolor: nil,
            boxplot_flierprops_markersize: 6.0,
            boxplot_meanline: false,
            boxplot_meanprops_color: "C2",
            boxplot_meanprops_linestyle: "--",
            boxplot_meanprops_linewidth: 1.0,
            boxplot_meanprops_marker: "^",
            boxplot_meanprops_markeredgecolor: "C2",
            boxplot_meanprops_markerfacecolor: "C2",
            boxplot_meanprops_markersize: 6.0,
            boxplot_medianprops_color: "C1",
            boxplot_medianprops_linestyle: "-",
            boxplot_medianprops_linewidth: 1.0,
            boxplot_notch: false,
            boxplot_patchartist: false,
            boxplot_showbox: true,
            boxplot_showcaps: true,
            boxplot_showfliers: true,
            boxplot_showmeans: false,
            boxplot_vertical: true,
            boxplot_whiskerprops_color: "black",
            boxplot_whiskerprops_linestyle: "-",
            boxplot_whiskerprops_linewidth: 1.0,
            boxplot_whiskers: 1.5,
            contour_corner_mask: true,
            contour_linewidth: None,
            contour_negative_linestyle: "dashed",
            date_autoformatter_day: "%Y-%m-%d",
            date_autoformatter_hour: "%m-%d %H",
            date_autoformatter_microsecond: "%M:%S.%f",
            date_autoformatter_minute: "%d %H:%M",
            date_autoformatter_month: "%Y-%m",
            date_autoformatter_second: "%H:%M:%S",
            date_autoformatter_year: "%Y",
            date_converter: :auto,
            date_epoch: "1970-01-01T00:00:00",
            date_interval_multiples: true,
            docstring_hardcopy: false,
            errorbar_capsize: 0.0,
            figure_autolayout: false,
            figure_constrained_layout_h_pad: 0.04167,
            figure_constrained_layout_hspace: 0.02,
            figure_constrained_layout_use: false,
            figure_constrained_layout_w_pad: 0.04167,
            figure_constrained_layout_wspace: 0.02,
            figure_dpi: 100.0,
            figure_edgecolor: "white",
            figure_facecolor: "white",
            figure_figsize: [6.4, 4.8],
            figure_frameon: true,
            figure_max_open_warning: 20,
            figure_raise_window: true,
            figure_subplot_bottom: 0.11,
            figure_subplot_hspace: 0.2,
            figure_subplot_left: 0.125,
            figure_subplot_right: 0.9,
            figure_subplot_top: 0.88,
            figure_subplot_wspace: 0.2,
            figure_titlesize: "large",
            figure_titleweight: "normal",
            font_cursive: [
              "Apple Chancery",
              "Textile",
              "Zapf Chancery",
              "Sand",
              "Script MT",
              "Felipa",
              "Comic Neue",
              "Comic Sans MS",
              "cursive"
            ],
            font_family: ["sans-serif"],
            font_fantasy: [
              "Chicago",
              "Charcoal",
              "Impact",
              "Western",
              "Humor Sans",
              "xkcd",
              "fantasy"
            ],
            font_monospace: [
              "DejaVu Sans Mono",
              "Bitstream Vera Sans Mono",
              "Computer Modern Typewriter",
              "Andale Mono",
              "Nimbus Mono L",
              "Courier New",
              "Courier",
              "Fixed",
              "Terminal",
              "monospace"
            ],
            font_sans_serif: [
              "DejaVu Sans",
              "Bitstream Vera Sans",
              "Computer Modern Sans Serif",
              "Lucida Grande",
              "Verdana",
              "Geneva",
              "Lucid",
              "Arial",
              "Helvetica",
              "Avant Garde",
              "sans-serif"
            ],
            font_serif: [
              "DejaVu Serif",
              "Bitstream Vera Serif",
              "Computer Modern Roman",
              "New Century Schoolbook",
              "Century Schoolbook L",
              "Utopia",
              "ITC Bookman",
              "Bookman",
              "Nimbus Roman No9 L",
              "Times New Roman",
              "Times",
              "Palatino",
              "Charter",
              "serif"
            ],
            font_size: 10.0,
            font_stretch: "normal",
            font_style: "normal",
            font_variant: "normal",
            font_weight: "normal",
            grid_alpha: 1.0,
            grid_color: "#b0b0b0",
            grid_linestyle: "-",
            grid_linewidth: 0.8,
            hatch_color: "black",
            hatch_linewidth: 1.0,
            hist_bins: 10,
            image_aspect: "equal",
            image_cmap: "viridis",
            image_composite_image: true,
            image_interpolation: "antialiased",
            image_lut: 256,
            image_origin: "upper",
            image_resample: true,
            interactive: false,
            legend_borderaxespad: 0.5,
            legend_borderpad: 0.4,
            legend_columnspacing: 2.0,
            legend_edgecolor: "0.8",
            legend_facecolor: "inherit",
            legend_fancybox: true,
            legend_fontsize: "medium",
            legend_framealpha: 0.8,
            legend_frameon: true,
            legend_handleheight: 0.7,
            legend_handlelength: 2.0,
            legend_handletextpad: 0.8,
            legend_labelcolor: nil,
            legend_labelspacing: 0.5,
            legend_loc: "best",
            legend_markerscale: 1.0,
            legend_numpoints: 1,
            legend_scatterpoints: 1,
            legend_shadow: false,
            legend_title_fontsize: None,
            lines_antialiased: true,
            lines_color: "C0",
            lines_dash_capstyle: :butt,
            lines_dash_joinstyle: :round,
            lines_dashdot_pattern: [6.4, 1.6, 1.0, 1.6],
            lines_dashed_pattern: [3.7, 1.6],
            lines_dotted_pattern: [1.0, 1.65],
            lines_linestyle: "-",
            lines_linewidth: 1.5,
            lines_marker: nil,
            lines_markeredgecolor: :auto,
            lines_markeredgewidth: 1.0,
            lines_markerfacecolor: :auto,
            lines_markersize: 6.0,
            lines_scale_dashes: true,
            lines_solid_capstyle: :projecting,
            lines_solid_joinstyle: :round,
            markers_fillstyle: "full",
            patch_antialiased: true,
            patch_edgecolor: "black",
            patch_facecolor: "C0",
            patch_force_edgecolor: false,
            patch_linewidth: 1.0,
            path_effects: [],
            path_simplify: true,
            path_simplify_threshold: 0.111111111111,
            path_sketch: None,
            path_snap: true,
            pcolor_shading: :auto,
            pcolormesh_snap: true,
            pgf_preamble: "",
            pgf_rcfonts: true,
            pgf_texsystem: "xelatex",
            polaraxes_grid: true,
            ps_distiller_res: 6000,
            ps_fonttype: 3,
            ps_papersize: "letter",
            ps_useafm: false,
            ps_usedistiller: None,
            savefig_bbox: None,
            savefig_directory: "~",
            savefig_dpi: "figure",
            savefig_edgecolor: :auto,
            savefig_facecolor: :auto,
            savefig_format: "png",
            savefig_orientation: "portrait",
            savefig_pad_inches: 0.1,
            savefig_transparent: false,
            scatter_edgecolors: "face",
            scatter_marker: "o",
            svg_fonttype: "path",
            svg_hashsalt: None,
            svg_image_inline: true,
            text_antialiased: true,
            text_color: "black",
            text_hinting: "force_autohint",
            text_hinting_factor: 8,
            text_kerning_factor: 0,
            text_latex_preamble: "",
            text_usetex: false,
            timezone: "UTC",
            tk_window_focus: false,
            toolbar: "toolbar2",
            webagg_address: "127.0.0.1",
            webagg_open_in_browser: true,
            webagg_port: 8988,
            webagg_port_retries: 50,
            xaxis_labellocation: "center",
            xtick_alignment: "center",
            xtick_bottom: true,
            xtick_color: "black",
            xtick_direction: "out",
            xtick_labelbottom: true,
            xtick_labelcolor: "inherit",
            xtick_labelsize: "medium",
            xtick_labeltop: false,
            xtick_major_bottom: true,
            xtick_major_pad: 3.5,
            xtick_major_size: 3.5,
            xtick_major_top: true,
            xtick_major_width: 0.8,
            xtick_minor_bottom: true,
            xtick_minor_pad: 3.4,
            xtick_minor_size: 2.0,
            xtick_minor_top: true,
            xtick_minor_visible: false,
            xtick_minor_width: 0.6,
            xtick_top: false,
            yaxis_labellocation: "center",
            ytick_alignment: "center_baseline",
            ytick_color: "black",
            ytick_direction: "out",
            ytick_labelcolor: "inherit",
            ytick_labelleft: true,
            ytick_labelright: false,
            ytick_labelsize: "medium",
            ytick_left: true,
            ytick_major_left: true,
            ytick_major_pad: 3.5,
            ytick_major_right: true,
            ytick_major_size: 3.5,
            ytick_major_width: 0.8,
            ytick_minor_left: true,
            ytick_minor_pad: 3.4,
            ytick_minor_right: true,
            ytick_minor_size: 2.0,
            ytick_minor_visible: false,
            ytick_minor_width: 0.6,
            ytick_right: false
end
