defmodule GreekCoin.TokenTest do
  use GreekCoin.DataCase


  describe "verify account email token" do
    alias GreekCoin.Accounts
    alias GreekCoin.Accounts.User
    alias GreekCoin.Token

    test "generate_and_verify_email_token"  do
      {:ok, user} = Accounts.create_user(%{credential: %{email: "someemail@host.com", password: "somepassword"}}) 
      assert user.credential.email == "someemail@host.com"
      
      token = Token.generate_new_account_email_token(user.credential.email)
      {:ok, email} = Token.verify_new_account_email_token(token)

      userReturn  = Accounts.get_user_by_email(email)
      assert userReturn.credential.email == "someemail@host.com"
    end  
  end

end
