defmodule GreekCoinWeb.Translator do

  import GreekCoinWeb.Gettext

  def translate(%{"locale"=> locale}, method) do
     Gettext.with_locale GreekCoinWeb.Gettext, locale,  Gettext.gettext(GreekCoinWeb.Gettext,method)
  end

end
