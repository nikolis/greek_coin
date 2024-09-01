module Page.Home exposing  (Model, Msg, init, subscriptions, toSession, update, view)

import Session exposing (Session)
import Html exposing (Html, button, div, fieldset, h1, input, li, text, textarea, ul)
import Html.Attributes exposing (attribute, class, placeholder, type_, value)
import Html.Events exposing (onInput, onSubmit)


type alias Model = 
    {
        name : String
        , session : Session
    }


type  Msg = 
    First

init : Session -> (Model, Cmd Msg)
init session = 
    (
        { name =  "Nikos"
        , session = session
        }
        , Cmd.none
    )

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


update : Msg -> Model -> ( Model, Cmd Msg)
update msg model =
    (model, Cmd.none)

view : Model -> { title: String, content : Html Msg}
view model =
    { title = ""
    , content = 
       div[][ text "asdafdasdfafsdafdsfdasfds"] 
    }


toSession : Model -> Session
toSession model =
    model.session
