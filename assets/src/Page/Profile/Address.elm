module Page.Profile.Address exposing (..)

import Session exposing (Session)
import Route 
import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Json.Decode exposing (list, string, Decoder, field, map5, decodeString, errorToString, nullable, int)
import Json.Decode.Pipeline
import Http
import Api2.Happy exposing (getBaseUrl)
import Api2.Data exposing (User, decoderUser, Currency, decoderCurrency)
import Paginate exposing (..)
import List.Extra 
import Api

type alias Model = 
    {
        session : Session
    ,   content : Status (PaginatedList Address)
    ,   expanded : Bool
    }

init : Session -> (Model, Cmd Msg)
init session =
    let
        md =  
            { 
                session = session
            ,   content = Loading
            ,   expanded = False
            }
    in
    (md, getAddresses session 1)


type Status a                  
    = Loading
    | LoadingSlowly            
    | Loaded a
    | Failed String

type Msg =
    GotSession Session
    | GotAddresses (Result Http.Error (AddressList))
    | Next
    | Prev
    | First
    | Last
    | GoTo Int
    | Expand Bool

type alias Address = 
    {
      id : Int
    , public_key : String
    , additional_info : Maybe String
    , currency : Currency
    , status : Bool
    }

decoderAddress : Json.Decode.Decoder Address
decoderAddress =
    Json.Decode.succeed Address
    |> Json.Decode.Pipeline.required "id" Json.Decode.int
    |> Json.Decode.Pipeline.required "public_key" Json.Decode.string
    |> Json.Decode.Pipeline.required "additional_info" (nullable Json.Decode.string)
    |> Json.Decode.Pipeline.required "currency" decoderCurrency
    |> Json.Decode.Pipeline.required "active" Json.Decode.bool
type alias AddressList  = 
    {
        data : List Address
    }

decoderAddressList : Json.Decode.Decoder AddressList
decoderAddressList =
    Json.Decode.succeed AddressList
    |> Json.Decode.Pipeline.required "data" (Json.Decode.list decoderAddress)

getAddresses : Session -> Int-> Cmd Msg
getAddresses session id =
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
    , url = (getBaseUrl ++ "/api/v1/provided/wallet")
    , expect = Http.expectJson GotAddresses decoderAddressList
    , timeout = Nothing
    , tracker = Nothing
    }




view : Model -> Html Msg
view model = 
    div[class "col"]
    [
       pricesTableExpanded model 10 
    ]

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = 
    case msg of

       GotSession session ->
            ({model | session = session}, Cmd.none)

       GotAddresses (Ok addresses) ->
            ({model | content = Loaded (Paginate.fromList 10 addresses.data)}, Cmd.none)

       GotAddresses (Err error) ->
            let
                _ = Debug.log "error" error
            in
            ({model | content = Failed (Debug.toString error)}, Cmd.none) 

       Next ->
           case model.content of 
               Loaded thingsM ->
                 ({ model | content = Loaded (Paginate.next thingsM) }, Cmd.none)
               _ -> 
                 (model, Cmd.none)

       Prev ->
           case model.content of 
               Loaded thingsM ->
                 ({ model | content = Loaded (Paginate.prev thingsM) }, Cmd.none)
               _ -> 
                 (model, Cmd.none)

       First ->
           case model.content of 
               Loaded thingsM ->
                 ({ model | content = Loaded (Paginate.first thingsM) }, Cmd.none)
               _ -> 
                 (model, Cmd.none)

       Last ->
           case model.content of 
               Loaded thingsM ->
                 ({ model | content = Loaded (Paginate.last thingsM) }, Cmd.none)
               _ -> 
                 (model, Cmd.none)

       GoTo index ->
           case model.content of 
               Loaded thingsM ->
                 ({ model | content = Loaded (Paginate.goTo index thingsM) }, Cmd.none)
               _ -> 
                 (model, Cmd.none)

       Expand var ->
           ({model| expanded = var}, Cmd.none)

subscriptions : Model -> Sub Msg
subscriptions model = 
    Sub.batch
    [
        Session.changes GotSession (Session.navKey model.session)
    ]


pricesTableExpanded : Model -> Int -> Html Msg
pricesTableExpanded  model size= 
    case model.content of 
        Loaded pairsU ->
          let
             pairs = Paginate.page pairsU

             prevButtons =
               button 
                 [
                  style "border-style" "none"
                 , style "background-color" "white"
                 , onClick First
                 , style "font-weight" "bolder"
                 , style "background-color" "transparent"
                 , style "pading" "1rem"
                 , style "border-style" "none"
                 , style "font-size" "1.25rem"

                 , disabled <| Paginate.isFirst pairsU
                 ] 
                 [ text "Previous" ]
              

             nextButtons =
              [ button 
                [
                  style "border-style" "none"
                , style "background-color" "white"
                , onClick Next
                , style "font-weight" "bolder"
                , style "background-color" "transparent"
                , style "pading" "1rem"
                , style "border-style" "none"
                , style "font-size" "1.25rem"
                , disabled <| Paginate.isLast pairsU ] [ text "Next" ]
              ]

             pagerButtonView index isActive =
                button
                  [ style "color"
                    (if isActive then
                        "rgba(0,99,166,1)"

                     else
                        "rgba(68,68,68,1)"
                    )
                  , style "text-shadow"
                    (if isActive then
                        "1px 0 rgba(0,99,166,1)"

                     else
                        "1px 0 rgba(68,68,68,1)"
                    )
                  , style "border-radius"
                    (if isActive then
                        "80px"

                     else
                        ""
                    )
                  , style "background-color"
                    (if isActive then
                        "white"

                     else
                        "transparent"
                    )
                  , style "font-weight" "bolder"
                  , style "padding" "0.2rem 0.8rem"
                  , style "border-style" "none"
                  , style "font-size" "1.25rem"
                  , onClick <| GoTo index
                  ]
                 [ text <| String.fromInt index ]
             pagerOptions =
                { innerWindow = 1
                , outerWindow = 1
                , pageNumberView = pagerButtonView
                , gapView = text "..."
                }
          in
          div[class "container price_table_expanded", style "margin-bottom" "100px", style "border-radius" "10px"]
          [
            table[class "table table-hover", style "elavation" "2px"]
              [
                  thead[]
                  [
                    tr[]
                    [
                        th[class "price_table_expanded_header", style "padding" "1.5rem"][span[][text "Cryptocurrency"]]
                    {--,   th[class "price_table_expanded_header", style "padding" "1.5rem"][span[][text "Currency"]]--}
                    ,   th[class "price_table_expanded_header", style "padding" "1.5rem"][span[][text "Status"]]
                    ,   th[class "price_table_expanded_header", style "padding" "1.5rem"][span[][text "Wallet Address"]]
                    ]
                  ]
              ,   tbody[]
                  (List.map (\assetPair -> tr[ ]
                   [
                       td[style "padding" "2rem"]
                       [
                           img[Html.Attributes.src assetPair.currency.url, style "margin-right" "1vw"][]
                       ,   span[class "price_table_expanded_main_field"][text assetPair.currency.alias_]
                       ,   span[style "text-transform" "uppercase", style "font-size" "1", style "color" "rgba(112,112,112,1)"][text ("("++ assetPair.currency.alias_sort ++ ")")]
                       ]
                   {--,   td[style "padding" "2rem"][
                              span[class "price_table_expanded_main_field"][text (String.fromInt assetPair.id)]
                          ]--}
                   ,   td[style "padding" "2rem"][span[style "color" "rgba(255,102,51,1)"][text ( case assetPair.status of
                         True ->
                             "Active"
                         False ->
                             "Revoked")]]
                   ,   td[style "padding" "2rem"][span[style "color" "rgba(255,102,51,1)"][text assetPair.public_key]]
                   ]) pairs
                  )
               ]
              , div[style "border-top"  "1px solid #dee2e6",class "row justify-content-center"]
                [
                  ( case model.expanded of
                      False ->
                        div[class "col-2", style "border-top"  "1px solid #dee2e6", style "padding-top" "50px", style "padding-bottom" "10px"]
                        [
                          button[onClick (Expand True),style "display" "table",style "margin" "auto", class "btn btn-outline-primary", style "border-radius" "50px", style "padding" "10px 20px"][span[style "color" "rgba(0,99,166,1)",style "font-weight" "bold"][text "VIEW MORE"]]
                        ]
                      True ->
                        div[class "col-4",  style "padding-top" "50px", style "padding-bottom" "10px"]
                        [
                            div[style "background-color" "rgb(239, 239, 239)", style "border-radius" "50px", style "padding" "5px", class "row justify-content-center"]
                            [
                                div[class "col"][prevButtons]
                            ,   div[class "col"][(span [style "bakground-color" "rgb(239, 239, 239)"] <| Paginate.elidedPager pagerOptions pairsU)]
                            ,   div[class "col"]nextButtons
                            ]
                        ]
                      )
                ]
            ]
        _ ->
            div[][]

