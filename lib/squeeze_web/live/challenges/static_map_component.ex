defmodule SqueezeWeb.Challenges.StaticMapComponent do
  use SqueezeWeb, :live_component

  alias SqueezeWeb.MapboxStaticMap

  def map_url(polyline) do
    opts = [
      height: 300,
      width: 500,
      show_pins: true,
      outline_color: "#FFFFFF"
    ]
    MapboxStaticMap.map_url(polyline, opts)
  end

  def description(user, segment) do
    distance = format_distance(segment.distance, user.user_prefs)
    "#{distance} - #{segment.city}, #{segment.state}"
  end
end
