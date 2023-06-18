defmodule Playfair.Projection do
  @callback project(
    float(),
    float(),
    float(),
    float(),
    float(),
    float(),
    (float(), float(), float() -> float()),
    (float(), float(), float() -> float()),
    any()
  ) :: {float(), float()}
end

defmodule Playfair.CartesianProjection do
  def project(x, y, x_min, x_max, y_min, y_max, scale_x, scale_y, _opts) do
    p_x = scale_x.(x, x_min, x_max)
    p_y = scale_y.(y, y_min, y_max)

    {p_x, p_y}
  end
end

defmodule Playfair.PolarProjection do
  def project(r, theta, _r_min, r_max, _theta_min, _theta_max, scale_r, _scale_theta, _opts) do
    scaled_r = scale_r.(r, 0.0, r_max)
    p_x = scaled_r * :math.cos(theta)
    p_y = scaled_r * :math.sin(theta)

    {p_x, p_y}
  end
end
