defmodule Membrane.Funnel.NewInputEvent do
  @moduledoc """
  Event sent each time new element is linked via funnel input pad.
  """
  @derive Membrane.EventProtocol

  @type t :: %__MODULE__{}
  defstruct []
end
