defmodule GreekCoinWeb.KrakenView do

  use GreekCoinWeb, :view

  alias GreekCoinWeb.CurrencyView
  import Kerosene.JSON

  def render("list.json", %{currencies: currencies}) do
    %{data: render_many(currencies, CurrencyView, "currency.json")}
  end


  def render("currency.json", %{currency: currency}) do
    %{id: currency.id,
      title: currency.title,
      description: currency.description,
      active: currency.active,
      active_deposit: currency.active_deposit,
      alias: currency.alias,
      fee: currency.fee,
      deposit_fee: currency.deposit_fee,
      withdraw_fee: currency.withdraw_fee,
      url: currency.pic_url,
      alias_sort: currency.alias_sort,
      decimals: currency.decimals
    }

  end

  def render("error.json", %{changeset: changeset}) do
    ret =  Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
    IO.inspect ret
    ret
  end 


end
