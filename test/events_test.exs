defmodule Flux.EventsTest do
  use ExUnit.Case

  test "subscribes and unsubscribes per run topic" do
    run_id = "run-events-1"

    assert :ok = Flux.subscribe_run(run_id)
    assert :ok = Flux.Events.publish_run_event(run_id, :run_started, %{seq: 1, payload: %{}})

    assert_receive {:flux_run_event, %{event: :run_started, run_id: ^run_id, seq: 1}}

    assert :ok = Flux.unsubscribe_run(run_id)
    assert :ok = Flux.Events.publish_run_event(run_id, :run_finished, %{seq: 2, payload: %{}})

    refute_receive {:flux_run_event, %{event: :run_finished, run_id: ^run_id, seq: 2}}
  end
end
