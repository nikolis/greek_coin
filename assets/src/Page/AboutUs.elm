module Page.AboutUs exposing (..)

import Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (class, classList, href, style)

type alias Model =  
    {
        session : Session
    }

type Msg = 
  GotSession Session



init : Session -> (Model, Cmd Msg)
init session = 
    let
        md = { session = session}
    in
    (md, Cmd.batch [Cmd.none])


view : Model -> {title : String, content: Html Msg}
view model = 
    { title = "Contact Us"
    , content = 
        div[]
        [
            viewSteper model
        ]
     }


viewSteper : Model -> Html Msg
viewSteper model=
          div[class "container_profile_header" ]
          [
            div [class "center_exchange"]
            [
              h1 [][ span[][ text "About Us"]]
            ]
          ]
 

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = 
    case msg of 
      GotSession session ->
         ( { model | session = session }, Cmd.none
         )


toSession : Model -> Session
toSession model = 
    model.session


subscriptions : Model -> Sub Msg
subscriptions model =
    Session.changes GotSession (Session.navKey model.session)
