defmodule OmbuOssNotifier.IssuesNotificationsJob do
  use GenServer

  alias OmbuOssNotifier.Fastruby
  alias OmbuOssNotifier.SlackNotifier

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(state) do
    schedule(Time.new!(11, 0, 0))
    
    {:ok, state}
  end

  def handle_info(:work, state) do
    # the actual work to be done
    IO.puts("Running job ...")
    Fastruby.list_issues()
    |> SlackNotifier.notify()
    
    # For now, this will be in UTC
    Time.new!(11, 0, 0)
    |> schedule()
    
    {:noreply, state}
  end
  
  defp schedule(time) do
    time_diff_seconds = DateTime.utc_now()
    |> calculate_time_diff(time)

    Process.send_after(self(), :work, time_diff_seconds*1000)
  end

  def calculate_time_diff(today, time) when today.hour >= time.hour do
    tomorrow = DateTime.add(today, 1, :day)
    Date.new!(tomorrow.year, tomorrow.month, tomorrow.day)
    |> DateTime.new!(time)
    |> DateTime.diff(today)
  end
  def calculate_time_diff(today, time) do
    Date.new!(today.year, today.month, today.day)
    |> DateTime.new!(time)
    |> DateTime.diff(today)
  end
end