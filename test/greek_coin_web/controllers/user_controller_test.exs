defmodule GreekCoinWeb.UserControllerTest do
  use GreekCoinWeb.ConnCase

  alias GreekCoin.Accounts

  describe "create" do

    test "create a user with an email, pass and pass_repeat", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: %{"credential" => %{"password" => "123456789", "password_confirmation" => "123456789", "email" => "nikolisgal123@gmail.com" }})
      assert json_response(conn, 201) == "Success a verification email has beed send to your email address for please follow the link in the email to activate your account!"
    end
  end

  describe "update" do

    test "update a user to be admin from an admin account", %{conn: conn} do
      {:ok, admin} =  Accounts.create_user(%{credential: %{email: "nikolisgal23@gmail.com", password: "somepass"}, first_name: "nikos", role: "admin"})

      connCreateUser = post(conn, Routes.user_path(conn, :create), user: %{"credential" => %{"password" => "123456789", "password_confirmation" => "123456789", "email" => "nikolaos.galerakis234@gmail.com"}})
 
      assert json_response(connCreateUser, 201) == "Success a verification email has beed send to your email address for please follow the link in the email to activate your account!"

      connAuthUser = post(conn, Routes.auth_path(conn, :create), credential: %{"email" => "nikolaos.galerakis234@gmail.com" , "password" => "123456789", "captcha_token" => "some_token"})
      body = json_response(connAuthUser, 200)

      conn = 
        conn
        |> put_req_header("authorization", ("Bearer " <> body["user"]["token"])) 

      connGetUser = get(conn, Routes.user_path(conn, :get_user))
      body2 = json_response(connGetUser, 200)
      IO.inspect body2

      assert admin.first_name == "nikos"
      assert admin.role == "admin"

      

      connAuthAdmin = post(conn, Routes.auth_path(conn, :create), credential: %{"email" => "nikolisgal23@gmail.com" , "password" => "somepass", "captcha_token" => "some_token"})
      
      body3 = json_response(connAuthAdmin, 200)
      conn = 
        conn
        |> put_req_header("authorization", ("Bearer " <> body3["user"]["token"]))
      IO.inspect(body2["id"]) 

      connUpdateToAdmin = put(conn, Routes.user_path(conn, :admin_update,  body2["id"]), user: %{role: "admin"})
      json_response(connUpdateToAdmin, 200)
      
      conn = 
        conn
        |> put_req_header("authorization", ("Bearer " <> body["user"]["token"])) 

      connGetUser2 = get(conn, Routes.user_path(conn, :get_user))
      body4 = json_response(connGetUser2, 200)
      assert body4["role"] == "admin"
      
    end

    test "update a user to be admin from a non admin account should fail", %{conn: conn} do
      {:ok, admin} =  Accounts.create_user(%{credential: %{email: "nikolisgal2345@gmail.com", password: "somepass"}, first_name: "nikos", role: ""})

      connCreateUser = post(conn, Routes.user_path(conn, :create), user: %{"credential" => %{"password" => "123456789", "password_confirmation" => "123456789", "email" => "nikolaos.galerakis123@gmail.com"}})
 
      assert json_response(connCreateUser, 201) == "Success a verification email has beed send to your email address for please follow the link in the email to activate your account!"

      connAuthUser = post(conn, Routes.auth_path(conn, :create), credential: %{"email" => "nikolaos.galerakis123@gmail.com" , "password" => "123456789", "captcha_token" => "some_token"})
      body = json_response(connAuthUser, 200)

      conn = 
        conn
        |> put_req_header("authorization", ("Bearer " <> body["user"]["token"])) 

      connGetUser = get(conn, Routes.user_path(conn, :get_user))
      body2 = json_response(connGetUser, 200)

      assert admin.first_name == "nikos"
      assert admin.role == nil

      

      connAuthAdmin = post(conn, Routes.auth_path(conn, :create), credential: %{"email" => "nikolisgal2345@gmail.com" , "password" => "somepass", "captcha_token" => "some_token"})
      
      body3 = json_response(connAuthAdmin, 200)
      conn = 
        conn
        |> put_req_header("authorization", ("Bearer " <> body3["user"]["token"]))

      connUpdateToAdmin = put(conn, Routes.user_path(conn, :admin_update,  body2["id"]), user: %{role: "admin"})
      response(connUpdateToAdmin, 401)
      
      conn = 
        conn
        |> put_req_header("authorization", ("Bearer " <> body["user"]["token"])) 

      connGetUser2 = get(conn, Routes.user_path(conn, :get_user))
      body4 = json_response(connGetUser2, 200)
      assert body4["role"] == nil
      
    end


  end

end
