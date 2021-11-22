defmodule Membrane.Funnel do
  @moduledoc """
  Element that can be used for collecting data from multiple inputs and sending it through one
  output.
  """
  use Membrane.Filter

  alias Membrane.Funnel

  def_input_pad :input, demand_mode: :auto, caps: :any, availability: :on_request
  def_output_pad :output, caps: :any, demand_mode: :auto

  def_options end_of_stream: [spec: :on_last_pad | :never, default: :on_last_pad]

  @impl true
  def handle_init(opts) do
    {:ok, %{end_of_stream: opts.end_of_stream}}
  end

  @impl true
  def handle_process(Pad.ref(:input, _id), buffer, _ctx, state) do
    {{:ok, buffer: {:output, buffer}}, state}
  end

  @impl true
  def handle_pad_added(Pad.ref(:input, _id), %{playback_state: :playing}, state) do
    {{:ok, event: {:output, %Funnel.NewInputEvent{}}}, state}
  end

  @impl true
  def handle_pad_added(Pad.ref(:input, _id), _ctx, state) do
    {:ok, state}
  end

  @impl true
  def handle_end_of_stream(Pad.ref(:input, _id), _ctx, %{end_of_stream: :never} = state) do
    {:ok, state}
  end

  @impl true
  def handle_end_of_stream(Pad.ref(:input, _id), ctx, %{end_of_stream: :on_last_pad} = state) do
    if ctx |> inputs_data() |> Enum.all?(& &1.end_of_stream?) do
      {{:ok, end_of_stream: :output}, state}
    else
      {:ok, state}
    end
  end

  defp inputs_data(ctx) do
    Enum.flat_map(ctx.pads, fn
      {Pad.ref(:input, _id), data} -> [data]
      _output -> []
    end)
  end
end
