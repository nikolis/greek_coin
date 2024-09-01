module Page.Home.Pros exposing (Model, Msg, init, update, view)

import Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (..)
import Asset


type alias Model = 
    {
        session: Session
    }

init: Session -> (Model, Cmd Msg)
init session = 
    let
        md = 
          { session = session 
          }
    in
    (md, Cmd.none)

type Msg =
    GotSession Session



update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        GotSession sess->
            ({model | session = sess}, Cmd.none)


view : Model -> Html Msg
view model = 
   div[style "margin-bottom" "8vh", class "container-lg"]
   [
       h1[style "color" "rgba(0,99,166,1)",style "font-weight" "bold", style "text-shadow" "2px 0 rgba(0, 99, 166, 1)"][text "Why Greek Coin"]
   ,   p[style "font-size" "1.25rem"]
       [ span[][text "We are trading Cryptocurrencies with the largest market capitalization of the market."]
       , br[][]
       , span[][text " Available instantly."]
       ]
   ,   viewCards 
   ]


viewCards : Html Msg
viewCards =
  div[]
  [
  div[class "card-deck", style "margin-bottom" "5vh"]
  [
    div[class "card", style "display" "flex", style "border-style" "none"]
    [
        div[class "row"]
        [
            div[class "col-md-4 align-self-center"]
            [
               img [Asset.src Asset.piggie, class "card-img ", style "margin" "auto"][]
            ]
        ,   div[class "col-md-8"]
            [
                div[class "card-body", style "padding" "0rem"]
                [
                    h5[class "card-title", style "margin-bottom" "4vh", style "font-weight" "bold"]
                    [
                        text "Earn Cryptocurrencies"
                    ]
                ,   p[class "card-text" ]
                    [text "You can earn more cryptocurrencies, simply by storing your cryptocurrencies in our platform and even through our Referal program. Make the most of your holdings with us."
                    ]
                ]
            ]    
        ]
    ]
  ,  div[class "card mb-3", style "border-style" "none"]
    [
        div[class "row"]
        [
            div[class "col-md-4 align-self-center"]
            [
               img [Asset.src Asset.bank, class "card-img"][]
            ]
        ,   div[class "col-md-8"]
            [
                div[class "card-body", style "padding" "0rem"]
                [
                    h5[class "card-title", style "margin-bottom" "4vh", style "font-weight" "bold"]
                    [
                        text "Pay by Bank Account"
                    ]
                ,   p[class "card-text" ]
                    [text "You can deposit Euros by simply using your bank account. We are also offering payments with cash in our office. More payment methods to be added soon."
                    ]
                ]
            ]    
        ]
    ]
 
  
  ]
  ,  div[class "card-deck", style "margin-bottom" "5vh"]
  [
    div[class "card mb-3", style "border-style" "none"]
    [
        div[class "row no-gutters"]
        [
            div[class "col-md-4 align-self-center"]
            [
               img [Asset.src Asset.guard, class "card-img"][]
            ]
        ,   div[class "col-md-8"]
            [
                div[class "card-body", style "padding" "0rem"]
                [
                    h5[class "card-title", style "margin-bottom" "4vh", style "font-weight" "bold"]
                    [
                        text "We are Licensed and Regulated"
                    ]
                ,   p[class "card-text" ]
                    [text "Our company is licensed from European Union, Republic of Estonia, Estonian Financial Inteligence Unit. You can feel safe trading with us."
                    ]
                ]
            ]    
        ]
    ]
  ,  div[class "card mb-3", style "border-style" "none"]
    [
        div[class "row no-gutters"]
        [
            div[class "col-md-4 align-self-center"]
            [
               img [Asset.src Asset.hands, class "card-img"][]
            ]
        ,   div[class "col-md-8"]
            [
                div[class "card-body", style "padding" "0rem"]
                [
                    h5[class "card-title", style "margin-bottom" "4vh", style "font-weight" "bold"]
                    [
                        text "We are here to help you We speak your Language"
                    ]
                ,   p[class "card-text" ]
                    [text "Our company is licensed from European Union, Republic of Estonia, Estonian Financial Inteligence Unit. You can feel safe trading with us."
                    ]
                ]
            ]    
        ]
    ]
 
  
  ]
  ,  div[class "card-deck", style "margin-bottom" "5vh"]
  [
    div[class "card mb-3", style "border-style" "none"]
    [
        div[class "row no-gutters"]
        [
            div[class "col-md-4 align-self-center"]
            [
               img [Asset.src Asset.bitcoinN, class "card-img"][]
            ]
        ,   div[class "col-md-8"]
            [
                div[class "card-body", style "padding" "0rem"]
                [
                    h5[class "card-title", style "margin-bottom" "4vh", style "font-weight" "bold"]
                    [
                        text "Offering the most popular Cryptocurrencies"
                    ]
                ,   p[class "card-text" ]
                    [text "We are offering instantly, the most popular cryptocurrencies with the largest capitalisation in the market."
                    ]
                ]
            ]    
        ]
    ]
  ,  div[class "card mb-3", style "border-style" "none"]
    [
        div[class "row no-gutters"]
        [
            div[class "col-md-4 align-self-center"]
            [
               img [Asset.src Asset.card, class "card-img"][]
            ]
        ,   div[class "col-md-8"]
            [
                div[class "card-body", style "padding" "0rem"]
                [
                    h5[class "card-title", style "margin-bottom" "4vh", style "font-weight" "bold"]
                    [
                        text "Low Fees, No Hidden Costs"
                    ]
                ,   p[class "card-text" ]
                    [text "Our service fees are low and described clearly in our fee table. We do not have any hidden costs. You get notified about the exact amount you will receive and the exact fee you will pay before confirming any transaction."
                    ]
                ]
            ]    
        ]
    ]
 
  
  ]
  ]

