defmodule Membrane.Funnel.NewInputResponseEvent do
  @moduledoc """
  Event that can be sent in response for `Membrane.Funnel.NewInputEvent`.

  `event` - event that should be sent by `Membrane.Funnel` on pad `pad`. If `:all` is passed
  then `event` will be sent on all funnel input pads.
  """
  @derive Membrane.EventProtocol

  @type t :: %__MODULE__{pad: Membrane.Pad.ref_t(), event: Membrane.Event.t() | :all}
  defstruct pad: nil,
            event: nil
end
