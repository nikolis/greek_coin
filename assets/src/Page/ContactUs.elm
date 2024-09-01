module Page.ContactUs exposing (..)

import Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (class, classList, href, style, value, name, id, src, alt)
import Html.Events exposing (onInput)
import Svg.Attributes
import Svg exposing (svg, rect)
import Page.Home.Naview as Nav

type alias Model =  
    {
        session : Session
    }

type Msg = 
  GotSession Session
  | ContactNumber String
  | Name String


init : Session -> (Model, Cmd Msg)
init session = 
    let
        md = { session = session}
    in
    (md, Cmd.batch [Cmd.none])


view : Model -> {title : String, content: Html Msg}
view model = 
    { title = "Contact Us"
    , content = div[]
      [
        div[]
        [ 
         div[style "padding-right" "100px", style "margin-left" "-15px",style "background-image" "url(\"images/contact2.png\")", style "background-repeat" "no-repeat", style "background-size" "cover"]
         [
             div[class "col", style "margin-right" "10vw"]
             [
              Nav.naview model.session 2
             ]
         , div[class "row", style "width" "100%"]
           [
               div[class "col", style "margin-left" "10vw"]
               [
                 span[style "font-size" "3rem", style "font-weight" "bold", style "color""white"][text "Contact Us"]
               , br[][]
               , span[style "font-size" "2rem", style "color" "rgba(255,158,46,1)"][text "Cryptocurrency at a glance"]
               , br[][]
               , svg[style "margin-top" "3vh"]
                 [
                   rect
                   [ Svg.Attributes.fill "rgba(255,158,46,1)"
                   , Svg.Attributes.rx "7"
                   , Svg.Attributes.ry "7"
                   , Svg.Attributes.x "0"
                   , Svg.Attributes.y "0"
                   , Svg.Attributes.width "125"
                   , Svg.Attributes.height "14"
                   ][]
                 ] 
               ]
               , div[class "col-6"][]
           ]
         ]
        , div[ style "margin-bottom" "3vh"]
         [
            div[class "container-fluid", style "margin-bottom" "35vh"]
            [
              div[class "row justify-content-center"]
              [

                 div[class "col-6 col-md-12 col-lg-11 col-xl-6 order-sm-12 order-xs-12 order-md-12 order-lg-12 order-xl-1 ", style "margin-top" "100px"]
                 [ 
                     div[style "margin-left" "-60px", style "width" "100%"][img [src "/images/communication.svg", style "width" "100%", style "max-height" "100%", style "margin-right" "5px"][]]
                 ]

              ,  div[class "col-8 col-md-10 col-lg-11 col-xl-5 order-sm-1 order-xs-1 order-md-1 order-xl-15 order-lg-1  ", style "margin-left" "", style "margin-right" "5vw", style "margin-top" "100px"]
                [
                   div[class "row ", style "margin-bottom" "3vh"]
                   [
                       div[class "col"][input[style "font-weight" "bolder",style "text-shadow" "1px 0 rgb(118, 118, 118)",style "font-size" "1.25rem",Html.Attributes.placeholder "Your Name", style"padding" "1vw",style "border-radius" "50px",style "background-color" "rgb(239, 239, 239)", style "border-style" "none", style "padding-left" "3vw", style "width" "100%"][]]
                   ,  div[class "col"][input[style "font-weight" "bolder",style "font-size" "1.25rem",style "text-shadow" "1px 0 rgb(118, 118, 118)",Html.Attributes.placeholder "Contact Number", style"padding" "1vw",style "border-radius" "50px",style "background-color" "rgb(239, 239, 239)", style "border-style" "none", style "padding-left" "3vw", style "width" "100%"][]]

                   ]
                , div[class "row", style "margin-bottom" "3vh"]
                   [
                       div[class "col"][input[style "font-weight" "bolder",style "text-shadow" "1px 0 rgb(118, 118, 118)",style "font-size" "1.25rem",Html.Attributes.placeholder "Email", style"padding" "1vw",style "border-radius" "50px",style "background-color" "rgb(239, 239, 239)", style "border-style" "none", style "padding-left" "3vw", style "width" "100%"][]]
                   ,  div[class "col"][input[style "font-weight" "bolder",style "font-size" "1.25rem",style "text-shadow" "1px 0 rgb(118, 118, 118)",Html.Attributes.placeholder "Subject", style"padding" "1vw",style "border-radius" "50px",style "background-color" "rgb(239, 239, 239)", style "border-style" "none", style "padding-left" "3vw", style "width" "100%"][]]

                   ]
                , div[class "row", style "margin-bottom" "3vh"]
                  [
                      div[class "col", style "margin-top" "3dp"]
                      [
                          textarea[style "font-weight" "bolder",style "text-shadow" "1px 0 rgb(118, 118, 118)",style "font-size" "1.25rem",style "width" "100%", style "minimum-height" "50dp",  style"padding" "2vw", style "border-radius" "50px", style "background-color" "rgb(239, 239, 239)", style "border-style" "none", Html.Attributes.attribute "rows" "10", Html.Attributes.placeholder "Your message"][]
                      ]
                  ]
                , div[class "row"]
                 [
                     button[style "margin" "auto",style "border-radius" "50px", style "background-color" "rgba(0,99,166,1)", style "color" "white", style "padding" "1.5vh 3vw", style "font-weight" "bolder", style "text-shadow" "1px 0 white", style "border-style" "none", style "font-size" "1.25rem" , style "letter-spacing" "1px"][text "submit"]
                 ]
                ]
              ]
            ]
          ]
       ]
     ]
    }


update : Msg -> Model -> (Model, Cmd Msg)
update msg model = 
    case msg of 
      GotSession session ->
         ( { model | session = session }, Cmd.none
         )
      Name name ->
       (model, Cmd.none)

      ContactNumber number ->
       (model, Cmd.none)


toSession : Model -> Session
toSession model = 
    model.session

subscriptions : Model -> Sub Msg
subscriptions model =
    Session.changes GotSession (Session.navKey model.session)
