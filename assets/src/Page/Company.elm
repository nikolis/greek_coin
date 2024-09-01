module Page.Company exposing  (Model, Msg, init, subscriptions, toSession, update, view)

import Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (..)
import Page.Home.Naview as Nav
import Svg exposing (svg, rect)
import Svg.Attributes
import Page.Home.Packages exposing (viewGettingStarted)
import Page.Home.Packages as PackagesP

type alias Model =
    {
        session : Session
    ,   packagesModel : PackagesP.Model

    }

init : Session ->(Model, Cmd Msg) 
init session =
    let
        (modelPackages, cmdsPackages) = PackagesP.init session
        md = 
            {
                session = session
            ,   packagesModel = modelPackages
            }
    in
    (md, Cmd.none)

type Msg = 
    GotSession
    | PackageMsg PackagesP.Msg 


subscriptions : Model -> Sub Msg
subscriptions model=
  Sub.none

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = 
     case msg of
        PackageMsg servMsg ->
           let
               (serM, comSer) = PackagesP.update  servMsg model.packagesModel
           in
           ({model |packagesModel  = serM}, Cmd.map (\serCom -> (PackageMsg serCom)) comSer)
        GotSession ->
            (model, Cmd.none)

 

view : Model -> {title : String, content: Html Msg}
view model = 
    { title = "Company"
    , content =
       div[class ""]
        [ 
         div[style "margin-left" "-15px",style "background-image" "url(\"images/crupto_2.png\")", style "background-repeat" "no-repeat", style "background-size" "cover", style "margin-top" "-5px", style "padding-right" "100px"]
         [
             div[class "col", style "margin-right" "10vw"]
             [
              Nav.naview model.session 2
             ]
         , div[class "row"]
           [
               div[class "col", style "margin-left" "10vw"]
               [
                 span[style "font-size" "3rem", style "font-weight" "bold", style "color""white"][text "Company"]
               , br[][]
               , span[style "font-size" "2rem", style "color" "rgba(255,158,46,1)"][text "Let's schedule together"]
               , br[][]
               , span[style "font-size" "2rem", style "color" "rgba(255,158,46,1)"][text "your next step in Cryptocurrency"]
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
       , div[style "margin-top" "5vh", style "margin-bottom" "vh"]
         [
            
           div[class "container-fluid", style "margin-bottom" "5vh", style "margin-left" "-15px"]
         [
            div[class "row "]
            [
              div[class "col col-md-12 col-lg-11 col-xl-6"]
              [
                div[][img [src "/images/office.svg", style "width" "100%", style "height" "100%", style "float" "" , style "margin-top" "50px"][]]
              ]
            , div[class "col col-md-10 col-lg-11 col-xl-5", style "margin-left" "3vw", style "margin-right" "5vw", style "margin-top" "25px"]
              [
                span[class "header_text"][text "Stay secure with GreekCoin"]
              , br[][]
              , br[][]
              , span[style "font-size" "1.25rem"][text """GreekCoin is the first Cryptocurrency Exchange Targeting the Greek Market. Licensed and regulated by Estonian FIU, can provide cryptocurrency exchange and wallet services. You can stay safe with us, because we know how to respect our clients. With over 3 years in the field of cryptocurrencies, over 10 million Euros cryptocurrency transactions and over 2000 happy customers you can served by one of the best in the field."""
                 ]
              , br[][]
              , br[][]
              , span[style "font-size" "1.25rem"][text "We are here not only to buy, sell and exchange cryptocurrencies but we can help you with your first steps in the world of cryptos and provide you with answers in your quaries. Our expirienced support team can handle your questions and give you the answers that you can not find elsewhere."]
              ]
           ]
        ]
        , div[class "container-fluid", style "margin-bottom" "100px"]
        [
            div[class "row not-gutters"]
            [
              div[class "col col-md-10 col-lg-10 col-xl-5 order-sm-12 order-xs-12 order-md-12 order-lg-12 order-xl-1", style "margin-left" "3vw", style "margin-right" "5vw", style "margin-top" "25px" ]
              [
                span[class "header_text"][text "George Svarnas"]
              , br[][]
              , span[style "font-size" "1.5rem", style "color" "rgba(112,112,112,1)", style "font-weight" "550"][text "CEO GREEK COIN"]
              , br[][]
              , br[][]
              , span[style "font-size" "1.25rem"][text """Born in Athens Greece in 1988, Crypto enthousiast and beliver George is the founder, General Manager and CEO of GREEKCOIN Cryptocurrency Exchange. He has educated in the University of London as Computer Scienctist. Be in the field of cryptocurrencies from 2015, he knows what, an unexpirienced user in the cryptocurrencies, needs and wants and thats why he has founded the first Cryptocurrency Exchange Targeting the Greek Market. Targeting the European audience but especially the Greek market, he is trying to spread and educate the Greek audiance. He is also here to guarantee that you are provided with the best help you will need to your first steps in cryptos."""
                 ]
              , br[][]
              , br[][]
              , span[style "font-size" "1.25rem"][text "He is a Crypto HODLer and he thinks that the future of financial infrastracture is hidden in the blockchain technology"]
              ]
            ,  div[class "col col-md-12 col-lg-11 col-xl-6 order-sm-1 order-xs-1 order-md-1 order-xl-15 order-lg-1"]
              [
                div[][img [src "/images/ceo.jpg", style "width" "45rem", style "height" "35rem", style "float" "" ][]]
              ]
 
           ]
        ]
        , div[class "container", style "margin-bottom" "100px"]
        [ div[class "row no-gutters justify-content-center"]
          [
            div[class "col"][img[style "width" "15vw",src "images/quote.svg"][]]
          , div[class "col-8"]
            [
               span[style "color" "rgb(0, 99, 166)",style "font-size" "1.5rem" , style "font-weight" "bolder", style "text-shadow" "rgb(0, 99, 166) 1px 0px"][text "If something seems too good to be true, it probably is NOT true. None has became ritch in one day. Try to be patient, try to stay calm, try not to get affected by your emotions, try to HODL and multiply your cryptocurrencies."]
            , br[][]
            , br[][]
            , span[style "font-weight" "bolder", style "text-shadow" "rgba(68,68,68,1) 1px 0px", style "font-size" "1.25rem"][text "George Svarnas"]
            , br[style "margin-bottom" "1vh"][]
            , span[style "font-size" "1.25rem", style "color" "rgba(112,112,112,1)"][text "CEO GREEK COIN"]
            ]
          ]
        ]
       , div[class "container-fluid", style "margin-bottom" "50px"]
         [
             div[class "row"]
               (List.map(\arg -> Html.map(\packMsg -> PackageMsg packMsg) arg) (PackagesP.viewGettingStarted))

         ]
       ]
     ]
       
    }

toSession : Model -> Session
toSession model = 
    model.session
