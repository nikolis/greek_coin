module Page.Payments.Deposit exposing (Model, Msg(..), init, subscriptions, update, view, Status(..), viewModal)

import Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Api2.Data exposing (Currency, BankDetails, CurrencyResponse, BankResponse, Deposit)
import Api2.Happy exposing (createDepositRequest, getAvailableBanks)
import Bootstrap.Modal as Modal
import Bootstrap.Button as Button
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid as Grid
import Bootstrap.Dropdown as Dropdown
import Json.Decode exposing (list, string, Decoder, field, map5, decodeString, errorToString, nullable, float, int)
import Api
import Route exposing (Route)
import Browser.Navigation as Navigat

import Http.Detailed
import Dict exposing (Dict)

type alias Model =
    {
        session: Session
    ,   currencyTitle : Maybe String
    ,   currency : Maybe Currency
    ,   dropdownCurrencyState : Dropdown.State
    ,   dropdownBankState : Dropdown.State
    ,   bank : Maybe BankDetails
    ,   bankDetailsId : Maybe String
    ,   monetary_cur : Status CurrencyResponse
    ,   bank_dets : Status BankResponse
    ,   modalResponseVisibility : ModalState
    ,   lastSubmitedDeposit : Maybe Deposit
    ,   message : String
    ,   messageTitle : String
    ,   fromNumberString : String
    }

type ModalState = 
    Visible 
    | Invisible 
    | SessionExpired
    | Validation

init : Session -> (Model, Cmd Msg)
init session = 
    let
        md = 
            { session = session
            , currencyTitle = Nothing
            , currency = Nothing
            , dropdownCurrencyState = Dropdown.initialState
            , dropdownBankState = Dropdown.initialState
            , bank = Nothing
            , bankDetailsId = Nothing
            , monetary_cur = Loading
            , bank_dets = Loading
            , modalResponseVisibility = Invisible
            , lastSubmitedDeposit = Nothing
            , message = ""
            , messageTitle = ""
            , fromNumberString = ""
            }
    in
    (md, Cmd.batch[getAvailableBanks md.session CompletedBankLoad])

type Status a
    = Loading
    | LoadingSlowly
    | Loaded a
    | Failed

type alias Item =
    { value : String
    , text : String
    , enabled : Bool
    }

type  Msg = 
    GotSession  Session
    | InitiateDeposit
    | DropdownCryptoChanged (Maybe String)
    | CurrencyChanged Currency
    | BankChanged BankDetails
    | CompletedTransactionRequestSubmited (Result (Http.Detailed.Error String) ( Http.Metadata, Deposit ))
    | CompletedBankLoad (Result Http.Error (BankResponse))
    | CompletedCurrenciesLoad (Result Http.Error (CurrencyResponse))
    | DropdownCurrencyToggle Dropdown.State
    | DropdownBankToggle Dropdown.State
    | CloseModalResponse
    | ShowModalResponse
    | AnimateResponseModal 
    | AnimateResponseModalClose 
    | SessionExpiredMsg
    | ChangeFromNumbHand String

depositRequestValidator : Model -> (Model, Cmd Msg)
depositRequestValidator model = 
   case model.currency of 
        Just currency1 ->
            case getCurrency model currency1.title of
                Just currency ->
                    case (String.toFloat model.fromNumberString) of
                        Just number ->
                            case number<= 0 of
                                True ->
                                   ({model | messageTitle = "Validation Error", message = "Ammount must be a positive number",modalResponseVisibility = Validation}, Cmd.none)
                                False ->
                                   depositRequest model currency number
                        Nothing ->
                         ({model | messageTitle = "Validation Error", message = "Ammount must be a number",modalResponseVisibility = Validation}, Cmd.none)
                        
                Nothing ->
                    ({model | messageTitle = "Validation Error", message = "Currency was not selected",modalResponseVisibility = Validation}, Cmd.none)
        Nothing ->
            ({model | messageTitle = "Validation Error", message = "Currency was not selected",modalResponseVisibility = Validation}, Cmd.none)




depositRequest : Model -> Currency -> Float -> (Model, Cmd Msg)
depositRequest model currency ammount =
   if String.contains "EUR" currency.alias_sort then
      case model.bank of
           Just bank ->
               (model, createDepositRequest model.session CompletedTransactionRequestSubmited ammount currency (Just (String.fromInt bank.id)))

           Nothing ->
               ({model | messageTitle = "Validation Error", message = "No bank was selected",modalResponseVisibility = Validation}, Cmd.none)
   else
     (model, createDepositRequest model.session CompletedTransactionRequestSubmited ammount currency Nothing)


getCurrency : Model -> String -> Maybe Currency
getCurrency model title =
    case model.monetary_cur of
        Loaded currencies ->
            let
              dic = Dict.fromList (List.map (\cur -> (cur.title, cur)) currencies.currencies)
            in
            Dict.get title dic
        _ ->
            Nothing

update: Msg -> Model -> (Model, Cmd Msg)
update msg model = 
    case msg of
        SessionExpiredMsg ->
           (model, Cmd.batch [Api.clearLogInfo, Navigat.load (Route.routeToString Route.Login)])

        ChangeFromNumbHand number ->
            ({model | fromNumberString = number}, Cmd.none)

        GotSession session->
            ({model|session = session}, Cmd.none)

        InitiateDeposit ->
            depositRequestValidator model

        DropdownCryptoChanged value->
            ({model| currencyTitle = value}, Cmd.none)
        
        CurrencyChanged cur ->
            ({model | currency = Just cur}, Cmd.none)

        BankChanged bankDets ->
            ({ model | bank = Just bankDets}, Cmd.none)

        DropdownCurrencyToggle state ->
            ( { model | dropdownCurrencyState = state}, Cmd.none)

        DropdownBankToggle state ->
            ( { model | dropdownBankState = state}, Cmd.none)

        CompletedTransactionRequestSubmited (Ok (metada, result)) ->
            let
                _ = Debug.log "last submitted deposit:" result
            in
            ({model|  message = "Requested was succesfully created",lastSubmitedDeposit =  Just result, modalResponseVisibility = Visible}, Cmd.none)

        CompletedTransactionRequestSubmited (Err error) ->
         let
             _= Debug.log "error getting the staff" (Debug.toString error)
         in
         case error of
             Http.Detailed.BadStatus metadata body ->
               let
                   errorResult = decodeString (field "error" string) body
               in
               case errorResult of 
                   Ok errorStr ->
                       case metadata.statusCode of
                           401 ->
                             ({model | message = errorStr, modalResponseVisibility = SessionExpired}, Cmd.none)
                           _ ->
                             ({model | message = errorStr, modalResponseVisibility = Visible}, Cmd.none)

                   _  ->
                     case metadata.statusCode of
                               401 ->
                                   let
                                      md = {model | message = "Session expired ", messageTitle = "Your session has expired please login",  modalResponseVisibility = SessionExpired}
                                   in
                                   (md, Cmd.none)
                               _ ->
                                   ({model | message = "Unknwon ERROR", modalResponseVisibility = Visible}, Cmd.none)

             _ ->
               ({model| message = "Unknown ERROR", modalResponseVisibility = Visible}, Cmd.none)

        CloseModalResponse ->
            ( { model | modalResponseVisibility = Invisible, lastSubmitedDeposit = Nothing, message = "", messageTitle ="" }
            , Cmd.none
            )

        AnimateResponseModal  ->
            ({ model | modalResponseVisibility = Visible}, Cmd.none)

        AnimateResponseModalClose  ->
            ({ model | modalResponseVisibility = Invisible, lastSubmitedDeposit = Nothing}, Cmd.none)

        ShowModalResponse ->
            ( { model | modalResponseVisibility = Visible }
            , Cmd.none
            )
        CompletedCurrenciesLoad (Ok mon) ->
            let
                firstCurr = List.head mon.currencies
            in
            ({model | monetary_cur = Loaded mon, currency = firstCurr}, Cmd.none)

        CompletedCurrenciesLoad (Err error) ->
            let
                _ = Debug.log "the eror getting cur" error
            in
            (model, Cmd.none)

        CompletedBankLoad (Ok feed) ->
           let
               _= Debug.log "Da bank: " feed
               firstBank = List.head feed.banks
               theId = 
                   case firstBank  of
                       Just bank ->
                           Just (String.fromInt bank.id)
                       Nothing ->
                           Nothing
           in
           ({model  | bank_dets = Loaded feed, bank =  firstBank}, Cmd.none)

        CompletedBankLoad (Err error) ->
           let
               _ = Debug.log "Da bang error: " error
           in
           ({model | bank_dets = Failed}, Cmd.none)

viewCurrencyDropDown : List Currency -> Model -> Html Msg
viewCurrencyDropDown  currenciesF model =
    let
        currencies = List.filter (\curr -> curr.active_deposit == True) currenciesF
    in
    case model.currency of
        Just currency ->
                 Dropdown.dropdown
                    model.dropdownCurrencyState
                     { options = [ Dropdown.attrs[style "width" "100%", style "height" "100%"] ]
                      , toggleMsg = DropdownCurrencyToggle
                      , toggleButton =
                          Dropdown.toggle [Button.attrs [style "background-color" "rgba(239,239,239,1)", style "width" "100%", style "content" "none"], Button.block] 
                                        [
                                          div[class "container"]
                                            [
                                                div[class "row", style "min-width" "140px"]
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
                      , items = (List.map (\assetPair -> Dropdown.buttonItem [style "color" "rgba(0,99,166,1)",style "font-size" "1.25rem",style "font-weight" "bold", onClick (CurrencyChanged assetPair)][img [style "margin-right" "1vw",src assetPair.url][], text assetPair.alias_]) currencies)
                     }
        Nothing ->
             div[][text "den"]

viewBankDropDown : List BankDetails -> Model -> Html Msg
viewBankDropDown  bankDetails model =
    case model.bank of
        Just selectedBank ->
                 Dropdown.dropdown
                    model.dropdownBankState
                     { options = [ Dropdown.attrs[style "width" "100%", style "height" "100%"], Dropdown.alignMenuRight ]
                      , toggleMsg = DropdownBankToggle
                      , toggleButton =
                          Dropdown.toggle [Button.attrs [style "background-color" "rgba(239,239,239,1)", style "width" "100%", style "content" "none"], Button.block] 
                                        [
                                          div[class "container"]
                                            [
                                                div[class "row"]
                                                [
                                                    div[class "col"]
                                                    [
                                                        div[class "row justify-content-start"]
                                                        [
                                                            div[class "col-2 ", style "height" "1.3rem", style "margin-top" "5px", align "start"]
                                                            [
                                                               img [src "images/bank2.svg", style "height" "1.3rem"][]
                                                             ]
                                                        ,  
                                                            div[class "col ", align "start"]
                                                            [
                                                               label[style "padding" "0px", style "margin" "0px"][span[style "color" "rgba(112,112,112,1)", style "font-size" "1.25rem", style "font-weight" "bold", style "text-shadow" "1px 0 rgba(112,112,112,1)"][text "bank"]] 
                                                            ]
                                                       ]
                                                    ,  div[class "row justify-content-start "]
                                                      [
                                                           div[class "col", align "start"]
                                                          [
                                                            span[style "color" "rgba(0,99,166,1)",style "font-size" "150%", style "font-weight" "bold", style "text-align" "start", style "text-transform" "uppercase", style "text-shadow" "1px 0 rgba(0,99,166,1)"] [ text selectedBank.name ]
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
                      , items = (List.map (\assetPair -> Dropdown.buttonItem [style "color" "rgba(0,99,166,1)",style "font-size" "1.25rem",style "font-weight" "bold", onClick (BankChanged assetPair)][ text assetPair.name]) bankDetails)
                     }

        Nothing ->
            div[][]

view : Model -> Html Msg
view model = 
   case model.monetary_cur of
     Loaded cryptocurencies ->
       case model.bank_dets of
         Loaded bankDets ->
                         div[class "container"]
                          [
                            div[style "border" "1px solid rgba(239,239,239,1)", style "border-radius" "10px", class "form-row", style "margin-top" "2vh"]
                            [
                              div[class "form-group col", style "margin" "0px"] 
                              [
                                label[style "padding-left" "0.5rem", style "padding-top" "0.5rem", style "margin-bottom" "0px", style "color" "rgba(112,112,112,1)", style "font-size" "1.25rem", style "font-weight" "bold", style "text-shadow" "1px 0 rgba(112,112,112,1)"][text "I want to Depose"]
                              , input[class "form-control", style "padding-top" "0rem", style "width" "100%",style "font-size" "1.5rem", style "color" "rgba(0,99,166,1)" ,style "font-weight" "bold",Html.Attributes.value  model.fromNumberString, onInput ChangeFromNumbHand, style "border-style" "none", style "text-shadow" "1px 0 rgba(0,99,166,1)"][]
                              ]

                            , div[class "form-group-append col-lg-auto col-xs-auto col-sm-auto col-md-auto col-xl-auto", style "padding-right" "0", style "margin-left" "5px"]
                                [
                                  viewCurrencyDropDown cryptocurencies.currencies model
                                ]

                            , div[class "form-group-append col-lg-auto col-xs-auto col-sm-auto col-md-auto col-xl-auto", style "padding-right" "0"][
                                  case model.currency of
                                     Just currency ->
                                       if String.contains "EUR" currency.title then 
                                           viewBankDropDown  bankDets.banks model
                                       else 
                                         div[][]
                                     Nothing ->
                                         div[][]

                                    ]
                            , Html.node "captch-node"[][] 
                            , div [id "recaptcha"][]
                       ]
                    ,  div[style "pading-bottom" "4vh", style "padding-top" "4vh", style "width" "30%", style "margin" "auto"]
                       [
                        button [ type_ "button", style "width" "100%" , style "margin" "auto", class "btn btn-primary primary_button", onClick InitiateDeposit] [text "DEPOSIT"]
                       ]
                    ]
         _ ->
              div[][]
     _ -> 
            div[][]  


viewModal : Model -> Maybe (Html Msg)
viewModal model   =
    case model.modalResponseVisibility of
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
                           button [type_ "button", style "width" "100%" , style "margin" "auto", style "padding" "10px 3px", onClick AnimateResponseModalClose , class "btn btn-primary primary_button"]
                           [text "Ok" ]
                         ]
                     ]

                  ]
                )

        SessionExpired ->
              Just(
                  div[class "container"]
                  [
                    div[class "row justify-content-center"]
                     [

                        div[class "col-4"]
                         [
                           button [type_ "button", style "width" "100%" , style "margin" "auto", style "padding" "10px 3px", onClick SessionExpiredMsg , class "btn btn-primary primary_button"]
                           [text "Ok" ]
                         ]
                     ]

                  ]
                )

        Invisible ->
            Nothing
        Visible ->
             case model.lastSubmitedDeposit of
                Just dep ->
                  case dep.bankDetails of
                    Just bankDets ->
                        Just(
                              div[class "container"]
                              [
                                  div[class "row"]
                                  [
                                      div[class "col"]
                                      [
                                          span[class "modal_header center-block"][text "Pay to this Bank Account"]
                                      ]
                                  ]

                              ,   div[class "row"]
                                  [
                                      div[class "col", style "text-align" "center"]
                                      [
                                          span[class "modal_message"][text "Beneficial Owner "]
                                      ]

                                  ,   div[class "col", style "text-align" "center"]
                                      [
                                          span[class "modal_message"][text bankDets.beneficiaryName]
                                      ]
                                  ]

                              ,   div[class "row"]
                                  [
                                      div[class "col", style "text-align" "center"]
                                      [
                                          span[class "modal_message"][text "IBAN "]
                                      ]

                                  ,   div[class "col", style "text-align" "center"]
                                      [
                                          span[class "modal_message"][text bankDets.iban]
                                      ]
                                  ]

                              ,   div[class "row"]
                                  [
                                      div[class "col", style "text-align" "center"]
                                      [
                                          span[class "modal_message", style "font-weight" "bolder", style "color" "red"][text "Reference Descriptions "]
                                      ]

                                  ,   div[class "col", style "text-align" "center"]
                                      [
                                          span[class "modal_message", style "font-weight" "bolder", style "color" "red"][(
                                            case dep.alias_ of
                                                Just alias_name ->
                                                    text alias_name
                                                Nothing ->
                                                    text "N/A"
                                          )]
                                      ]
                                  ]

                              ,   div[class "row"]
                                  [
                                      div[class "col", style "text-align" "center"]
                                      [
                                          span[class "modal_message"][text "BIC "]
                                      ]

                                  ,   div[class "col", style "text-align" "center"]
                                      [
                                          span[class "modal_message"][text bankDets.swift_code]
                                      ]
                                  ]

                              ,   div[class "row"]
                                  [
                                      div[class "col", style "text-align" "center"]
                                      [
                                          span[class "modal_message"][text "Bank Name"]
                                      ]

                                  ,   div[class "col", style "text-align" "center"]
                                      [
                                          span[class "modal_message"][text bankDets.name]
                                      ]
                                  ]
                              ,   div[class "row"]
                                  [
                                      div[class "col", style "text-align" "center"]
                                      [
                                          span[class "modal_message"][text "RecipientAddress"]
                                      ]

                                  ,   div[class "col", style "text-align" "center"]
                                      [
                                          span[class "modal_message"][text bankDets.recipientAddress]
                                      ]
                                  ]

                              ,   div[class "row"]
                                  [
                                      div[class "col", style "text-align" "center"]
                                      [
                                          span[class "modal_message"][text "Bank Address"]
                                      ]

                                  ,   div[class "col", style "text-align" "center"]
                                      [
                                          span[class "modal_message"][text bankDets.bankAddress]
                                      ]
                                  ]
                              ,   div[class "row"]
                                  [
                                      div[class "col", style "text-align" "center"]
                                      [
                                          span[class "modal_message"][text "Deposit fee: "]
                                      ]

                                  ,   div[class "col", style "text-align" "center"]
                                      [
                                          span[class "modal_message"][text ((String.fromFloat dep.currency.deposit_fee) ++ " "++ dep.currency.alias_sort)]
                                      ]
                                  ]


                              ,  div[class "row"]
                                 [
                                     div[class "col"]
                                     [
                                       button [type_ "button", style "width" "40%" , style "margin" "auto", style "padding" "10px 3px", onClick AnimateResponseModalClose, class "btn btn-primary primary_button"][text "OK"]
                                     ] 
                                 ]
                              ]
                            )
                    Nothing ->
                        case dep.wallet of
                            Just wallet ->
                                   Just(
                                      div[class "container"]
                                      [
                                          div[class "row"]
                                          [
                                              div[class "col"]
                                              [
                                                  span[class "modal_header center-block"][text "Deposit Important Details"]
                                              ]
                                          ]
                                      ,   div[class "row"]
                                          [
                                              div[class "col", style "text-align" "center"]
                                              [
                                                  span[class "modal_message"][text "Deposit Address :"]
                                              ]

                                           ,  div[class "col", style "text-align" "center"]
                                              [
                                                  span[class "modal_message"][text wallet.public_key]
                                              ]
                                          ]
                                      ,   div[class "row"]
                                          [
                                              div[class "col", style "text-align" "center"]
                                              [
                                                  span[class "modal_message"][text "Deposit Fee: "]
                                              ]

                                           ,  div[class "col", style "text-align" "center"]
                                              [
                                                  span[class "modal_message"][text ((String.fromFloat dep.currency.deposit_fee) ++ " "++ dep.currency.alias_sort)]
                                              ]
                                          ]
                                      ,   div[class "row"]
                                          [
                                              div[class "col", style "text-align" "center"]
                                              [
                                                  span[class "modal_message"][text ("Send only " ++ dep.currency.alias_ ++ " to this deposit address. Sending coin or token other than " ++ dep.currency.alias_ ++ " to this address, or address mistake may result in the loss of your deposit") ]
                                              ]
                                          ]

                                      ,  div[class "row"]
                                         [
                                             div[class "col"]
                                             [
                                               button [type_ "button", style "width" "40%" , style "margin" "auto", style "padding" "10px 3px", onClick AnimateResponseModalClose, class "btn btn-primary primary_button"][text "OK"]
                                             ] 
                                         ]
                                      ]
                                    )

                            Nothing ->
                                Nothing
                Nothing ->
                    let
                      title = 
                        case model.message of
                            "There is no available wallet" ->
                               "Please contact with us."
                            _ ->
                                "Feedback"
                    in
                     Just(
                          div[class "container"]
                          [
                              div[class "row"]
                              [
                                  div[class "col"]
                                  [
                                      span[class "modal_header center-block"][text title]
                                  ]
                              ]
                          ,   div[class "row"]
                              [
                                  div[class "col", style "text-align" "center"]
                                  [
                                      span[class "modal_message"][text model.message]
                                  ]
                              ]
                          ,  div[class "row"]
                             [
                                 div[class "col"]
                                 [
                                   button [type_ "button", style "width" "40%" , style "margin" "auto", style "padding" "10px 3px", onClick AnimateResponseModalClose, class "btn btn-primary primary_button"][text "OK"]
                                 ] 
                             ]
                          ]
                        )





subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
    [
       Dropdown.subscriptions model.dropdownCurrencyState DropdownCurrencyToggle
     , Dropdown.subscriptions model.dropdownBankState DropdownBankToggle
    ]
