defmodule Seismo.Accelerometer do 
  @moduledoc """
  This module starts a GenServer than periodically measures values from a 3 axis accelerometer 
  every quarter of a second
  """
  use GenServer 
  @name :accelerometer

  alias Circuits.I2C
  require Logger

  @doc """
  Client function to start the GenServer 
  """
  @spec start_link(term()) :: {:ok, pid()}
  def start_link(_) do 
    GenServer.start_link(__MODULE__, %{}, name: @name)
  end 


  ## Server Interface
  
  @doc """
  Server function called by start_link to initialize the server, this function connects to the i2c bus
  and holds it's reference in the server's state
  """
  @spec init(term()) :: {:ok, map()}
  def init(_) do 
    {:ok, bus} = I2C.open("i2c-1")
    
    Logger.info("bus names: #{inspect(I2C.bus_names())}")
    
    
    {:ok, %{bus: bus}, {:continue, []}}
  end 

  def handle_continue(_, state) do
    Logger.info("starting Loop")
    
    Process.send_after(self(), :read, 500)
      
    {:noreply, state}
  end 


  @doc """
  Server function to periodically read x, y, z axes from the accelerometer
  """
  def handle_info(:read, state) do 
    Process.send_after(self(), :read, 500)
        

    Logger.info("Reading x axis")
    Logger.info("x: #{read_sensor(state.bus, 0)}")
    Logger.info("Reading y axis")
    Logger.info("y: #{read_sensor(state.bus, 1)}")
    Logger.info("Read z axis")
    Logger.info("z: #{read_sensor(state.bus, 2)}")
  
    {:noreply, state}
  end

  defp read_sensor(ref, sensor) do 
    {channel_value, _} = Integer.parse("#{sensor + 40}", 16)

    {:ok, <<val>>} = I2C.write_read(ref, 0x48, <<channel_value>>, 1)

    val
  end 
end 
