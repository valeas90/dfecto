defmodule Doomanager.Events.BannerMessage do
  @moduledoc """
  Message Payload definition for account actions
  """

  @derive Jason.Encoder
  defstruct [
    :enabled,
    :end_date,
    :html_code,
    :id,
    :image,
    :is_default,
    :link,
    :mobile_image,
    :name,
    :target_blank,
    :terms_data,
    :search_engine,
    :start_date
  ]

  @type search_engine_info :: %{id: binary, hashid: binary}

  @type t :: %__MODULE__{
          enabled: binary,
          end_date: binary,
          html_code: binary,
          id: integer,
          image: binary,
          is_default: boolean,
          link: binary,
          mobile_image: binary,
          name: binary,
          target_blank: boolean,
          terms_data: list,
          search_engine: search_engine_info,
          start_date: binary
        }
end
