defmodule OmbuOssNotifier.IssuesNotificationsJob do
  use GenServer

  alias OmbuOssNotifier.Fastruby
  alias OmbuOssNotifier.SlackNotifier

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(state) do
    schedule()
    
    {:ok, state}
  end

  def handle_info(:work, state) do
    # the actual work to be done
    IO.puts("Running job ...")
    Fastruby.list_issues()
    |> SlackNotifier.notify()
    
    # work is done, let's schedule again
    schedule()
    
    {:noreply, state}
  end
  
  defp schedule() do
    # schedule after one minute
    Process.send_after(self(), :work, 10000)
  end

end