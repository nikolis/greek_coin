# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     GreekCoin.Repo.insert!(%GreekCoin.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
#
import GreekCoin.Funds
alias GreekCoin.Accounts
alias GreekCoin.Funds.Action

{:ok, _ada} = GreekCoin.Repo.insert(%GreekCoin.Funds.Currency{title: "ZEUR", alias: "EUR",active: true, fee: 0.0, deposit_fee: 0.0, withdraw_fee: 0.0, active_deposit: true, decimals: 2})
{:ok, _action} = GreekCoin.Repo.insert(%GreekCoin.Funds.Action{title: "Buy"})
{:ok, _action_sell} = GreekCoin.Repo.insert(%GreekCoin.Funds.Action{title: "Sell"})
{:ok, _action_exchange} = GreekCoin.Repo.insert(%GreekCoin.Funds.Action{title: "Exchange"})


{:ok, eng} = GreekCoin.Repo.insert(%GreekCoin.Localization.Country{name: "Other"})
{:ok, greece} = GreekCoin.Repo.insert(%GreekCoin.Localization.Country{name: "Greece"})

{:ok, user} = Accounts.create_user(%{user_name: "so username", country_id: greece.id, credential: %{email: "nikolisgal@gmail.com", password: "123456789", password_confirmation: "123456789"}, status: "email_verified", role: "admin"})


{:ok, _en} = GreekCoin.Repo.insert(%GreekCoin.Localization.Language{title: "English", tag: "en", country_id: eng.id})
{:ok, _gr} = GreekCoin.Repo.insert(%GreekCoin.Localization.Language{title: "Greek",tag: "gr", country_id: greece.id })


"""
{:ok, ada} = GreekCoin.Repo.insert(%GreekCoin.Funds.Currency{title: "ADA"})
{:ok, _atom} = GreekCoin.Repo.insert(%GreekCoin.Funds.Currency{title: "ATOM"})
{:ok, _bat} = GreekCoin.Repo.insert(%GreekCoin.Funds.Currency{title: "BAT"})
{:ok, _dai} = GreekCoin.Repo.insert(%GreekCoin.Funds.Currency{title: "DAI"})
{:ok, _gno} = GreekCoin.Repo.insert(%GreekCoin.Funds.Currency{title: "GNO"})
{:ok, _icx} = GreekCoin.Repo.insert(%GreekCoin.Funds.Currency{title: "ICX"})
{:ok, _link} = GreekCoin.Repo.insert(%GreekCoin.Funds.Currency{title: "LINK"})
{:ok, _lsk} = GreekCoin.Repo.insert(%GreekCoin.Funds.Currency{title: "LSK"})
{:ok, _nano} = GreekCoin.Repo.insert(%GreekCoin.Funds.Currency{title: "NANO"})
{:ok, _omg} = GreekCoin.Repo.insert(%GreekCoin.Funds.Currency{title: "OMG"})
{:ok, _paxg} = GreekCoin.Repo.insert(%GreekCoin.Funds.Currency{title: "PAXG"})
{:ok, _qtum} = GreekCoin.Repo.insert(%GreekCoin.Funds.Currency{title: "QTUM"})
{:ok, _sc} = GreekCoin.Repo.insert(%GreekCoin.Funds.Currency{title: "SC"})
{:ok, _usdt} = GreekCoin.Repo.insert(%GreekCoin.Funds.Currency{title: "USDT"})
{:ok, _waves} = GreekCoin.Repo.insert(%GreekCoin.Funds.Currency{title: "WAVES"})
{:ok, _xetc} = GreekCoin.Repo.insert(%GreekCoin.Funds.Currency{title: "XETC"})
{:ok, _xmln} = GreekCoin.Repo.insert(%GreekCoin.Funds.Currency{title: "XMLN"})
{:ok, _xrep} = GreekCoin.Repo.insert(%GreekCoin.Funds.Currency{title: "XREP"})
{:ok, _xtz} = GreekCoin.Repo.insert(%GreekCoin.Funds.Currency{title: "XTZ"})
{:ok, _xmlm} = GreekCoin.Repo.insert(%GreekCoin.Funds.Currency{title: "XXLM"})
{:ok, _xzec} = GreekCoin.Repo.insert(%GreekCoin.Funds.Currency{title: "XZEC"})
{:ok, xxbt} = GreekCoin.Repo.insert(%GreekCoin.Funds.Currency{title: "XXBT"})
{:ok, bch} = GreekCoin.Repo.insert(%GreekCoin.Funds.Currency{title: "BCH"})
{:ok, dash} = GreekCoin.Repo.insert(%GreekCoin.Funds.Currency{title: "DASH"})
{:ok, doge} = GreekCoin.Repo.insert(%GreekCoin.Funds.Currency{title: "XXDG"})
{:ok, eth} = GreekCoin.Repo.insert(%GreekCoin.Funds.Currency{title: "XETH"})
{:ok, ltc} = GreekCoin.Repo.insert(%GreekCoin.Funds.Currency{title: "XLTC"})
{:ok, xmr} = GreekCoin.Repo.insert(%GreekCoin.Funds.Currency{title: "XXMR"})
{:ok, xrp} = GreekCoin.Repo.insert(%GreekCoin.Funds.Currency{title: "XXRP"})
{:ok, zec} = GreekCoin.Repo.insert(%GreekCoin.Funds.Currency{title: "XZEC"})
{:ok, eos} = GreekCoin.Repo.insert(%GreekCoin.Funds.Currency{title: "EOS"})
{:ok, eur} = GreekCoin.Repo.insert(%GreekCoin.Funds.Currency{title: "EUR"})

GreekCoin.Repo.insert(%GreekCoin.Funds.Treasury{user_id: user.id, currency_id: ada.id, balance: 50.4})
GreekCoin.Repo.insert(%GreekCoin.Funds.Treasury{user_id: user.id, currency_id: xxbt.id, balance: 3.4})
GreekCoin.Repo.insert(%GreekCoin.Funds.Treasury{user_id: user.id, currency_id: xmr.id, balance: 30.4})
GreekCoin.Repo.insert(%GreekCoin.Funds.Treasury{user_id: user.id, currency_id: ltc.id, balance: 10.4})
GreekCoin.Repo.insert(%GreekCoin.Funds.Treasury{user_id: user.id, currency_id: eos.id, balance: 660.4})
"""
