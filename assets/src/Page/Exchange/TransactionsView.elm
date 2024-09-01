module Page.Exchange.TransactionsView exposing (dropDown, viewPackages, pricesTable, pricesTableExpanded, view, viewModal, getUserAssets, getUserAssets2, currencyTableExpanded)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Page.Exchange.Transactions as TransactionsMain
  exposing (Msg(..), PackageButtonMode(..), Model, Status(..), AssetPairCurrencyAnimation, AssetPairCurrency, ActionWindow(..), getPriceFromCurrencyView, ModalState(..),findCurrencyPrice, findCurrencyChange) 
import Bootstrap.Modal as Modal
import Bootstrap.Button as Button
import Bootstrap.Grid as Grid
import Bootstrap.Dropdown as Dropdown
import Api2.Data exposing (Currency, AssetMetaInfo, Action, ExchangeRequestResponse,TransactionRequest, KrakenMetaResponse, CurrencyResponse, KrakenResponse, decoderKraken, AssetPairInfo, dataDecoder)
import Round
import Api2.Data exposing (Withdraw)
import Api.Data exposing (Treasury)
import Paginate exposing (..)
import List.Extra as LE 
import Animation exposing (px)

{----------------------------VIEW -----------------}
view : Model -> PackageButtonMode -> Html Msg
view model buttonMode =
    binanceView model buttonMode


binanceView : Model ->  PackageButtonMode ->Html Msg
binanceView model buttonMode =
    div[class "container", style "background-color" "white", style "border-radius" "10px", style "padding-top" "2.5vh", style "padding-bottom" "3vh", style "box-shadow" "8px 8px 16px 8px rgba(0.2,0.2,0.2,0.2)"]
    [
      div[class "row"]
      [
       div[class "col"]
        [
          div[class "row"]
          [
           div[class ("col "++ getClassCol model Buy), style "padding-left" "3vw", style "margin-left" "1vw"][a[href "#pageSubmenu", class (getClass model Buy), type_ "button",onClick (ChangeWindow Buy)][span[][text "Buy"]]]
         , div[class ("col "++ getClassCol model Sell), style "padding-left" "2.5vw"][ a[href "#pageSubmenu", class (getClass model Sell), type_ "button",onClick (ChangeWindow Sell)][text "Sell"]]
         , div[class ("col "++ getClassCol model Exchange),style "padding-left" "1.5vw", style "padding-right" "3.5vw", style "margin-right" "1vw"][ a[href "#pageSubmenu", class (getClass model Exchange), type_ "button",onClick (ChangeWindow Exchange)][text "Exchange"]]
         ]
        ]
      ]
     , div[class "row", style "padding-top" "2.5vh"]
      [
        div[class "col"][exchangeView model.assetPairsCurr model buttonMode]
       ]
    ]

getClassCol: Model -> ActionWindow -> String
getClassCol model action =
    case (model.window == action) of
        True ->
            "panel_col active"
        False ->
            "panel_col"


getClass: Model -> ActionWindow -> String
getClass model action =
    case (model.window == action) of
        True ->
            "panel_button active"
        False ->
            "panel_button"


getLabelTop : ActionWindow -> String
getLabelTop actionWindow = 
    case actionWindow of
        Buy ->
            "I want to Spend"
        Sell ->
            "I want to Get"
        Exchange -> 
            "I want to Give"


getLabelBottom : ActionWindow -> String
getLabelBottom actionWindow =
    case actionWindow of
        Buy ->
            "I want to Buy"
        Sell ->
            "I want to Sell"
        Exchange ->
            "I want to Get"

disabledIn : ActionWindow -> Int -> Bool
disabledIn actionWindow numb = 
    case actionWindow of
        Buy ->
            case numb of
                2 ->
                    True
                _ ->
                    False
        Sell ->
             case numb of
                2 ->
                    False
                _ ->
                    True
 
        Exchange ->
              case numb of
                2 ->
                    True
                _ ->
                    False



exchangeView : Status (List AssetPairCurrencyAnimation)  -> Model   -> PackageButtonMode -> Html Msg
exchangeView statusAssetPairCurrency model buttonMode=
    case statusAssetPairCurrency of
       Loaded statusAssetPairs ->
                   let
                       assetPairs =
                         case model.window of
                             Exchange ->
                                 let
                                     listAll = List.filter (\assetPair -> not (String.contains "EUR" assetPair.pair.quote.title )) statusAssetPairs
                                 in
                                 listAll 
                             _ ->
                                 let
                                    subList = List.filter (\assetPair -> (String.contains "EUR" assetPair.pair.quote.title))  statusAssetPairs
                                 in
                                    case model.config of
                                        Just configuration ->
                                            let
                                              subListFilt = List.filter (\assetPair -> (assetPair.pair.base.id  == configuration.currencyId)) subList
                                            in
                                            case List.head subListFilt of
                                               Just asPair ->
                                                  asPair::subList 
                                               Nothing ->
                                                   subList
                                        Nothing ->
                                            subList
                       assetPairsTo = 
                           case model.first of 
                               Just str ->
                                  List.filter (\assetPair -> assetPair.pair.base == str) assetPairs
                               Nothing ->
                                  assetPairs

                       assetPairsReady = LE.uniqueBy (\assetPair -> assetPair.pair.base.title) assetPairs
                       assetPairsToReady = LE.uniqueBy (\assetPair -> assetPair.pair.primaryName) assetPairsTo
                   in
                      div[]
                      [  
                        div[style "border" "1px solid rgba(239,239,239,1)", style "border-radius" "10px", class "form-row"]
                            [
                              div[class "form-group col", style "padding-right" "0", style "margin" "0px"]
                              [
                                label[style "padding-left" "0.5rem", style "padding-top" "0.5rem", style "margin-bottom" "0px"][span[style "color" "rgba(112,112,112,1)", style "font-size" "1.25rem", style "font-weight" "bold", style "text-shadow" "1px 0 rgba(112,112,112,1)"][text (getLabelTop model.window)]]
                              , input [class "form-control", style "width" "100%", style "font-size" "1.5rem", style "color" "rgba(0,99,166,1)" ,style "font-weight" "bold",Html.Attributes.value model.toNumberString, onInput ChangeToNumb, style "border-style" "none", style "text-shadow" "1px 0 rgba(0,99,166,1)", style "padding-top" "0rem", disabled (disabledIn model.window 1), style "background-color" "transparent"][]
                              ]
                            , div[class "form-group-append col-lg-auto col-xs-auto col-sm-auto col-md-auto col-xl-auto", style "padding-right" "0"]
                              [
                                viewCurrencyDropDownSecond assetPairsToReady  model
                              , node "editor-select" [][]
                              ]
                            ]
                      , div[style "border" "1px solid rgba(239,239,239,1)", style "border-radius" "10px", class "form-row", style "margin-top" "2vh"]
                            [
                            div[class "form-group col", style "margin" "0px"] 
                              [
                                label[style "padding-left" "0.5rem", style "padding-top" "0.5rem", style "margin-bottom" "0px", style "color" "rgba(112,112,112,1)", style "font-size" "1.25rem", style "font-weight" "bold", style "text-shadow" "1px 0 rgba(112,112,112,1)"][text (getLabelBottom model.window)]
                              , input[class "form-control", style "width" "100%",style "font-size" "1.5rem", style "color" "rgba(0,99,166,1)" ,style "font-weight" "bold",Html.Attributes.value  model.fromNumberString, onInput ChangeFromNumbHand, disabled (disabledIn model.window 2), style "border-style" "none", style "text-shadow" "1px 0 rgba(0,99,166,1)", style "padding-top" "0rem", style "background-color" "transparent"][]
                              ]
                            , div[class "form-group-append col-lg-auto col-xs-auto col-sm-auto col-md-auto col-xl-auto", style "padding-right" "0"]
                                [
                                  viewCurrencyDropDownIcon assetPairsReady model
                                ]
                              ]
                            
                      , div[style "pading-bottom" "4vh", style "padding-top" "4vh", style "width" "30%", style "margin" "auto"]
                        [
                            case buttonMode of 
                                LoginMode ->
                                    button [type_ "button", style "width" "100%" , style "margin" "auto", style "padding" "10px 3px", onClick ToLoginPage, class "btn btn-primary primary_button"]
                                    [ span[][text "NEXT"] ]
                                ScrollBuyMode  ->
                                   button [type_ "button", style "width" "100%" , style "margin" "auto", style "padding" "10px 3px", onClick SendRequest, class "btn btn-primary primary_button"]
                                   [ span[][text "NEXT"] ]
                        ]
                      ]
       _ ->
         div[][span [][text "No Content" ]]

viewCurrencyDropDownSecond : List AssetPairCurrencyAnimation -> Model -> Html Msg
viewCurrencyDropDownSecond  assetPairs model =
    case model.second of
        Just currency ->
                 Dropdown.dropdown
                    model.myDrop2State
                     { options = [ Dropdown.attrs[style "width" "100%", style "height" "100%"], Dropdown.alignMenuRight ]
                      , toggleMsg = MyDrop2Msg
                      , toggleButton =
                          Dropdown.toggle [Button.attrs [style "background-color" "rgba(239,239,239,1)", style "width" "100%", style "content" "none"], Button.block] 
                                        [
                                          div[class "container"]
                                            [
                                                div[class "row"]
                                                [
                                                    div[class "col"]
                                                    [
                                                        div[class "row"]
                                                        [
                                                            div[class "col ", align "start"]
                                                            [
                                                               label[style "padding" "0px", style "margin" "0px"][span[style "color" "rgba(112,112,112,1)", style "font-size" "1.25rem", style "font-weight" "bold", style "text-shadow" "1px 0 rgba(112,112,112,1)"][text currency.alias_]] 
                                                            ]
                                                       ]
                                                    ,  div[class "row no-gutters"]
                                                      [
                                                          div[class "col-2 ", style "height" "1.3rem", style "margin-top" "5px", align "start"]
                                                          [
                                                            img [src currency.url, style "height" "1.3rem"][]
                                                          ]
                                                      ,   div[class "col", align "start"]
                                                          [
                                                            span[style "margin-left" "15%",style "color" "rgba(0,99,166,1)",style "font-size" "150%", style "font-weight" "bold", style "text-align" "start", style "text-transform" "uppercase", style "text-shadow" "1px 0 rgba(0,99,166,1)"] [ text currency.alias_sort ]
                                                          ]
                                                      ]
                                                    ]
                                                ,  div[class "col-2 align-self-center"]
                                                   [
                                                       img[src "images/arrow-down.svg",style "width" "15px"][]
                                                   ]
                                                ]
                                            ]
 
                                        ]
                      , items = (List.map (\assetPair -> Dropdown.buttonItem [style "color" "rgba(0,99,166,1)",style "font-size" "1.25rem",style "font-weight" "bold", onClick (SecondSet assetPair.pair.quote)][img [style "margin-right" "1vw",src assetPair.pair.quote.url][], text assetPair.pair.quote.alias_]) assetPairs)
                     }
        Nothing ->
             div[][text "den"]





viewCurrencyDropDownIcon : List AssetPairCurrencyAnimation -> Model  -> Html Msg
viewCurrencyDropDownIcon  assetPairs model =
    case model.first of
        Just currency ->
                 Dropdown.dropdown
                    model.myDrop1State
                     { options = [  Dropdown.attrs[style "width" "100%", style "height" "100%"] ]
                      , toggleMsg = MyDrop1Msg
                      , toggleButton =
                          Dropdown.toggle [Button.attrs [style "background-color" "rgba(239,239,239,1)"]] 
                          [
                                             div[class "container"]
                                            [
                                                div[class "row"]
                                                [
                                                    div[class "col"]
                                                    [
                                                        div[class "row"]
                                                        [
                                                            div[class "col", align "start"]
                                                            [
                                                               label[style "padding" "0px", style "margin" "0px"][span[style "color" "rgba(112,112,112,1)", style "font-size" "1.25rem", style "font-weight" "bold", style "text-shadow" "1px 0 rgba(112,112,112,1)"][text currency.alias_]] 
                                                            ]
                                                       ]
                                                    ,  div[class "row  no-gutters"]
                                                      [
                                                          div[class "col-2 no-gutters", style "height" "1.3rem", style "margin-top" "5px", align "start"]
                                                          [
                                                            img [src currency.url, style "height" "1.3rem"][]
                                                          ]

                                                      ,   div[class "col", align "start"]
                                                          [
                                                            span[style "margin-left" "15%",style "color" "rgba(0,99,166,1)",style "font-size" "150%", style "font-weight" "bold", style "text-align" "start", style "text-transform" "uppercase", style "text-shadow" "1px 0 rgba(0,99,166,1)"] [ text currency.alias_sort ]
                                                          ]
                                                      ]
                                                    ]
                                                ,  div[class "col-2 align-self-center"]
                                                   [
                                                       img[src "images/arrow-down.svg",style "width" "15px"][]
                                                   ]
                                                ]
                                          ]
                          ]
                      , items = (List.map (\assetPair -> Dropdown.buttonItem [style "color" "rgba(0,99,166,1)",style "font-size" "1.25rem",style "font-weight" "bold", onClick (FirstSet assetPair.pair.base)][img [style "margin-right" "1vw",src assetPair.pair.base.url][], text assetPair.pair.base.alias_]) assetPairs)
                     }
        Nothing ->
             div[][text "den"]



{----------------------------Prices TABLE --------------}
pricesTable : Model -> Int -> Html Msg
pricesTable  model size= 
    case model.assetPairsCurr of 
        Loaded pairsUnf ->
          let
             pairsOld = List.filter (\pair -> String.contains "EUR" pair.pair.quote.alias_sort) pairsUnf
             (pairs, _) = LE.splitAt size pairsOld
          in
          div[class "container", style "margin-bottom" "100px", style "border-radius" "10px"]
          [
            table[class "table table-hover", style "margin-bottom" "0px"]
              [
                  thead[]
                  [
                    tr[]
                    [
                        th[class "price_table_header text-center", style "width" "40%", style "padding-top" "0rem"][span[style "color" "rgba(112,112,112,1)"][text "Name"]]
                    ,   th[class "price_table_header", style "padding-top" "0rem"][span[style "color" "rgba(112,112,112,1)"][text "Last Price"]]
                    ,   th[class "price_table_header", style "padding-top" "0rem"][span[style "color" "rgba(112,112,112,1)"][text "24h Change"]]
                    ]
                  ]
              ,   tbody[]
                  (List.map (\assetPair -> tr[style "padding" "50px" ]
                   [
                       td[style "padding" "1.4rem"]
                       [
                          img[Html.Attributes.src assetPair.pair.base.url, style "margin-right" "1vw"][]
                       ,  span[class "price_table_main_field"][text assetPair.pair.base.alias_]
                       ,  span[style "text-transform" "uppercase", style "font-size" "1rem", style "color" "rgba(112,112,112,1)"][text ("("++ assetPair.pair.base.alias_sort ++ ")")]
                       ]
                   ,   td[style "padding" "1.4rem",style "font-size" "1.2rem", style "font-weight" "bold"][
                         ( case getPriceFromCurrencyView model assetPair.pair Buy 1 True of
                            Just som -> 
                              span([class "price_table_main_field" ]++ Animation.render assetPair.animation) [text ((String.fromFloat som) ++ " €")]
                            Nothing ->
                              span[class "price_table_main_field"][text "N/A"]
                          )]

                   , (case String.contains "-" (findCurrencyChange assetPair.pair model) of
                       False ->
                          td[style "padding" "1.4rem"][img[src "images/up-price.svg",style "width" "1rem", style "height" "1rem"][] ,span[class "price_table_main_field",style "color" "rgba(58,214,160,1)"][text (findCurrencyChange assetPair.pair model)]]
                       True ->
                          td[style "padding" "1.4rem"][img[src "images/down-price.svg",style "width" "1rem", style "height" "1rem"][], span[class "price_table_main_field",style "color" "rgba(255,102,51,1)"][text (findCurrencyChange assetPair.pair model)]]
                      )
                   ]) pairs
                  )
               ]
              , div[class "row"]
                [
                    div[class "col", style "border-top"  "1px solid #dee2e6", style "padding-top" "50px", style "padding-bottom" "10px"]
                    [{--
                     button[style "border" "solid 3px rgba(0,99,166,1)",style "display" "table",style "margin" "auto", class "btn btn-outline-primary", style "border-radius" "50px", style "padding" "10px 20px"][span[style "color" "rgba(0,99,166,1)",style "font-weight" "bold"][text "VIEW MORE"]]--}
                    ]
                ]
            ]
        _ ->
          div[][]



{-------------------------- PRICE TABLE  EXPANDED-----------------}
pricesTableExpanded : Model -> Int -> Html Msg
pricesTableExpanded  model size= 
    case model.things of 
        Loaded pairsUnf ->
          let
             pairsOld = List.filter (\pair -> String.contains "EUR" pair.quote.alias_sort) (Paginate.page pairsUnf)
             (pairs, _) = LE.splitAt size pairsOld

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

                 , disabled <| Paginate.isFirst pairsUnf 
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
                , disabled <| Paginate.isLast pairsUnf ] [ text "Next" ]
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
                        th[class "price_table_expanded_header", style "padding" "1.5rem"][span[][text "Name"]]
                    ,   th[class "price_table_expanded_header", style "padding" "1.5rem"][span[][text "Last Price"]]
                    ,   th[class "price_table_expanded_header", style "padding" "1.5rem"][span[][text "24h Change"]]
                    ]
                  ]
              ,   tbody[]
                  (List.map (\assetPair -> tr[ ]
                   [
                       td[style "padding" "2rem"]
                       [
                           img[Html.Attributes.src assetPair.base.url, style "margin-right" "1vw"][]
                       ,   span[class "price_table_expanded_main_field"][text assetPair.base.alias_]
                       ,   span[style "text-transform" "uppercase", style "font-size" "1", style "color" "rgba(112,112,112,1)"][text ("("++ assetPair.base.alias_sort ++ ")")]
                       ]
                   ,   td[style "padding" "2rem"][
                         ( case getPriceFromCurrencyView model assetPair Buy 1 True of
                            Just som -> 
                              span[class "price_table_expanded_main_field"][text ((String.fromFloat som) ++ " €")]
                            Nothing ->
                              span[class "price_table_expanded_main_field"][text "N/A"]
                          )]
                   ,   td[style "padding" "2rem"][span[style "color" "rgba(255,102,51,1)"][text (findCurrencyChange assetPair model)]]
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
                            ,   div[class "col"][(span [style "bakground-color" "rgb(239, 239, 239)"] <| Paginate.elidedPager pagerOptions pairsUnf)]
                            ,   div[class "col"]nextButtons
                            ]
                        ]
                      )
                ]
            ]
        _ ->
          div[][]




{-------------------------- Currency TABLE  EXPANDED-----------------}
currencyTableExpanded : Model -> Int -> Html Msg
currencyTableExpanded  model size= 
    case model.things of 
        Loaded pairsUnf ->
          let
             pairsOld = List.filter (\pair -> String.contains "EUR" pair.quote.alias_sort) (Paginate.page pairsUnf)
             (pairs, _) = LE.splitAt size pairsOld

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

                 , disabled <| Paginate.isFirst pairsUnf 
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
                , disabled <| Paginate.isLast pairsUnf ] [ text "Next" ]
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
                        th[class "price_table_expanded_header", style "padding" "1.5rem"][span[][text "Name"]]
                    ,   th[class "price_table_expanded_header", style "padding" "1.5rem"][span[][text "Transaction fee"]]
                    ,   th[class "price_table_expanded_header", style "padding" "1.5rem"][span[][text "Withdraw fee"]]
                    ,   th[class "price_table_expanded_header", style "padding" "1.5rem"][span[][text "Deposit fee"]]
                    ]
                  ]
              ,   tbody[]
                  (List.map (\assetPair -> tr[ ]
                   [
                       td[style "padding" "2rem"]
                       [
                           img[Html.Attributes.src assetPair.base.url, style "margin-right" "1vw"][]
                       ,   span[class "price_table_expanded_main_field"][text assetPair.base.alias_]
                       ,   span[style "text-transform" "uppercase", style "font-size" "1", style "color" "rgba(112,112,112,1)"][text ("("++ assetPair.base.alias_sort ++ ")")]
                       ]
                   ,   td[style "padding" "2rem"][
                              span[class "price_table_expanded_main_field"][text ((String.fromFloat assetPair.base.fee) ++ " %")]
                       ]
                   ,   td[style "padding" "2rem"][span[class "price_table_expanded_main_field"][text ((String.fromFloat assetPair.base.withdraw_fee)++" "++ assetPair.base.alias_sort)]]
                   ,   td[style "padding" "2rem"][span[class "price_table_expanded_main_field"][text ((String.fromFloat assetPair.base.deposit_fee)  ++ " " ++ assetPair.base.alias_sort)]]

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
                            ,   div[class "col"][(span [style "bakground-color" "rgb(239, 239, 239)"] <| Paginate.elidedPager pagerOptions pairsUnf)]
                            ,   div[class "col"]nextButtons
                            ]
                        ]
                      )
                ]
            ]
        _ ->
          div[][]









{------------------------------Package Deals -----------------}
viewPackages : Model -> PackageButtonMode -> Html Msg
viewPackages model msg= 
     div[class "rowService",style "margin-bottom" "50px", style "margin-top" "50px"]
      [
        div[class "container-lg "][ viewPackage model msg]
      ]

viewPackage : Model -> PackageButtonMode -> Html Msg
viewPackage model msg= 
   case model.assetPairsCurr of
      Loaded assetPairsPre ->
          let
               assetPairs= List.filter (\pair -> String.contains "EUR" pair.pair.quote.title ) assetPairsPre
          in
        case model.selectedPair of
          Just  pair ->
             
             div[style "margin-bottom" "5vh", style "text-align" "center", style "width" "100%"]
             [
                h1[style "font-weight" "bold", style "color" "rgba(0,99,166,1)", style "text-shadow" "2px 0 rgba(0,99,166,1)", style "letter-spacing" "2px"][text "Ready Made Packages"]
             ,  span[style "color" "rgba(68,68,68,1)",style "font-weight" "500", style "font-size" "1.25rem"][text "You can choose from our ready made packages"]
             ,  br[][]
             ,  span[style "color" "rgba(68,68,68,1)",style "font-weight" "500", style "font-size" "1.25rem"][text "and buy cryptocurrencies fast and easy."]
             ,  br[][]
             ,  h3[style "font-weight" "bold", style "color" "rgba(68,68,68,1)", style "text-shadow" "1px 0 rgba(68,68,68,1)",style "margin-top" "20px"][text "Choose a Cryptocurrency"]
             ,  div [style "margin-bottom" "5vh"]
                   [ Dropdown.dropdown
                     model.myDropStatePackages
                     { options = [ ]
                      , toggleMsg = MyDropMsgPackages
                      , toggleButton =
                          Dropdown.toggle [Button.attrs [(style "background-color" "rgba(239,239,239,1)"), style "border-radius" "45px"]] 
                           [ img [style "width" "40px",style "margin-right" "1vw",src pair.base.url][]
                           , span[style "color" "rgba(0,99,166,1)",style "font-size" "150%", style "font-weight" "bold", style "text-shadow" "1px 0 rgba(0,99,166,1)"]
                             [ text pair.base.alias_ ]
                           , img[src "images/arrow-down.svg",style "width" "20px", style "margin-left" "35px"][]

                           ]
                      , items = (List.map (\assetPair -> Dropdown.buttonItem [style "color" "rgba(0,99,166,1)",style "font-size" "150%",style "font-weight" "bold", onClick (ItemMsg assetPair.pair)][img [style "margin-right" "1vw",src assetPair.pair.base.url][], text assetPair.pair.base.alias_]) assetPairs)
                     }
          -- etc
                  ]
              , viewCardOffers model.assetPairsCurr model msg
              ]
          Nothing ->
              div[][]
      _ -> 
        div[][]


viewCardOffers : Status (List AssetPairCurrencyAnimation) -> Model -> PackageButtonMode  -> Html Msg
viewCardOffers  content model msg = 
    case model.selectedPair of 
        Just pair ->
          div[class "card-group"]
          [
              viewCard model pair 100 msg
          ,   viewCard model pair 250 msg
          ,   viewCard model pair 500 msg 
          ,   viewCard model pair 1000 msg
          ]    
        Nothing ->
         div[][]

viewCard : Model -> AssetPairCurrency -> Float -> PackageButtonMode -> Html Msg
viewCard model assetPairCurrency ammount msg= 
    let
       priceM =  (getPriceFromCurrencyView  model  assetPairCurrency Buy 1 True)
    in
   case priceM of
       Just price ->
         div[class "card text-center card-package", style "margin-right" "0.5vw", style "background-color" "", style "padding-bottom" "2rem"]
         [
           img[src assetPairCurrency.base.url, class "card-img-top", alt "...", style "width" "20%", style "margin-left" "auto", style "margin-right" "auto", style "margin-top" "4vh"][]
         ,   div[class "card-body"]
             [
                span[class "card-title",style "font-size" "150%", style "font-weight" "bold"][text ("You Get")]
             ,  h5[class "card-subtitle", style "margin-top" "0.5rem"][text ((Round.round assetPairCurrency.base.decimals (ammount/price))++" " ++ assetPairCurrency.base.alias_sort)]
             ,   p[class "card-text",style "margin-top" "1.5vh"][span [][text ((String.fromFloat ammount) ++ " EUR")]]
             ,  case msg of 
                    LoginMode ->
                        button[style "margin-bottom" "4rem",class "btn-card", style "border-radius" "50px", onClick ToLoginPage][text "Buy"]
                    ScrollBuyMode ->
                        button[style "margin-bottom" "4rem",class "btn-card", style "border-radius" "50px", onClick (ScrollBuy assetPairCurrency ammount)][text "Buy"]
             ]
         ]
       Nothing ->
           div[][]











{---------------- Modal -----}

viewModal : Model -> Maybe (Html Msg)
viewModal model =
   case model.modalVisibility of
      Validation ->
             Just(
                  div[class "container"]
                  [
                      div[class "row"]
                      [
                          div[class "col"]
                          [
                              span[class "modal_header center-block"][text model.messageTitle]
                          ]
                      ]
                  ,   div[class "row"]
                      [
                          div[class "col", style "text-align" "center"]
                          [
                              span[class "modal_message"][text model.message]
                          ]
                      ]
                  ,  div[class "row justify-content-center"]
                     [

                        div[class "col-4"]
                         [
                           button [type_ "button", style "width" "100%" , style "margin" "auto", style "padding" "10px 3px", onClick CloseModalValidation , class "btn btn-primary primary_button"]
                           [text "Ok" ]
                         ]
                     ]

                  ]
                )

      Visible ->
        case model.modalAction of
           3 ->
              Just(
                  div[class "container"]
                  [
                      div[class "row"]
                      [
                          div[class "col"]
                          [
                              span[class "modal_header center-block"][text "Please Wait"]
                          ]
                      ]
                  ,   div[class "row"]
                      [
                          div[class "col", style "text-align" "center"]
                          [
                              span[class "modal_message"][text "We are processing your request"]
                          ]
                      ]
                  ]
                )
           4 ->
              Just(
                  div[class "container"]
                  [
                    div[class "row justify-content-center"]
                     [

                        div[class "col-4"]
                         [
                           button [type_ "button", style "width" "100%" , style "margin" "auto", style "padding" "10px 3px", onClick SessionExpired , class "btn btn-primary primary_button"]
                           [text "Log In" ]
                         ]
                     ]

                  ]
                )
           2 ->
              Just(
                  div[class "container"]
                 ([
                      div[class "row"]
                      [
                          div[class "col"]
                          [
                              span[class "modal_header center-block"][text model.messageTitle]
                          ]
                      ]
                  ,   div[class "row"]
                      [
                          div[class "col", style "text-align" "center"]
                          [
                              span[class "modal_message"][text model.message]
                          ]
                      ]
                  ,  div[class "row justify-content-center"]
                     [
                        div[class "col-4"]
                         [
                           button [type_ "button", style "width" "100%" , style "margin" "auto", style "padding" "10px 3px", onClick (CloseModal 3 "") , class "btn btn-primary primary_button"]
                           [text "Ok" ]
                         ]
                     ]
                  ]
                )
                )

           _ ->

              Just(
                  div[class "container"]
                  ([
                      div[class "row", style "margin-bottom" "20px"]
                      [
                          div[class "col"]
                          [
                              span[class "modal_header center-block"][text model.message]
                          ]
                      ]
                   ]
                  ++
                (  case  model.response  of
                        Just resp ->
                            case resp.transaction.actionId of
                                1 ->
                                  viewValidAction model
                                2 ->
                                  viewValidActionSell model
                                _ ->
                                  viewValidAction model
                        Nothing ->
                            []
                           
               )
                )
                )
      Invisible ->
          Nothing


viewValidActionSell : Model -> List (Html Msg )
viewValidActionSell model = 
  case model.response of
      Just resp ->
        let
             fee = Round.roundNum resp.transaction.tgtCurrency.decimals ((resp.transaction.tgtCurrency.fee/100) * resp.transaction.srcAmount)
             sellingAmmount = resp.transaction.srcAmount - fee
             gettingTotal = Round.roundNum resp.transaction.tgtCurrency.decimals resp.transaction.srcAmount
             for = Round.roundNum resp.transaction.srcCurrency.decimals ((resp.transaction.srcAmount - fee) * resp.transaction.exchangeRate) 
             forEnd = for
        in
          [
              div[class "row justify-content-center"]
              [
                 div[class "col"][span[class "modal_message"][text (resp.transaction.tgtCurrency.alias_ ++ " Price " ++ (String.fromFloat resp.transaction.exchangeRate) ++ " "++ resp.transaction.srcCurrency.alias_sort )]]
              ]
          ,   div[class "row justify-content-center"]
              [
                  div[class "col"][span[class "modal_message"][text ("Selling amount " ++ (String.fromFloat sellingAmmount)++ " "++ resp.transaction.tgtCurrency.alias_sort) ]]
              ]
          ,   div[class "row justify-content-center"]
              [
                  div[class "col"][span[class "modal_message"][text ("Transaction fee " ++ (String.fromFloat fee)++ " "++ resp.transaction.tgtCurrency.alias_sort) ]]
              ]
          ,   div[class "row justify-content-center"]
              [
                  div[class "col"][span[class "modal_message"][text ("Selling  " ++ (String.fromFloat resp.transaction.srcAmount) ++ " "++ resp.transaction.tgtCurrency.alias_sort ) ]]
              ]
          ,   div[class "row justify-content-center"]
              [
                  div[class "col"][span[class "modal_message"][text ("For " ++ (String.fromFloat forEnd) ++ " " ++ resp.transaction.srcCurrency.alias_sort) ]]
              ]
           ,  div[class "row justify-content-center", style "margin-top" "20px"]
             [
                  div[class "col-4"]  
                   [button [type_ "button", style "width" "100%" , style "margin" "auto", style "padding" "10px 3px", onClick (CloseModal 3 "") , class "btn  primary_button", style "background-color" "transparent", style "color" "rgba(112,112,112,1)"]
                   [
                        text "Cancel" 
                   ]
                 ]
             ,   div[class "col-4"]
                 [
                   button [type_ "button", style "width" "100%" , style "margin" "auto", style "padding" "10px 3px", onClick (getMsgForBut model.modalAction model.modalToken) , class "btn btn-primary primary_button"]
                   [
                       case  model.modalAction of
                        1 ->
                          text "Verify"
                        _ ->
                          text "View Rules" 
                    ]
                 ]
             ]
          ]
      Nothing ->
          []






viewValidAction : Model -> List (Html Msg )
viewValidAction model = 
  case model.response of
      Just resp ->
        let
             fee =Round.roundNum resp.transaction.srcCurrency.decimals  ((resp.transaction.tgtCurrency.fee/100) * resp.transaction.srcAmount)
             purchaseCost = Round.roundNum resp.transaction.srcCurrency.decimals resp.transaction.srcAmount - fee
             spending = Round.roundNum resp.transaction.srcCurrency.decimals resp.transaction.srcAmount
             for = (resp.transaction.srcAmount /resp.transaction.exchangeRate) 
             forEnd = Round.roundNum resp.transaction.tgtCurrency.decimals (for - (for * (resp.transaction.tgtCurrency.fee/100)))
        in
          [
              div[class "row justify-content-center"]
              [
                 div[class "col"][span[class "modal_message"][text (resp.transaction.tgtCurrency.alias_ ++ " Price " ++ (String.fromFloat resp.transaction.exchangeRate) ++ " "++ resp.transaction.srcCurrency.alias_sort )]]
              ]
          ,   div[class "row justify-content-center"]
              [
                  div[class "col"][span[class "modal_message"][text ("Purchase cost " ++ (String.fromFloat purchaseCost)++ " "++ resp.transaction.srcCurrency.alias_sort) ]]
              ]
          ,   div[class "row justify-content-center"]
              [
                  div[class "col"][span[class "modal_message"][text ("Transaction fee " ++ (String.fromFloat fee)++ " "++ resp.transaction.srcCurrency.alias_sort) ]]
              ]
          ,   div[class "row justify-content-center"]
              [
                  div[class "col"][span[class "modal_message"][text ("Spending " ++ (String.fromFloat spending) ++ " "++ resp.transaction.srcCurrency.alias_sort ) ]]
              ]
          ,   div[class "row justify-content-center"]
              [
                  div[class "col"][span[class "modal_message"][text ("For " ++ (String.fromFloat forEnd) ++ " " ++ resp.transaction.tgtCurrency.alias_sort) ]]
              ]
           ,  div[class "row justify-content-center", style "margin-top" "20px"]
             [
                  div[class "col-4"]  
                   [button [type_ "button", style "width" "100%" , style "margin" "auto", style "padding" "10px 3px", onClick (CloseModal 3 "") , class "btn  primary_button", style "background-color" "transparent", style "color" "rgba(112,112,112,1)"]
                   [
                        text "Cancel" 
                   ]
                 ]
             ,   div[class "col-4"]
                 [
                   button [type_ "button", style "width" "100%" , style "margin" "auto", style "padding" "10px 3px", onClick (getMsgForBut model.modalAction model.modalToken) , class "btn btn-primary primary_button"]
                   [
                       case  model.modalAction of
                        1 ->
                          text "Verify"
                        _ ->
                          text "View Rules" 
                    ]
                 ]
             ]
          ]
      Nothing ->
          []
 



getMsgForBut : Int -> String ->  Msg
getMsgForBut action token =
    case action of
        1 ->
            CloseModal 1 token
        _ -> 
            CloseModal 2 ""



{-------------- DROPDOWN ------}
dropDown : Maybe Model -> Maybe (List Treasury) -> Maybe (List Withdraw) -> Html msg
dropDown transactionsMaybe treasury  withdraws= 
  case treasury of
      Just treasur ->
          let

              totalInEur = case transactionsMaybe of
                  Just transM ->
                      let
                       treasuriesEnd = List.filter (\trea -> trea.currency /= "EUR") treasur
                       sumOfEur = List.filter (\trea -> trea.currency == "EUR") treasur
                       sum2 = List.foldl (\obje old-> obje.balance +old) 0 sumOfEur
                       sum = (List.foldl (maybeAdd) (Just 0) (List.map (asset2Value transM ) treasuriesEnd) )
                      in
                      case sum of
                          Just sum1 ->
                              Just (sum1+sum2)
                          Nothing ->
                              Nothing
                  Nothing ->
                      Nothing
              heList = 
                    case totalInEur of
                        Nothing ->
                            [img[src "images/loading.svg"][]]
                        Just total ->
                            [text ((Round.round 2 total) ++ " €")
                          , img[src "/images/wallet-header.svg", style "width" "30px", style "margin-left" "15px"][]]

          in
          li[class "nav-item dropdown"][ 
                a[
                  href "#pageSubmenu"
                , style "padding-left" "20px"
                , class "nav-link"
                , style "font-size" "1.25rem"
                , id "navbarDropdown"
                , attribute "role" "button"
                , attribute "data-toggle" "dropdown"
                , attribute "aria-haspopup" "true"
                , attribute "aria-expanded" "false"
                , attribute "background-color" "transparent"
                ]
                
                 (heList ++  [
                  (case withdraws of 
                    Just withdrs ->
                       getUserAssets2 treasur  transactionsMaybe withdrs
                    Nothing ->
                       getUserAssets treasur  transactionsMaybe 
                   )
                ])]
      Nothing ->
          div[][]


getUserAssets : List Treasury -> Maybe Model -> Html msg
getUserAssets treasuries model= 
  div [class "dropdown-menu",attribute "aria-labelledby" "navbarDropdown"]
      (List.map (asset2Div model) treasuries)

asset2Div2 : Withdraw -> Html msg
asset2Div2 withdraws =
  div [class "dropdown_item", href "#"]
      [ span[class "treasury_cur"][text ("W -> " ++ (withdraws.currency.alias_sort ++ " : "))], span[class "treasury_balance"][text (" -"++(String.fromFloat withdraws.ammount))]]  
  
asset2Value :  Model -> Treasury  -> Maybe Float
asset2Value  model trea=
      case model.assetPairsCurr of 
        Loaded pairsUnf ->
          let
             listPair = List.map (\pairN -> pairN.pair) pairsUnf
             pairsOld = List.filter (\pair -> String.contains "EUR" pair.quote.alias_sort && String.contains trea.currency pair.base.alias_sort)  listPair
             pairEnd = List.head pairsOld
          in
          case pairEnd of 
              Just  par ->
                  case findCurrencyPrice par model model.window of
                      Just price ->
                          Just ( Round.roundNum 2 (( trea.balance   * price) * (1- (par.base.fee)/100)) )
                      Nothing ->
                          Nothing

              Nothing ->
                    Nothing
        _ ->
           let
              _ = Debug.log "no " "data"
           in
            Nothing



asset2Div : Maybe Model -> Treasury  -> Html msg
asset2Div  modelM trea=
  case modelM of 
    Just model ->
      case model.assetPairsCurr of 
        Loaded pairsUnf ->
          let
             listPair = List.map (\pairN -> pairN.pair) pairsUnf
             pairsOld = List.filter (\pair -> String.contains "EUR" pair.quote.alias_sort && String.contains trea.currency pair.base.alias_sort)  listPair
             pairEnd = List.head pairsOld
          in
          case pairEnd of 
              Just  par ->
                  case findCurrencyPrice par model model.window of
                      Just price ->
                         div [class "dropdown_item", href "#"]
                         [ span[class "treasury_cur"][text trea.currency], span[class "treasury_balance"][text ((String.fromFloat ( Round.roundNum 2 (( trea.balance   * price) * (1- (par.base.fee)/100)) )) ++ " €")]]
                      Nothing ->
                          let
                             _ = Debug.log "no" "price"
                          in
                         div [class "dropdown_item", href "#"]
                          [ span[class "treasury_cur"][text trea.currency], span[class "treasury_balance"][text (String.fromFloat trea.balance)]]

              Nothing ->
                  let
                      _ = Debug.log "no" "pair"
                  in
                    div [class "dropdown_item", href "#"]
                     [ span[class "treasury_cur"][text trea.currency], span[class "treasury_balance"][text (String.fromFloat trea.balance)]]
        _ ->
           let
              _ = Debug.log "no " "data"
           in
           div [class "dropdown_item", href "#"]
            [ span[class "treasury_cur"][text trea.currency], span[class "treasury_balance"][text (String.fromFloat trea.balance)]]
    Nothing ->
        let
            _ = Debug.log "no" "model"
        in
       div [class "dropdown_item", href "#"]
          [ span[class "treasury_cur"][text trea.currency], span[class "treasury_balance"][text (String.fromFloat trea.balance)]]

getUserAssets2 : List Treasury -> Maybe Model -> List Withdraw -> Html msg
getUserAssets2 treasuries  model withdraws= 
  div [class "dropdown-menu",attribute "aria-labelledby" "navbarDropdown"]
     ( (List.map (asset2Div model) treasuries)
      ++ [
          div[class "dropdown-divider"]
          []
          ]
      ++ (List.map asset2Div2 withdraws)
         
      )

maybeAdd : Maybe Float -> Maybe Float-> Maybe Float
maybeAdd number existing=
    case number of 
        Just nm ->
            case existing of
                Just ex ->
                    Just(ex + nm)
                Nothing ->
                    Nothing
        Nothing ->
            Nothing

