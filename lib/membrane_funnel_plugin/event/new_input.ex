defmodule Membrane.Funnel.NewInputEvent do
  @moduledoc """
  Event sent each time new element is linked via funnel input pad.

  `pad` - newly linked pad
  """
  @derive Membrane.EventProtocol

  @type t :: %__MODULE__{pad: Membrane.Pad.ref_t()}
  @enforce_keys [:pad]
  defstruct @enforce_keys
end
