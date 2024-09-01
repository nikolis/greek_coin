defmodule GreekCoin.Accounts do
  import Ecto.Query

  @moduledoc """
  The accounts context
  """

  alias GreekCoin.Repo
  alias GreekCoin.Accounts.User
  alias GreekCoin.Accounts.Credential
  alias GreekCoin.Accounts.LoginAttempt
  alias GreekCoin.Accounts.Address

  def create_login_attempt(attrs \\ %{}) do
    %LoginAttempt{}
    |> LoginAttempt.changeset(attrs)
    |> Repo.insert()
  end

  def create_failed_login_attempt(email, ip) do
    user =  get_user_by_email(email)
    attrs = %{user_id: user.id, result: "Failure" , ip_address: ip}
    %LoginAttempt{}
    |> LoginAttempt.changeset(attrs)
    |> Repo.insert()
  end

  def change_login_attempt(%LoginAttempt{} = loginAttempt) do
    LoginAttempt.changeset(loginAttempt, %{})
  end

  def change_address(%Address{} = address) do
    Address.changeset(address, %{})
  end

  def get_login_attempt!(id) do
    Repo.get!(LoginAttempt, id)
  end

  def get_users_count(status) do
    if (status == "all") do
       result = from(u in User, select: count(u.id)
       )
       |> Repo.all
       [head | _tail] = result
       head
    else 
      result = from(u in User, where: like(u.status, ^status), select: count(u.id)
      )
      |> Repo.all
      [head | _tail] = result
      head
    end
  end

  def list_login_attempts() do
    Repo.all(LoginAttempt)
  end

  def list_login_by_user(user_id, params) do
   query = from lg_at in LoginAttempt,          
     where: lg_at.user_id == ^user_id
   query
   Repo.paginate(query,params) 
  end


  def get_user_by_email(email) do
   query = from usr in User,          
      join: cred in Credential, 
      on: usr.id == cred.user_id,
      where: cred.email == ^email
      
   query
   |> Repo.one
   |> Repo.preload([:credential])
  end 
  
  def mark_as_email_verified(%User{} = user) do
    user
    |> User.changeset(%{status: "email_verified"})
    |> Repo.update()
  end 

  
  def update_user(%User{} = user, user_params) do
    User.changeset(user, user_params)
    |> Repo.update()
  end

  def update_address(address, params) do
    Address.changeset(address, params)
    |> Repo.update()
  end


   def admin_user_update(user, user_params) do
    User.admin_only_changeset(user, user_params)
    |> Repo.update()
  end

 
  def list_users do
    Repo.all(User)
    |> Repo.preload([:credential, :address])
  end

  def list_addresses do
    Repo.all(Address)
  end

  def get_address!(id) do
    Repo.get!(Address, id)
  end
 
  def delete_address(address) do
    Repo.delete(address)
  end

  def delete_login_attempt(loginAttempt) do
    Repo.delete(loginAttempt)
  end

  def get_user(id) do
    Repo.get(User, id)
  end

  def get_user!(id) do
    Repo.get!(User, id)
    |> Repo.preload(:address)
    |> Repo.preload(:credential)
  end

  def get_user_by(params) do
    Repo.get_by(User, params)
  end

  def reset_user_password(credential, changes) do
    credential
    |> Credential.changeset(changes)
    |> Repo.update()
  end

  def create_address(attrs \\ %{}) do
    %Address{}
    |> Address.changeset(attrs)
    |> Repo.insert()
  end
 
  def create_user(attrs \\ %{}) do
    insertion =
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
    case insertion do
      {:ok, %User{} = user} ->
        user = Repo.preload(user,[:credential])
        {:ok, user}
      {:error, err} ->
        {:error, err}
    end
  end

  def register_user(attrs \\ %{}) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

def authenticate_by_email_and_pass(email, given_pass) do
    user = get_user_by_email(email)
    cond do
      user && Bcrypt.verify_pass(given_pass, user.credential.password_hash) ->
        {:ok, user}
     
      user ->
        {:error, :unauthorized}
      
      true ->
        Pbkdf2.no_user_verify()
        {:error, :not_found}
    end
  end

  def list_credentials do
    Repo.all(Credential)
  end

  def get_credential!(id), do: Repo.get!(Credential, id)

  def create_credential(attrs \\ %{}) do
    %Credential{}
    |> Credential.changeset(attrs)
    |> Repo.insert()
  end

  def update_login_attempt(%LoginAttempt{} = attempt, attrs) do
    attempt
    |> LoginAttempt.changeset(attrs)
    |> Repo.update()
  end

  def update_credential_light(%Credential{} = credential, attrs) do
    credential
    |> Credential.changeset_light(attrs)
    |> Repo.update()
  end

  def update_credential(%Credential{} = credential, attrs) do
    credential
    |> Credential.changeset(attrs)
    |> Repo.update()
  end

  def delete_credential(%Credential{} = credential) do
    Repo.delete(credential)
  end

  def change_credential(%Credential{} = credential) do
    Credential.changeset(credential, %{})
  end
end

