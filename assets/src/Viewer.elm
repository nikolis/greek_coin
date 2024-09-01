module Viewer exposing (Viewer, avatar, cred, decoder, minPasswordChars, store, username, cookiesGet, decoderApi)

{-| The logged-in user currently viewing this page. It stores enough data to
be able to render the menu bar (username and avatar), along with Cred so it's
impossible to have a Viewer if you aren't logged in.
-}

import Api exposing (Cred)
import Avatar exposing (Avatar)
import Email exposing (Email)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (custom, required, optional)
import Json.Encode as Encode exposing (Value)
import Profile exposing (Profile)
import Username exposing (Username)



-- TYPES


type Viewer
    = Viewer Avatar Bool Cred



-- INFO


cred : Viewer -> Cred
cred (Viewer _ _ val) =
    val

cookiesGet : Viewer -> Bool
cookiesGet (Viewer _ cooki _ ) =
    cooki


username : Viewer -> Username
username (Viewer _ _ val) =
    Api.username val


avatar : Viewer -> Avatar
avatar (Viewer val _ _) =
    val


{-| Passwords must be at least this many characters long!
-}
minPasswordChars : Int
minPasswordChars =
    6

-- SERIALIZATION

decoderApi : Maybe Viewer -> Decoder (Cred -> Viewer)
decoderApi viewer=
   case viewer of 
       Nothing ->
            Decode.succeed Viewer
                |> custom (Decode.field "image" Avatar.decoder)
                |> optional "cookies"  Decode.bool True
       Just viewr ->
           let

               cookie =  cookiesGet viewr
           in
            Decode.succeed Viewer
                |> custom (Decode.field "image" Avatar.decoder)
                |> optional "cookies"  Decode.bool cookie


decoder : Decoder (Cred -> Viewer)
decoder =
    Decode.succeed Viewer
        |> custom (Decode.field "image" Avatar.decoder)
        |> required "cookies" Decode.bool


store : Viewer -> Cmd msg
store (Viewer avatarVal cookies credVal ) =
    let
        _ = Debug.log "storing" "creds"
    in
    Api.storeCredWith
        credVal
        avatarVal
        cookies
