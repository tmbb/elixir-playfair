#set page(width: auto, height: auto, margin: 10pt)

#let new_canvas(height: auto, width: auto) = {(
    height: height,
    width: width,
    x: (),
    y: (),
    contents: (),
    widths: (),
    heights: ()
  )
}

#let XY-Axis(name: none,
             location: bottom,
             direction: none,
             size: 100%,
             label: none,
             label_alignment: center,
             label_outer_padding: 7pt,
             label_inner_padding: 10pt,
             label_rotation: none,
             label_align: center,
             label_location: center,
             major_tick_locations: (),
             major_tick_labels: (),
             major_tick_size: 7pt,
             major_tick_padding: 4pt,
             spine: true,
             start_padding: 0pt,
             start_margin: 0pt,
             end_padding: 0pt,
             end_margin: 0pt) = {

  // By default, axes are bottom_to_top or left_to_right
  let actual_direction = if direction == none {
    if location == bottom or location == top {
      ltr
    } else if location == left or location == right {
      btt
    }
  } else {
    direction
  }

  let actual_label_rotation = if label_rotation == none {
    if location == bottom or location == top {
      0deg
    } else if location == left {
      270deg
    } else if location == right {
      90deg
    }
  } else {
    label_rotation
  }
  
  (
    name: name,
    direction: actual_direction,
    location: location,
    size: size,
    label: label,
    label_inner_padding: label_inner_padding,
    label_outer_padding: label_outer_padding,
    label_rotation: actual_label_rotation,
    label_align: label_align,
    label_location: label_location,
    major_tick_locations: major_tick_locations,
    major_tick_labels: major_tick_labels,
    major_tick_size: major_tick_size,
    major_tick_padding: major_tick_padding,
    spine: spine,
    start_padding: start_padding,
    start_margin: start_margin,
    end_padding: end_padding,
    end_margin: end_margin
  )
}


#let float_formatter(value, decimal_places: 2) = {
  [#calc.round(value, digits: decimal_places)]
}

#let percent_formatter(value, decimal_places: 0) = {
  [#calc.round(value * 100, digits: decimal_places)%]
}

#let absolute_part(relative_length, styles) = {
  measure(box(width: relative_length), styles).width
}

#let draw_on_canvas(canvas, element, styles, x: 0%, y: 0%, halign: "left", valign: "bottom") = {
  let size = measure(element, styles)
  let abs_x = absolute_part(x, styles)
  let abs_y = absolute_part(y, styles)

  assert(type(valign) == "float" or valign in ("top", "bottom", "center"),
    message: "Parameter 'valign' must be either a float
              or one of \"top\", \"bottom\" or \"center\". Got " +
              repr(valign) + " instead.")

  assert(type(halign) == "float" or halign in ("left", "right", "center"),
    message: "Parameter 'halign' must be either a float
              or one of \"left\", \"right\" or \"center\". Got " +
              repr(halign) + " instead.")
              
  let new_width = {
    if (halign == "left") {
      abs_x + size.width
    } else if (halign == "right") {
      abs_x - size.width
    } else if (halign == "center") {
      abs_x - size.width/2
    }
  }

  let new_height = {
    if (valign == "top") {
      abs_y + size.height
    } else if (valign == "bottom") {
      abs_y - size.height
    } else if (valign == "center") {
      abs_y - size.height/2
    }
  }

  let actual_x = {
    if (halign == "left") {
      x
    } else if (halign == "right") {
      x - size.width
    } else if (halign == "center") {
      x - size.width/2
    } else if type(halign) == "float" {
      x - size.width * halign
    }
  }

  let actual_y = {
    if (valign == "top") {
      y
    } else if (valign == "bottom") {
      y - size.height
    } else if (valign == "center") {
      y - size.height/2
    } else if type(valign) == "float" {
      y - size.height * valign
    }
  }

  canvas.x.push(actual_x)
  canvas.y.push(actual_y)
  canvas.widths.push(new_width)
  canvas.heights.push(new_height)
  canvas.contents.push(element)

  canvas
}

#let max_of_array(array) = {
  array.fold(0pt, calc.max)
}

#let min_of_array(array) = {
  array.fold(0pt, calc.min)
}

#let canvas_to_box(canvas, width: auto, height: auto) = {
  let box_width = if width == "minimum" {
    max_of_array(canvas.widths.map(calc.abs))
  } else {
    width
  }
  
  let box_height = if height == "minimum" {
    max_of_array(canvas.heights.map(calc.abs))
  } else {
    height
  }
  
  box(width: box_width, height: box_height)[
      #for i in range(0, canvas.contents.len()) {
        let x = canvas.x.at(i)
        let y = canvas.y.at(i)
        let element = canvas.contents.at(i)
        
        place(
          top + left,
          dx: x,
          dy: y,
          element
        )
      }
  ]
}

#let rotate_affecting_layout(angle, body) = style(styles => {
  if angle == 0deg {
    // Simplify a common case (NOTE: this doesn't generate a box. Should it?)
    body 
  } else {
    // The general case
    let size = measure(body, styles)
    box(inset: (x: -size.width/2+(size.width*calc.abs(calc.cos(angle))+size.height*calc.abs(calc.sin(angle)))/2,
               y: -size.height/2+(size.height*calc.abs(calc.cos(angle))+size.width*calc.abs(calc.sin(angle)))/2),
               rotate(body,angle))
  }
})

#let log_scale(x, maximum, minimum) = {
  (calc.log(x) - calc.log(minimum)) / (calc.log(maximum) - calc.log(minimum))
}

#let position_on_XY_axis(axis, relative_value) = {
  let non_data_size = (
    axis.start_padding + axis.end_padding +
    axis.start_margin + axis.end_margin
  )
  
  let data_size = axis.size - non_data_size
  
  if axis.direction == ltr or axis.direction == ttb {
    // The axis coordinates align with the normal Typst coordinate system
    axis.start_padding + axis.start_margin + (relative_value * data_size)
  } else if axis.direction == rtl or axis.direction == btt {
    // The axis coordinates are inverted relative to the normal Typst coordinate system
    100% - ((axis.end_padding + axis.end_margin) + (relative_value * data_size))
  }
}

#let draw_vertical_XY_Axis_label(axis, rest_of_axis, side_of_label, styles) = {
  let direction = if side_of_label == "right" {
    ltr
  } else if side_of_label == "left" {
    rtl
  } else {
    panic("'side_of_label' bust be \"left\" or \"right\"")
  }
  
  let label_box = if (axis.label == none) {
    none
  } else {
    let c2 = new_canvas()
    c2 = draw_on_canvas(c2,
                        rotate_affecting_layout(axis.label_rotation, axis.label),
                        styles, x: 0%, y: 50%,
                        halign: "left",
                        valign: "center")
                        
    stack(dir: direction,
      h(axis.label_inner_padding),
      canvas_to_box(c2, width: "minimum")
    )
  }

  stack(
    dir: direction,
    rest_of_axis,
    label_box
  )
}

#let draw_right_XY_Axis_label(axis, rest_of_axis, styles) = {
   draw_vertical_XY_Axis_label(axis, rest_of_axis, "right", styles)
}

#let draw_left_XY_Axis_label(axis, rest_of_axis, styles) = {
   draw_vertical_XY_Axis_label(axis, rest_of_axis, "left", styles)
}

#let draw_horizontal_XY_Axis_label(axis, rest_of_axis, styles) = {
  let (label_valign, stack_direction, y) = if axis.location == top {
    ("bottom", btt, 100%)
  } else if axis.location == bottom {
    ("top", ttb, 0%)
  } else {
    panic("axis location must be 'top' or 'bottom'")
  }

  let label_box = if (axis.label == none) {
    none
  } else {
    let c2 = new_canvas()
    c2 = draw_on_canvas(c2,
                        rotate_affecting_layout(axis.label_rotation, axis.label),
                        styles, x: 50%, y: y,
                        halign: "center",
                        valign: label_valign)
                        
    stack(dir: stack_direction,
      v(axis.label_inner_padding),
      canvas_to_box(c2, height: "minimum")
    )
  }

  stack(
    dir: stack_direction,
    rest_of_axis,
    label_box
  )
}

#let draw_bottom_XY_Axis(axis, styles) = {
  let (g_spine_start, g_spine_end) = if axis.direction == ltr {
    (axis.start_padding, axis.end_padding)
  } else if axis.direction == rtl {
    (axis.end_padding, axis.start_padding)
  } else {
    panic("axis direction must be either 'ltr' or 'rtl'")
  }
  
  let g_spine = if axis.spine {
    line(start: (g_spine_start, 0%),
         end: (100% - g_spine_end, 0%),
         stroke: (cap: "square"))
  } else []

  let c1 = new_canvas()
  let c1 = draw_on_canvas(c1, g_spine, styles, x: 0%, y: 0%)
  
  for (value, label) in axis.major_tick_locations.zip(axis.major_tick_labels) {
    let position = position_on_XY_axis(axis, value)
    let tick_line = line(
      start: (position, axis.major_tick_size),
      end: (position, 0%),
      stroke: (cap: "square")
    )
    
    c1 = draw_on_canvas(c1, tick_line, styles, x: 0%, y: 0%,
                        halign: "left", valign: "top")

    c1 = draw_on_canvas(c1, label, styles,
                        x: position, y: axis.major_tick_size + axis.major_tick_padding,
                        halign: "center", valign: "top")
  }

  draw_horizontal_XY_Axis_label(axis, canvas_to_box(c1, height: "minimum"), styles)
}

#let draw_top_XY_Axis(axis, styles) = {
  let (g_spine_start, g_spine_end) = if axis.direction == ltr {
    (axis.start_padding, axis.end_padding)
  } else if axis.direction == rtl {
    (axis.end_padding, axis.start_padding)
  } else {
    panic("axis direction must be either 'ltr' or 'rtl'")
  }
  
  let g_spine = if axis.spine {
    line(start: (g_spine_start, 0%),
         end: (100% - g_spine_end, 0%),
         stroke: (cap: "square"))
  } else []

  let c1 = new_canvas()
  let c1 = draw_on_canvas(c1, g_spine, styles, x: 0%, y: 100%)
  
  for (value, label) in axis.major_tick_locations.zip(axis.major_tick_labels) {
    let position = position_on_XY_axis(axis, value)
    let tick_line = line(
      start: (position, 100% - axis.major_tick_size),
      end: (position, 100%),
      stroke: (cap: "square")
    )
    
    c1 = draw_on_canvas(c1, tick_line, styles, x: 0%, y: 0%,
                        halign: "left", valign: "top")

    c1 = draw_on_canvas(c1, label, styles,
                        x: position, y: 100% - axis.major_tick_size - axis.major_tick_padding,
                        halign: "center", valign: "bottom")
  }

  draw_horizontal_XY_Axis_label(axis, canvas_to_box(c1, height: "minimum"), styles)
}

#let draw_left_XY_Axis(axis, styles) = {
  let (g_spine_start, g_spine_end) = if axis.direction == ttb {
    (axis.start_padding, axis.end_padding)
  } else if axis.direction == btt {
    (axis.end_padding, axis.start_padding)
  } else {
    panic("axis direction must be either 'ltr' or 'rtl'")
  }
  
  let g_spine = if axis.spine {
    line(start: (100%, 100% - g_spine_start),
         end: (100%, g_spine_end),
         stroke: (cap: "square"))
  } else []

  let c1 = new_canvas()
  let c1 = draw_on_canvas(c1, g_spine, styles, x: 0%, y: 0%)
  
  for (value, label) in axis.major_tick_locations.zip(axis.major_tick_labels) {
    let position = position_on_XY_axis(axis, value)
    let tick_line = line(
      start: (100% - axis.major_tick_size, position),
      end: (100%, position),
      stroke: (cap: "square")
    )
    
    c1 = draw_on_canvas(c1, tick_line, styles, x: 0%, y: 0%,
                        halign: "right",
                        valign: "top")

    c1 = draw_on_canvas(c1, label, styles,
                        x: 100% - axis.major_tick_size - axis.major_tick_padding,
                        y: position,
                        halign: "right", valign: "center")
  }

  draw_left_XY_Axis_label(axis, canvas_to_box(c1, width: "minimum"), styles)
}

#let draw_right_XY_Axis(axis, styles) = {
  let (g_spine_start, g_spine_end) = if axis.direction == ttb {
    (axis.start_padding, axis.end_padding)
  } else if axis.direction == btt {
    (axis.end_padding, axis.start_padding)
  } else {
    panic("axis direction must be either 'ltr' or 'rtl'")
  }
  
  let g_spine = if axis.spine {
    line(start: (0%, 100% - g_spine_start),
         end: (0%, g_spine_end),
         stroke: (cap: "square"))
  } else []

  let c1 = new_canvas()
  let c1 = draw_on_canvas(c1, g_spine, styles, x: 0%, y: 0%)
  
  for (value, label) in axis.major_tick_locations.zip(axis.major_tick_labels) {
    let position = position_on_XY_axis(axis, value)
    let tick_line = line(
      start: (0%, position),
      end: (axis.major_tick_size, position),
      stroke: (cap: "square")
    )
    
    c1 = draw_on_canvas(c1, tick_line, styles, x: 0%, y: 0%,
                        halign: "left",
                        valign: "top")

    c1 = draw_on_canvas(c1, label, styles,
                        x: axis.major_tick_size + axis.major_tick_padding,
                        y: position,
                        halign: "left", valign: "center")
  }

  draw_right_XY_Axis_label(axis, canvas_to_box(c1, width: "minimum"), styles)
}

#let draw_XY_Axis(axis, styles) = {
  if axis.location == top {
    draw_top_XY_Axis(axis, styles)
  } else if axis.location == right {
    draw_right_XY_Axis(axis, styles)
  } else if axis.location == bottom {
    draw_bottom_XY_Axis(axis, styles)
  } else if axis.location == left {
    draw_left_XY_Axis(axis, styles)
  } else {
    panic("Axis direction is invalid. Must be one of: top, bottom, left, right.")
  }
}

#let draw_XY_axes_area(axes, direction, whitespace_builder, styles) = {
  let g_objects = ()
  let n = axes.len()
  for i in range(n) {
    let axis = axes.at(i)
    let g_axis = draw_XY_Axis(axis, styles)
    g_objects.push(g_axis)
    if (i < n - 1) {
      g_objects.push(whitespace_builder(axis.label_outer_padding))
    }
  }
  
  stack(dir: direction, ..g_objects)
}

#let draw_top_XY_axes_area(axes, styles) = {
  draw_XY_axes_area(axes, btt, v, styles)
}

#let draw_bottom_XY_axes_area(axes, styles) = {
  draw_XY_axes_area(axes, ttb, v, styles)
}

#let draw_left_XY_axes_area(axes, styles) = {
  draw_XY_axes_area(axes, rtl, h, styles)
}

#let draw_right_XY_axes_area(axes, styles) = {
  draw_XY_axes_area(axes, ltr, h, styles)
}

#let scatterplot(axes, plot_blueprint) = {
  let data_x = plot_blueprint.data.x
  let data_y = plot_blueprint.data.y
  let x_axis_name = plot_blueprint.x_axis
  let y_axis_name = plot_blueprint.y_axis
  let x_axis = axes.at(x_axis_name)
  let y_axis = axes.at(y_axis_name)

  let dot_radius = plot_blueprint.style.at("dot_radius", default: 4pt)
  let dot_fill = plot_blueprint.style.at("dot_fill", default: rgb(0%, 0%, 80%, 30%))

  [
    #for (x, y) in data_x.zip(data_y) {
      let position_x = position_on_XY_axis(x_axis, x)
      let position_y = position_on_XY_axis(y_axis, y)
      
      place(
        top + left,
        dx: position_x - dot_radius,
        dy: position_y - dot_radius,
        circle(
          radius: dot_radius,
          fill: dot_fill
        )
      )
    }
  ]  
}

#let _boxplot_single_box(y_axis, x_axis, single_box) = {
  let style = single_box.at("style", default: (__map__: none))
  let box_width = style.at("box_width", default: 15pt)
  let whisker_width = style.at("whisker_width", default: 10pt)
  
  let p_x = position_on_XY_axis(x_axis, single_box.x)
  let p_whisker_low = position_on_XY_axis(y_axis, single_box.whisker_low)
  let p_box_low = position_on_XY_axis(y_axis, single_box.q1)
  let p_median = position_on_XY_axis(y_axis, single_box.median)
  let p_box_high = position_on_XY_axis(y_axis, single_box.q3)
  let p_whisker_high = position_on_XY_axis(y_axis, single_box.whisker_high)

  [
    #place(
      top + left,
      dx: 0%,
      dy: 0%,
      line(
        start: (p_x - whisker_width/2, p_whisker_high),
        end: (p_x + whisker_width/2, p_whisker_high)
      )
    )
    #place(
      top + left,
      dx: 0%,
      dy: 0%,
      line(
        start: (p_x, p_whisker_high),
        end: (p_x, p_box_high)
      )
    )
    #place(
      top + left,
      dx: 0%,
      dy: 0%,
      line(
        start: (p_x, p_whisker_low),
        end: (p_x, p_box_low)
      )
    )
    #place(
      top + left,
      dx: p_x - box_width/2,
      dy: p_box_high,
      rect(
        width: box_width,
        height: p_median - p_box_high
      )
    )
    #place(
      top + left,
      dx: p_x - box_width/2,
      dy: p_median,
      rect(
        width: box_width,
        height: p_box_low - p_median
      )
    )
    #place(
      top + left,
      dx: 0%,
      dy: 0%,
      line(
        start: (p_x, p_box_low),
        end: (p_x, p_whisker_low)
      )
    )
    #place(
      top + left,
      dx: 0%,
      dy: 0%,
      line(
        start: (p_x - whisker_width/2, p_whisker_low),
        end: (p_x + whisker_width/2, p_whisker_low)
      )
    )
  ] 
}

#let boxplot(axes, plot_blueprint) = {
  let data = plot_blueprint.data
  
  let x_axis_name = plot_blueprint.x_axis_name
  let y_axis_name = plot_blueprint.y_axis_name
  let x_axis = axes.at(x_axis_name)
  let y_axis = axes.at(y_axis_name)

  for single_box in data {
    _boxplot_single_box(y_axis, x_axis, single_box)
  }
}


#let plot(
      plot_blueprints: (),
      title: none,
      title_padding: 16pt,

      width: 100%,
      height: 100%,
      
      top_axes: (XY-Axis(name: "x2", location: top),),
      left_axes: (XY-Axis(name: "y", location: left),),
      bottom_axes: (XY-Axis(name: "x", location: bottom),),
      right_axes: (XY-Axis(name: "y2", location: right),)
  ) = {

    let plot_title = if (title == none) {
      none
    } else {
      stack(dir: ttb, title, v(title_padding))
    }

    let axes = ("__map__": none)
    for axes_group in (top_axes, right_axes, bottom_axes, left_axes) {
      for axis in axes_group {
        // Enforce unique names for our axes
        if axis.name in axes {
          panic("The axes' names must be unique. Found duplicate names.")
        }

        // Insert a new axis into the dictionary
        axes.insert(axis.name, axis)
      }  
    }
    
    style(styles => {
      // Axes areas
      let g_top_axes_area = draw_top_XY_axes_area(top_axes, styles)
      let g_top_axes_area_height = measure(g_top_axes_area, styles).height
      
      let g_bottom_axes_area = draw_bottom_XY_axes_area(bottom_axes, styles)
      let g_bottom_axes_area_height = measure(g_bottom_axes_area, styles).height
      
      let g_left_axes_area = draw_left_XY_axes_area(left_axes, styles)
      let g_left_axes_area_width = measure(g_left_axes_area, styles).width
      
      let g_right_axes_area = draw_right_XY_axes_area(right_axes, styles)
      let g_right_axes_area_width = measure(g_right_axes_area, styles).width

      let plot_title_height = measure(plot_title, styles).height

      let data = for plot_blueprint in plot_blueprints {
        let plotter = plot_blueprint.plotter
        plotter(axes, plot_blueprint)
      }
      
      [
        #stack(
          dir: ttb,
          plot_title,
          grid(
            columns: (
              g_left_axes_area_width,
              width - plot_title_height - g_left_axes_area_width - g_right_axes_area_width,
              g_right_axes_area_width
            ),
            rows: (
              g_top_axes_area_height,
              height - g_top_axes_area_height - g_bottom_axes_area_height,
              g_bottom_axes_area_height
            ),
            gutter: 0pt,
            box(height: auto)[
              // top_right
            ],
            g_top_axes_area,
            box(height: auto)[
              // top_left  
            ],
            g_left_axes_area,
            box(height: auto)[
              // Center
              #data
            ],
            g_right_axes_area,
            box(height: auto)[
              // bottom_right  
            ],
            g_bottom_axes_area,
            box(height: auto)[
              // bottom_right 
            ]
          )
        )
      ]
    }
  )
}

// $ADD-PLOT-HERE