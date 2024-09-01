defmodule GreekCoinWeb.AddressView do
  use GreekCoinWeb, :view
  

  def render("address.json", %{address: address}) do
    %{ zip: address.zip,
       address: address.title,
       country: address.country,
       city: address.city
    }
  end


end
