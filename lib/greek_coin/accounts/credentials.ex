defmodule  GreekCoin.Accounts.Credential do
  use Ecto.Schema 
  
  import Ecto.Changeset
  
  alias GreekCoin.Accounts.User


  schema "credentials" do      
    field :email, :string
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    field :password_hash, :string
    field :ga_secret, :string
            
    belongs_to :user, User
        
    timestamps()               
  end 

 def changeset_light(credential, attrs) do 
    IO.inspect attrs
    credential
    |> cast(attrs, [:ga_secret])
  end


  def changeset(credential, attrs) do 
    IO.inspect attrs
    credential
    |> cast(attrs, [:email, :password, :ga_secret])
    |> validate_required([:email, :password])
    |> validate_length(:password, min: 6, max: 100)
    |> unique_constraint(:email)
    |> put_pass_hash()
  end
    
  defp put_pass_hash(changeset) do
    case changeset do          
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password_hash, Bcrypt.hash_pwd_salt(pass))
     
      _ ->
        changeset
    end   
  end

end

