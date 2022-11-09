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
    
    run_in(24, :hour)
    
    {:noreply, state}
  end

  def run_in(time, :second) do
    Process.send_after(self(), :work, time*1000)
  end
  def run_in(time, :minute) do
    Process.send_after(self(), :work, time*60*1000)
  end
  def run_in(time, :hour) do
    Process.send_after(self(), :work, time*60*60*1000)
  end
  
  defp schedule(time) do
    time_diff_seconds = DateTime.utc_now()
    |> calculate_time_diff(time)

    run_in(time_diff_seconds)
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