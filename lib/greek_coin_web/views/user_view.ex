defmodule GreekCoinWeb.UserView do
  use GreekCoinWeb, :view      

  alias GreekCoinWeb.UserView  
  alias GreekCoinWeb.AddressView
  import Kerosene.JSON

  def render("list.json", %{users: users, kerosene: kerosene, conn: conn}) do
    %{data: render_many(users, UserView, "user.json"),
      pagination: paginate(conn, kerosene)
    }
  end

  def render("show.json", %{user: user}) do
    %{user: render_one(user, UserView, "user.json")}
  end   
        
  def render("index.json", %{users: users}) do
    %{data: render_many(users, UserView, "user.json")} 
  end   

  def render("user.json", %{user: user}) do
    %{id: user.id,
      email: user.credential.email,
      first_name: user.first_name, 
      status: user.status, 
      last_name: user.last_name,
      role: user.role,
      mobile: user.mobile,
      auth2fa: user.auth2fa,
      clearance_level: user.clearance_level, 
      address: render_one( user.address, AddressView, "address.json"),
      id_pic_front: user.id_pic_front,
      id_pic_front_comment: user.id_pic_front_comment,
      id_pic_back: user.id_pic_back,
      id_pic_back_comment: user.id_pic_back_comment,
      ofi_bill_file: user.ofi_bill_file,
      ofi_bill_file_comment: user.ofi_bill_file_comment,
      selfie_pic: user.selfie_pic,
      selfie_pic_comment: user.selfie_pic_comment,

    }   
  end  


  def render("user_detailed.json", %{user: user}) do
    %{id: user.id,
      email: user.credential.email,
      first_name: user.first_name, 
      status: user.status, 
      last_name: user.last_name,
      role: user.role,
      mobile: user.mobile,
      auth2fa: user.auth2fa,

      id_pic_front: user.id_pic_front,
      id_pic_front_comment: user.id_pic_front_comment,
      id_pic_back: user.id_pic_back,
      id_pic_back_comment: user.id_pic_back_comment,
      ofi_bill_file: user.ofi_bill_file,
      ofi_bill_file_comment: user.ofi_bill_file_comment,
      selfie_pic: user.selfie_pic,
      selfie_pic_comment: user.selfie_pic_comment,
      clearance_level: user.clearance_level, 

      address: render_one( user.address, AddressView, "address.json")
    }   
  end  

  def render("upload.json", %{auth_header: header, date: date, file_hash: hash, path: path}) do
    %{
      auth_header: header,
      date: date,
      hash: hash,
      path: path,
    }
  end  
  
  def render("error.json", %{changeset: changeset}) do
    ret =  Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
    IO.inspect ret
    ret
  end 
    
end 
