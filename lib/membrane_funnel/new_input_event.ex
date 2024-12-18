if :code.module_status(Membrane.Funnel.NewInputEvent) == :not_loaded do
  defmodule Membrane.Funnel.NewInputEvent do
    @moduledoc """
    Event sent each time new element is linked (via funnel input pad) after playing pipeline.
    """
    @derive Membrane.EventProtocol

    @type t :: %__MODULE__{}
    defstruct []
  end
end
