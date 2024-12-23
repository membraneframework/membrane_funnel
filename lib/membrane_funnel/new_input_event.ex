module_name = Membrane.Funnel.NewInputEvent

if not Code.ensure_loaded?(module_name) do
  defmodule module_name do
    @moduledoc """
    Event sent each time new element is linked (via funnel input pad) after playing pipeline.
    """
    @derive Membrane.EventProtocol

    @type t :: %__MODULE__{}
    defstruct []
  end
end
