#defmodule GreekCoinWeb.Plural do
# @behaviour Gettext.Plural

  #def nplurals("elv"), do: 3

  #def plural("elv", 0), do: 0
  #def plural("elv", 1), do: 1
  #def plural("elv", _), do: 2

  # Fallback to Gettext.Plural
  #def nplurals(locale), do: Gettext.Plural.nplurals(locale)
  #def plural(locale, n), do: Gettext.Plural.plural(locale, n)
  #end

  #defmodule MyApp.Gettext do
  #  use Gettext, otp_app: :greek_coin, plural_forms: GreekCoinWeb.Plural
  #end
