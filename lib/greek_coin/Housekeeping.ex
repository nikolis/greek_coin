defmodule GreekCoin.Housekeeping do
  use GenServer
  
  alias GreekCoin.Funds

  def start_link(args) do
    GenServer.start_link(__MODULE__, [])
  end

  def init(state) do
    schedule_work()
    {:ok, state}
  end

  def handle_info(:work, state) do
    Funds.clean_transactions(DateTime.utc_now(), -60*60*2)
    Funds.clean_withdraws(DateTime.utc_now(), -60*60*2)
    schedule_work()
    {:noreply, state}
  end

  defp schedule_work() do
    Process.send_after(self, :work, (2 * 1000 * 60 *60))
  end

end
