defmodule SqueezeWeb.Dashboard.OverviewLive do
  use SqueezeWeb, :live_view

  alias Squeeze.Dashboard
  alias Squeeze.Challenges

  @impl true
  def mount(_params, session, socket) do
    user = socket.assigns[:current_user] || get_current_user(session)
    activities = Dashboard.recent_activities(user)
    summaries = Dashboard.list_activity_summaries(user)
    activity_map = activity_map(summaries)

    socket = assign(socket,
      page_title: "Dashboard",
      current_user: user,
      activity_map: activity_map,
      activity_summaries: summaries,
      activities: activities,
      challenges: Challenges.list_current_challenges(user),
      run_activities: run_activities(summaries),
      run_dates: run_dates(summaries),
      todays_activities: Dashboard.todays_activities(user),
      ytd_run_stats: Squeeze.Stats.ytd_run_summary(user)
    )

    {:ok, socket}
  end

  defp activity_map(summaries) do
    summaries
    |> Enum.reduce(%{}, fn(x, acc) ->
      date = x.start_at_local |> Timex.to_date()
      list = Map.get(acc, date, [])
      Map.put(acc, date, [x | list])
    end)
  end

  defp run_activities(summaries) do
    summaries
    |> Enum.filter(&(String.contains?(&1.type, "Run")))
  end

  defp run_dates(summaries) do
    summaries
    |> Enum.filter(&(String.contains?(&1.type, "Run")))
    |> Enum.map(&(Timex.to_date(&1.start_at_local)))
    |> Enum.uniq()
    |> Enum.reject(&is_nil/1)
  end
end