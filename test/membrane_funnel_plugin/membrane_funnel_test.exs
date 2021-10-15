defmodule Membrane.FunnelTest do
  use ExUnit.Case

  import Membrane.Testing.Assertions

  alias Membrane.{Buffer, Funnel, Testing}

  test "Collects multiple inputs" do
    import Membrane.ParentSpec
    data = 1..10

    {:ok, pipeline} =
      %Testing.Pipeline.Options{
        elements: [
          src1: %Testing.Source{output: data},
          src2: %Testing.Source{output: data},
          funnel: Funnel,
          sink: Testing.Sink
        ],
        links: [
          link(:src1) |> to(:funnel),
          link(:src2) |> to(:funnel),
          link(:funnel) |> to(:sink)
        ]
      }
      |> Testing.Pipeline.start_link()

    :ok = Testing.Pipeline.play(pipeline)

    assert_receive {Membrane.Testing.Pipeline, ^pipeline,
                    {:playback_state_changed, :prepared, :playing}}

    data
    |> Enum.flat_map(&[&1, &1])
    |> Enum.each(fn payload ->
      assert_sink_buffer(pipeline, :sink, %Buffer{payload: ^payload})
    end)

    assert_end_of_stream(pipeline, :sink)
    refute_sink_buffer(pipeline, :sink, _buffer, 0)

    Membrane.Pipeline.stop_and_terminate(pipeline)

    assert_receive {Membrane.Testing.Pipeline, ^pipeline,
                    {:playback_state_changed, :prepared, :stopped}}
  end
end
