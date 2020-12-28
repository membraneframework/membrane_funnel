defmodule Membrane.Funnel do
  @moduledoc """
  Element that can be used for collecting data from multiple inputs and sending it through one
  output.
  """
  use Membrane.Filter

  alias Membrane.Funnel

  def_input_pad :input, demand_unit: :buffers, caps: :any, availability: :on_request
  def_output_pad :output, caps: :any

  def_options end_of_stream: [spec: :on_last_pad | :never, default: :on_last_pad]

  @impl true
  def handle_init(opts) do
    {:ok, Map.from_struct(opts)}
  end

  @impl true
  def handle_demand(:output, _size, :buffers, ctx, state) do
    demands = ctx |> inputs_data() |> Enum.map(&{:demand, {&1.ref, 1}})
    {{:ok, demands}, state}
  end

  @impl true
  def handle_process(Pad.ref(:input, _id), buffer, _ctx, state) do
    {{:ok, buffer: {:output, buffer}, redemand: :output}, state}
  end

  @impl true
  def handle_pad_added(Pad.ref(:input, _id) = pad, _ctx, state) do
    {{:ok, [demand: {pad, 1}, event: {:output, %Funnel.NewInputEvent{pad: pad}}]}, state}
  end

  @impl true
  def handle_event(:output, %Funnel.NewInputResponseEvent{} = response_event, ctx, state) do
    %Funnel.NewInputResponseEvent{pad: pad, event: event} = response_event

    if pad == :all do
      events = ctx |> inputs_data() |> Enum.map(&{:event, {&1.ref, event}})
      {{:ok, events}, state}
    else
      {{:ok, event: {pad, event}}, state}
    end
  end

  @impl true
  def handle_event(_pad, _event, _ctx, state) do
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
      {_ref, %{direction: :input} = data} -> [data]
      _output -> []
    end)
  end
end
