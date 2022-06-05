defmodule Scraper do
  def work() do
    1..5
    |> Enum.random()
    |> :timer.seconds()
    |> Process.sleep()
  end

  def online?(_url) do
    work()

    Enum.random([false, true, true])
  end
end
