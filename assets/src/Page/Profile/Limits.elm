module Page.Profile.Limits exposing (..)

import Session exposing (Session)
import Route 
import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Json.Decode exposing (list, string, Decoder, field, map5, decodeString, errorToString, nullable, int)
import Json.Decode.Pipeline
import Http
import Api2.Happy exposing (getBaseUrl)
import Api2.Data exposing (User, Address, decoderUser, Currency)
import Api

type alias Model = 
    {
        session : Session
    ,   user : Status User 
    }

init : Session -> (Model, Cmd Msg)
init session =
    let
        md =  
            { 
                session = session
            ,   user = Loading
            }
    in
    (md, fetchUser session)


fetchUser : Session -> Cmd Msg
fetchUser session = 
    Http.request
    {
          headers =
         case Session.cred session of
             Just cred ->
                 [ Api.credHeader cred]
             Nothing ->
                 []

    , method = "GET"
    , body = Http.emptyBody
    , url = (getBaseUrl ++ "/api/v1/self")
    , expect = Http.expectJson GotUser decoderUser
    , timeout = Nothing
    , tracker = Nothing
    }

type Status a                  
    = Loading
    | LoadingSlowly            
    | Loaded a
    | Failed String

type Msg =
    GotSession Session
    | GotUser (Result Http.Error User)

view : Model -> Html Msg
view model = 
    div[class "col"]
    [
        h1[][text "Account Limits"]
    ,   viewLimits model
    ]

viewLimits : Model -> Html Msg
viewLimits model = 
    case model.user of 
        Loaded usr ->
             limitsTable usr 
        _ ->
            div[][text "ni user"]

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = 
    case msg of

        GotSession session ->
            ({model | session = session}, Cmd.none)

        GotUser (Ok user) ->
            ({model | user = Loaded user}, Cmd.none)

        GotUser (Err error) ->
            ({model | user = Failed (Debug.toString error)}, Cmd.none)


subscriptions : Model -> Sub Msg
subscriptions model = 
    Sub.batch
    [
        Session.changes GotSession (Session.navKey model.session)
    ]
    
limitsTable : User -> Html Msg
limitsTable  user= 
          let
              level = staticArray user.clearanceLevel
          in
          div[class "container-xxl", style "margin-bottom" "100px", style "border-radius" "10px"]
          [
            table[class "table table-hover", style "margin-bottom" "0px"]
              [
                  thead[]
                  [
                    tr[]
                    [
                        th[class "price_table_header", style "padding-top" "0rem"][span[style "color" "rgba(112,112,112,1)"][]]
                    ,   th[class "price_table_header", style "padding-top" "0rem"][span[style "color" "rgba(112,112,112,1)"][text "SEPA Deposit"]]
                    ,   th[class "price_table_header", style "padding-top" "0rem"][span[style "color" "rgba(112,112,112,1)"][text "SEPA Withdrawal"]]
                    ,   th[class "price_table_header", style "padding-top" "0rem"][span[style "color" "rgba(112,112,112,1)"][text "Deposit Crypto"]]
                    ,   th[class "price_table_header", style "padding-top" "0rem"][span[style "color" "rgba(112,112,112,1)"][text "Withdrwal Crypto"]]

                    ]
                  ]
              ,   tbody[]
                   [
                     tr[]
                     [
                       td[style "padding" "1.4rem"]
                       [
                          span[class "price_table_main_field"][text "MONTHLY"]
                       ]
                   ,   td[style "padding" "1.4rem"]
                        [
                            span[class "price_table_main_field"][text level.first.first]
                        ]
                   ,   td[style "padding" "1.4rem"]
                        [
                            span[class "price_table_main_field"][text level.first.second]
                        ]
                   ,   td[style "padding" "1.4rem"]
                        [
                            span[class "price_table_main_field"][text level.first.third]
                        ]
                   ,   td[style "padding" "1.4rem"]
                        [
                            span[class "price_table_main_field"][text level.first.forth]
                        ]
                     ]
                   , tr[]
                     [
                      td[style "padding" "1.4rem"]
                        [
                            span[class "price_table_main_field"][text "ANNUALLY"]
                        ]

                   ,   td[style "padding" "1.4rem"]
                       [
                          span[class "price_table_main_field"][text level.second.first]
                       ]
                   ,   td[style "padding" "1.4rem"]
                        [
                            span[class "price_table_main_field"][text level.second.second]
                        ]
                   ,   td[style "padding" "1.4rem"]
                        [
                            span[class "price_table_main_field"][text level.second.third]
                        ]
                   ,   td[style "padding" "1.4rem"]
                        [
                            span[class "price_table_main_field"][text level.second.forth]
                        ]
                     ]

                   ]
                  
               ]
            ]

type alias Row =
    {
        first : String
    ,   second : String
    ,   third : String
    ,   forth : String
    }

type alias Level = 
    {
        first: Row
    ,   second: Row
    }

staticArray : Int -> Level
staticArray level= 
    case level of
        2 ->
            Level (Row "15000"  "15000" "15000" "15000") (Row "180000" "180000" "180000" "180000")
        1 ->
            Level (Row "5000"  "5000"  "5000"  "10000") (Row "50000" "50000" "50000" "100000")
        _ ->
            Level (Row "0" "0" "0" "0") (Row "0" "0" "0" "0")


