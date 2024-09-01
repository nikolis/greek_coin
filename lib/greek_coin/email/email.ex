defmodule GreekCoin.Email do 

  alias GreekCoin.Accounts.User
  alias GreekCoin.Newsletter.NewsUser

  import Bamboo.Email

  def email_verification_email(email, url) do
    new_email(
      to: email,
      from: "info@greek-coin.gr",
      subject: "Greek Coin email Verification",
      html_body: 
      "<h1> Email Verification </h1>" <>
        "<a href=\"" <> url <>"\"> please verify the email address by clicking on the following"   , 
      text_body: "Thanks for joining!"
    )
  end

  def credential_reset_email(%User{} = user, token) do
    new_email(
      to: user.credential.email,
      from: "info@greek-coin.gr",
      subject: "Greek Coin Password reset",
      html_body: 
      "<h1> Passwordreset </h1>" <>
        "Please use this token to update your credentials: " <> token , 
      text_body: "Thanks for joining!"
    )
  end 

  def get_withdraw_details(withdraw) do
    if (! is_nil(withdraw.user_bank_details)) do  
      ( "<p> Beneficial Name " <> withdraw.user_bank_details.beneficiary_name <> " </p> </br>" <>
      "<p> IBAN "<> withdraw.user_bank_details.iban <> "</p> </br>"<>
       "<p> BIC/SWIFT CODE "<> withdraw.user_bank_details.swift_code <> "</p> </br>"<>
      "<p> Bank Name " <> withdraw.user_bank_details.name <> " </p> </br>")
    else
      if (! is_nil(withdraw.user_wallet)) do
        "<span> Wallet Address " <> withdraw.user_wallet.bublic_key <> " </span>" 
      else
        ""
      end
    end
  end

  def withdraw_verification_email(%User{} = user, url, withdraw) do
    amount = withdraw.ammount
    alias = withdraw.currency.alias
    new_email(
      to: user.credential.email,
      from: "info@greek-coin.gr",
      subject: "Greek Coin Withdrawall Request Verification",
      html_body: 
      "<img src= \"https://s3.eu-west-2.amazonaws.com/greek.coin.crupto.images/logo.png\" >"<>
      "<h1> Withdrawall Verification </h1>" <>
      "<p> You have requested to withdraw: "<> to_string(amount) <>" " <> alias <> " </p> "<>
      "</br>" <>
        "<p>" <> get_withdraw_details(withdraw) <> "</p>"<>
      "<p>" <> "PLEASE check carefully the details above. Be aware that if you confirm an incorrect address or bank account details , we will not be able to assist you to recover your assets." <>
        "<p> Verify this withdrawal by clicking <a href=\"" <> url <>"\"> HERE </p>" <>
          "<p> The verification link is valid for 60 minutes. Please do not share the link with anyone.</p>"<>
      "<p> If you did not initiate this operation, come in touch with us, as soon as possible through our chat or send us an email to support@greek-coin.com</p>"<>
      "<p> This is an automated message, please do not reply</p>"<>
      "<p>GREEK COIN OU <br> ESTONIA Roseni 13m Tallinn Harju,10111 <br> GREECE l.V.Kon/nou 42,Athens,11635 <br> info@greek-coin.com <br> info@greek-coin.gr <br> +372 60 23 53 0 <br> +30 211 40 33 211 <br> +30 6908 66 88 44</p>",
      text_body: "Thanks for your pattience!"
    )
  end 

  def newsletter_verification_email(%NewsUser{} = user, url) do
    new_email(
      to: user.email,
      from: "info@greek-coin.gr",
      subject: "Greek Coin Newsletter registration",
      html_body: 
      "<h1> Thank you for joinning our newsletter </h1>" <>
        "<a href=\"" <> url <>"\"> please verify your registration by clicking on this link"   , 
      text_body: "Thanks for your pattience!"
    )
  end 

  def newsletter_delete_verification_email(email, url) do

    new_email(
      to: email,
      from: "info@greek-coin.gr",
      subject: "Greek Coin Newsletter list un registration",
      html_body: 
      "<h1> We are sorry your are not sutisfied </h1>" <>
        "<a href=\"" <> url <>"\"> please verify your de registration by clicking on this link"   , 
      text_body: "Thanks for your pattience!"
    )
  end 

  def new_transaction_notification() do
    new_email(
      to: "nikolisgal@gmail.com",
      from: "info@greek-coin.gr",
      subject: "New Transaction Notification For admins",
      html_body: 
      "<h1> There is a new notification that needs your attention !  </h1>", 
      text_body: "Please handle as soon as possible"
    )
  end 
end
