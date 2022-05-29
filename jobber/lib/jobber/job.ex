defmodule Jobber.Job do
  use GenServer, restart: :transient
  require Logger

  defstruct [:work, :id, :max_retries, retries: 0, status: "new"]

  def init(args) do
    work = Keyword.fetch!(args, :work)
    id = Keyword.get(args, :id)
    max_retries = Keyword.get(args, :max_retries, 3)

    state = %Jobber.Job{id: id, work: work, max_retries: max_retries}
    {:ok, state, {:continue, :run}}
  end

  def start_link(args) do
    args =
      if Keyword.has_key?(args, :id) do
        args
      else
        Keyword.put(args, :id, random_job_id())
      end

    id = Keyword.get(args, :id)
    type = Keyword.get(args, :type)

    GenServer.start_link(__MODULE__, args, name: via(id, type))
  end

  def random_job_id() do
    :crypto.strong_rand_bytes(5) |> Base.url_encode64(padding: false)
  end

  def handle_continue(:run, state) do
    new_state = state.work.() |> handle_job_result(state)

    if new_state.status == "errored" do
      Process.send_after(self(), :retry, 5000)
      {:noreply, new_state}
    else
      Logger.info("Job exiting #{state.id}")
      {:stop, :normal, new_state}
    end
  end

  def handle_info(:retry, state) do
    {:noreply, state, {:continue, :run}}
  end

  defp handle_job_result({:ok, _data}, state) do
    Logger.info("Job completed #{state.id}")
    %Jobber.Job{state | status: "done"}
  end

  defp handle_job_result(:error, %{status: "new"} = state) do
    Logger.warn("Job errored #{state.id}")
    %Jobber.Job{state | status: "errored"}
  end

  defp handle_job_result(:error, %{status: "errored"} = state) do
    Logger.warn("Job retry failed #{state.id}")
    new_state = %Jobber.Job{state | retries: state.retries + 1}

    if new_state.retries == state.max_retries do
      %Jobber.Job{state | status: "failed"}
    else
      new_state
    end
  end

  defp via(key, value) do
    {:via, Registry, {Jobber.JobRegistry, key, value}}
  end
end
