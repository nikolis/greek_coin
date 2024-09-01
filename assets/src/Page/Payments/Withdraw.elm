module Page.Payments.Withdraw exposing (Model, Msg(..), init, subscriptions, update, view, Status(..), viewModal)

import Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Api2.Data exposing (Currency, decoderWithdraw, Withdraw, CurrencyResponse)
import Api2.Happy exposing (getBaseUrl)
import Json.Encode as E
import Api
import Http.Detailed
import Dict exposing (Dict)
import Bootstrap.Modal as Modal
import Bootstrap.Button as Button
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid as Grid
import Json.Decode.Pipeline exposing (required, optional, hardcoded)
import Json.Decode exposing (list, string, Decoder, field, map5, decodeString, errorToString, nullable, float, int)
import Bootstrap.Dropdown as Dropdown
import Http.Legacy
import Task exposing (Task)
import Api.Endpoint as Endpoint

import Api
import Route exposing (Route)
import Browser.Navigation as Navigat


type alias Model =
    {
        session: Session
    ,   wallet : WalletLocal
    ,   ammount : String
    ,   ammountComment : String
    ,   bankDetails : BankDetailsLocal
    ,   currencyTitleWithdraw : Maybe String
    ,   currency : Maybe Currency
    ,   monetary_cur : Status CurrencyResponse
    ,   message : String
    ,   modalResponseVisibility : ModalState
    ,   dropdownCurrencyState : Dropdown.State
    ,   lastWithdrawSubmited : Maybe Withdraw
    ,   user : Maybe User
    ,   token : Maybe String
    ,   authToken :  String
    ,   modalAction : Int
    }

type ModalState = 
    Visible 
    | Invisible 
    | SessionExpired


init : Session -> (Model, Cmd Msg)
init session = 
    let
        md = 
            { 
              session = session
            , wallet = WalletLocal ""
            , ammount = "0.0"
            , bankDetails = BankDetailsLocal "" "" "" "" "" "" 
            , currencyTitleWithdraw = Nothing
            , currency = Nothing
            , monetary_cur = Loading
            , message = ""
            , modalResponseVisibility = Invisible
            , dropdownCurrencyState = Dropdown.initialState 
            , lastWithdrawSubmited = Nothing
            , user = Nothing
            , token = Nothing
            , authToken = ""
            , modalAction = 0
            , ammountComment = ""
            }
    in
    (md, Cmd.batch[Task.attempt GotUser (fetchUser session)])

fetchUser :  Session -> Task Http.Legacy.Error (User)
fetchUser  session =
    let
        request =
            Api.get Endpoint.user  (Session.cred session) decoderUser
    in
    Http.Legacy.toTask request

decoderUser : Json.Decode.Decoder User
decoderUser =
    Json.Decode.succeed User
    |> Json.Decode.Pipeline.required "first_name" myNullable
    |> Json.Decode.Pipeline.required "last_name" myNullable

type alias User = 
    {
       firstName : String
    ,  lastName : String
    }

myNullable :  Json.Decode.Decoder String
myNullable  =
    Json.Decode.oneOf
    [ Json.Decode.string
    , Json.Decode.null ""
    ]

type alias WalletLocal = 
    {
      public_key: String
    }

type alias BankDetailsLocal =
    {
       beneficiaryName : String
     , iban : String
     , swift_code : String
     , name : String
     , recipientAddress : String
     , bankAddress : String
    }

type Status a
    = Loading
    | LoadingSlowly
    | Loaded a
    | Failed

type  Msg = 
    GotSession  Session
    | InitiateWithdraw
    | CompletedWithdrawRequestSubmited (Result (Http.Detailed.Error String) (Http.Metadata, WithdrawResponse)) 
    | DropdownChangedWithdraw (Maybe String)
    | ChangeAmmount String
    | ChangeRecipientAddress String
    | ChangeSwift String
    | ChangeBankName String
    | ChangeIban String
    | ChangeWalletKey String
    | DropdownCurrencyToggle Dropdown.State
    | CurrencyChanged Currency
    | CloseModalResponse
    | ShowModalResponse
    | GotUser (Result Http.Legacy.Error User)
    | SendWithdrawTokens
    | TokenLoginInput String 
    | SessionExpiredMsg


withdraw2fa : Model -> Cmd Msg
withdraw2fa model= 
  case model.token of 
    Just token ->
       let
             user =
                 E.object
                     [ ( "token", E.string model.authToken )
                     , ( "withdraw_token", E.string token )
                     ]

             body = user
                    |> Http.jsonBody
         in
     Http.request
     { headers =
            case Session.cred model.session of
                Just cred ->
                    let
                        _ =
                            Debug.log "cred" (Api.credHeader cred)
                    in
                    [ Api.credHeader cred ]

                Nothing ->
                    []

      , method = "POST"
      , url = (getBaseUrl ++ ("/verify/withdrawall/2fa/"))
      , body =  body
      , expect = Http.Detailed.expectJson  CompletedWithdrawRequestSubmited decoderWithdrawResponse
      , timeout = Nothing
      , tracker = Nothing
      }
    Nothing ->
        Cmd.none

type alias WithdrawResponse =
    {
        withdraw : Maybe Withdraw
    ,   token : Maybe String
    }

decoderWithdrawResponse : Json.Decode.Decoder WithdrawResponse 
decoderWithdrawResponse = 
    Json.Decode.succeed WithdrawResponse
    |> Json.Decode.Pipeline.required "withdraw" (nullable decoderWithdraw)
    |> Json.Decode.Pipeline.required "token" (nullable string)

bankDetailsEncoder : BankDetailsLocal -> E.Value
bankDetailsEncoder bankDetails =
    E.object
        [ ( "beneficiary_name", E.string bankDetails.beneficiaryName )
        , ( "iban", E.string bankDetails.iban )
        , ( "name", E.string bankDetails.name )
        , ( "swift_code", E.string bankDetails.swift_code )
        , ( "recipient_address", E.string bankDetails.recipientAddress)
        ]

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

postWithdrawallEvent : Model -> Currency -> (Model, Cmd Msg)
postWithdrawallEvent model currency =
    case (String.toFloat model.ammount) of
        Just num ->
            case (num > 0) of
                True ->
                    case String.isEmpty (String.replace " " "" model.bankDetails.beneficiaryName) of
                        True ->
                          ({model | message = "You need to first provide your profile e.g First, Last Name Information through the profile page ", modalAction = 3}, Cmd.none)
                        False ->
                            case String.isEmpty (String.replace " " "" model.bankDetails.swift_code) of
                                True ->
                                   ({model | message = "Swift code canot be empty", modalAction = 3}, Cmd.none)
                                False ->
                                   case String.isEmpty (String.replace " " "" model.bankDetails.name) of
                                       True ->
                                         ({model | message = "Bank Name canot be empty", modalAction = 3}, Cmd.none)
                                       False ->
                                                 case String.isEmpty (String.replace " " "" model.bankDetails.iban) of
                                                     True ->
                                                       ({model | message = "Iban canot be emty", modalAction = 3}, Cmd.none)
                                                     False ->
                                                         case String.isEmpty (String.replace " " "" model.bankDetails.recipientAddress) of
                                                             True ->
                                                                ({model | message = "Recipient Addrss canot be empty", modalAction = 3}, Cmd.none)
                                                             False ->
                                                                 case String.isEmpty (String.replace " " "" model.bankDetails.bankAddress) of
                                                                     _ ->
                                                                       (model, postWithdrawallRequest model currency num)
                False ->
                    ({model | message = "Please check the withdrawal amount", modalAction = 3}, Cmd.none)
        Nothing ->
            ({model | message = "Please check the withdrawal amount", modalAction = 3}, Cmd.none)


postWithdrawallRequest : Model -> Currency -> Float -> Cmd Msg
postWithdrawallRequest model currency ammount=
    let
        body =
            E.object
                [ ( "withdraw"
                  , E.object
                        [ ( "currency_id", E.int currency.id )
                        , ( "ammount", E.float ammount )
                        , ( "user_bank_details", bankDetailsEncoder model.bankDetails )
                        ]
                  )
                ]
                |> Http.jsonBody
    in
    Http.request
        { headers =
            case Session.cred model.session of
                Just cred ->
                    let
                        _ =
                            Debug.log "cred" (Api.credHeader cred)
                    in
                    [ Api.credHeader cred ]

                Nothing ->
                    []
        , method = "POST"
        , body = body
        , url = (getBaseUrl ++ "/api/v1/transaction/withdraw")
        , expect = Http.Detailed.expectJson CompletedWithdrawRequestSubmited decoderWithdrawResponse
        , timeout = Nothing
        , tracker = Nothing
        }


postWithdrawallEventWallet : Model -> Currency -> (Model, Cmd Msg)
postWithdrawallEventWallet model currency =
    case (String.toFloat model.ammount) of
        Just num ->
            case (num > 0) of
                True ->
                    case String.isEmpty(String.replace " " "" model.wallet.public_key) of
                        True ->
                           ({model | message = "Wallet key cannot be empty", modalAction = 3}, Cmd.none)
                        False ->
                           (model, postWalletRequest model currency num)
                False ->
                    ({model | message = "Please check the withdrawal amount", modalAction = 3}, Cmd.none)
        Nothing ->
            ({model | message = "ammount must be a number", modalAction = 3}, Cmd.none)



postWalletRequest : Model -> Currency -> Float -> Cmd Msg
postWalletRequest model currency ammount =
    let
        body =
            E.object
                [ ( "withdraw"
                  , E.object
                        [ ( "currency_id", E.int currency.id )
                        , ( "ammount", E.float ammount)
                        , ( "user_wallet", E.object [ ( "bublic_key", E.string model.wallet.public_key ) ] )
                        ]
                  )
                ]
                |> Http.jsonBody
    in
    Http.request
        { headers =
            case Session.cred model.session of
                Just cred ->
                    let
                        _ =
                            Debug.log "cred" (Api.credHeader cred)
                    in
                    [ Api.credHeader cred ]

                Nothing ->
                    []
        , method = "POST"
        , body = body
        , url = (getBaseUrl ++ "/api/v1/transaction/withdraw")
        , expect = Http.Detailed.expectJson CompletedWithdrawRequestSubmited decoderWithdrawResponse
        , timeout = Nothing
        , tracker = Nothing
        }





update: Msg -> Model -> (Model, Cmd Msg)
update msg model = 
    case msg of

        SessionExpiredMsg ->
           (model, Cmd.batch [Api.clearLogInfo, Navigat.load (Route.routeToString Route.Login)])

        GotUser (Ok new_user) ->
            let
                _ = Debug.log "user ret: " new_user
                bankDetails = model.bankDetails 
                bankDetailsNew = {bankDetails | beneficiaryName = (new_user.firstName ++ " " ++ new_user.lastName)}
            in
            ({model | user = Just new_user, bankDetails = bankDetailsNew}, Cmd.none)

        GotUser (Err err) ->
            let
                _ = Debug.log "the ret error: " (Debug.toString err)
            in
            (model, Cmd.none)

        GotSession session->
            ({model|session = session}, Cmd.none)

        CompletedWithdrawRequestSubmited (Ok (metadatam, result)) ->
            case result.withdraw of
                Just withdraw ->
                   ({model| lastWithdrawSubmited = Just withdraw, modalResponseVisibility = Visible, modalAction = 0}, Cmd.none)
                Nothing ->
                    case result.token of
                        Just token ->
                            ({model | token = Just token, modalResponseVisibility = Visible, modalAction = 0}, Cmd.none)
                        Nothing ->
                            (model, Cmd.none)

        CompletedWithdrawRequestSubmited(Err error) ->
           let
               _  = Debug.log "Eroor" error
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
                           ({model | message = errorStr, modalResponseVisibility = SessionExpired, modalAction = 0}, Cmd.none)
                         _ ->
                           ({model | message = errorStr, modalResponseVisibility = Visible, modalAction = 0}, Cmd.none)

                   _  ->
                      case metadata.statusCode of 
                          401 ->
                             ({model | message = "Unknwon ERROR", modalResponseVisibility = SessionExpired, modalAction = 0}, Cmd.none)
                          _ ->
                             ({model | message = "Unknwon ERROR", modalResponseVisibility = Visible, modalAction = 0}, Cmd.none)

             _ ->
               ({model| message = "Unknown ERROR", modalResponseVisibility = Visible}, Cmd.none)

        CurrencyChanged cur ->
            ({model | currency = Just cur}, Cmd.none)

        DropdownCurrencyToggle state ->
            ( { model | dropdownCurrencyState = state}, Cmd.none)

        TokenLoginInput txt ->
            ({model | authToken = txt}, Cmd.none)

        CloseModalResponse ->
            ( { model | modalResponseVisibility = Invisible , lastWithdrawSubmited = Nothing}
            , Cmd.none
            )

        SendWithdrawTokens ->
            ({model | modalAction = 1, token = Nothing}, withdraw2fa model)

        ShowModalResponse ->
            ( { model | modalResponseVisibility = Visible, modalAction = 0 }
            , Cmd.none
            )

        InitiateWithdraw ->
            let
                md = {model | modalResponseVisibility = Visible, modalAction =1}
            in
            case model.currency of
                Just curr ->
                    case String.contains "EUR" curr.title of
                        True ->
                             postWithdrawallEvent md curr
                        False ->
                             postWithdrawallEventWallet md curr 
                Nothing ->
                    ( model, Cmd.none )

        DropdownChangedWithdraw value ->
           ({model | currencyTitleWithdraw = value}, Cmd.none)

        ChangeAmmount ammount ->
             let
                 numbAmmount = String.toFloat ammount
             in
             case numbAmmount of
                 Just numb ->
                   ({ model | ammount = ammount}, Cmd.none)
                 Nothing ->
                   ({model | ammount = ammount}, Cmd.none)


        ChangeRecipientAddress recipientAddress->
           let
               bankDets = model.bankDetails 
               bankDetsNew = {bankDets | recipientAddress = recipientAddress}
           in
           ({model | bankDetails = bankDetsNew}, Cmd.none)

        ChangeSwift swift ->
           let
               bankDets = model.bankDetails 
               bankDetsNew = {bankDets | swift_code = swift}
           in
           ({model | bankDetails = bankDetsNew}, Cmd.none)

        ChangeBankName bankName ->
           let
               bankDets = model.bankDetails 
               bankDetsNew = {bankDets | name = bankName}
           in
           ({model | bankDetails = bankDetsNew}, Cmd.none)

        ChangeIban iban ->
           let
               bankDets = model.bankDetails 
               bankDetsNew = {bankDets | iban = iban}
           in
           ({model | bankDetails = bankDetsNew}, Cmd.none)

        ChangeWalletKey walletKey ->
           let
               wallet = model.wallet 
               walletNew = {wallet | public_key = walletKey}
           in
           ({model | wallet = walletNew}, Cmd.none)


view : Model -> Html Msg
view model = 
    case model.monetary_cur of
        Loaded cryptocurencies ->
            div [ class "container" ]
                ([ 
                      div[style "border" "1px solid rgba(239,239,239,1)", style "border-radius" "10px", class "form-row"]
                            [
                              div[class "form-group col", style "padding-right" "0", style "margin" "0px"]
                              [
                                label[style "padding-left" "0.5rem", style "padding-top" "0.5rem", style "margin-bottom" "0px", style "color" "rgba(112,112,112,1)", style "font-size" "1.25rem", style "font-weight" "bold", style "text-shadow" "1px 0 rgba(112,112,112,1)"][span[][text "I want to Withdraw"]]
                              , input [class "form-control", style "padding-top" "0rem", style "width" "100%",style "font-size" "1.5rem", style "color" "rgba(0,99,166,1)" ,style "font-weight" "bold"{--,Html.Attributes.value  model.fromNumberString, onInput ChangeFromNumbHand--}, style "border-style" "none", style "text-shadow" "1px 0 rgba(0,99,166,1)", value  model.ammount, onInput ChangeAmmount, style "border-style" "none"][]
                              ]
                            , div[class "form-group-append col-lg-auto col-xs-auto col-sm-auto col-md-auto col-xl-auto", style "padding-right" "0"]
                              [
                                viewCurrencyDropDown cryptocurencies.currencies model
                              ]
                            ]
                 ] ++ (viewDetailsContainer model)
                   ++
                 ([      
                       div[style "pading-bottom" "4vh", style "padding-top" "4vh", style "width" "30%", style "margin" "auto"]
                       [
                       button [type_ "button", style "width" "100%" , style "margin" "auto", class "btn btn-primary primary_button" , onClick InitiateWithdraw ] 
                          [ span [][text "WITHDRAW"]]
                       {--, viewWalletDetails model--}
                       ]
                ])
            )

        _ ->
            div [] []

viewDetailsContainer : Model -> List ( Html Msg)
viewDetailsContainer model =
    case model.currency of
        Just currency ->
            case String.contains "EUR" currency.title of
                True ->
                    viewBank model

                False ->
                    viewWallet model

        Nothing ->
            []

type alias Item =
    { value : String
    , text : String
    , enabled : Bool
    }

viewCurrencyDropDown : List Currency -> Model -> Html Msg
viewCurrencyDropDown  currenciesF model =
    let
        currencies = List.filter (\curr ->  curr.active_deposit == True) currenciesF
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
             div[][text "N/A"]




viewModal : Model -> Maybe (Html Msg)
viewModal model =
  case model.modalResponseVisibility of
      Invisible ->
          Nothing

      SessionExpired ->
              Just(
                  div[class "container"]
                  [
                    div[class "row justify-content-center"]
                     [

                        div[class "col-4"]
                         [
                           button [type_ "button", style "width" "100%" , style "margin" "auto", style "padding" "10px 3px", onClick SessionExpiredMsg , class "btn btn-primary primary_button"]
                           [text "Log In" ]
                         ]
                     ]

                  ]
                )

      Visible ->
          case model.lastWithdrawSubmited of
              Just withdraw ->
                  Just(
                      div[class "container"]
                      [
                          div[class "row"]
                          [
                              div[class "col"]
                              [
                                  span[class "modal_header center-block"][text "You have requested a Withdrawall"]
                              ]
                          ]

                      ,  div[class "row"]
                          [
                              div[class "col"]
                              [
                                  span[class "modal_message center-block"][text "We have send you and email. Please click the link to verify your withdrawall "]
                              ]
                          ]

                      ,( case withdraw.wallet of 
                            Just wallet ->  
                              div[class "row"]
                              [
                                  div[class "col", style "text-align" "center"]
                                  [
                                      span[class "modal_message"][text "Wallet address: "]
                                  ]
                              ,   div[class "col", style "text-align" "center"]
                                  [
                                      span[class "modal_message"][text wallet.public_key]
                                  ]

                             ]
                            Nothing ->
                                case withdraw.bankAccountDetails of
                                    Just bankDetails ->
                                        div[]
                                        [
                                        div[class "row justify-content-center"]
                                        [
                                            div[class "col-4", style "text-align" "center"]
                                            [
                                                span[class "modal_message"][text "Bank account iban: "]
                                            ]
                                       ,    div[class "col-4", style "text-align" "center"]
                                            [
                                                span[class "modal_message"][text bankDetails.iban]
                                            ]
                                       ]
                                      ,  div[class "row justify-content-center"]
                                        [
                                            div[class "col-4", style "text-align" "center"]
                                            [
                                                span[class "modal_message"][text "Swift Code: "]
                                            ]
                                       ,    div[class "col-4", style "text-align" "center"]
                                            [
                                                span[class "modal_message"][text bankDetails.swift_code]
                                            ]

                                       ]

                                      ,  div[class "row justify-content-center"]
                                        [
                                            div[class "col-4", style "text-align" "center"]
                                            [
                                                span[class "modal_message"][text "Beneficiary name: "]
                                            ]
                                       ,    div[class "col-4", style "text-align" "center"]
                                            [
                                                span[class "modal_message"][text bankDetails.beneficiaryName]
                                            ]

                                       ]
                                      ,  div[class "row justify-content-center"]
                                        [
                                            div[class "col-4", style "text-align" "center"]
                                            [
                                                span[class "modal_message"][text "Recipient Address: "]
                                            ]
                                       ,    div[class "col-4", style "text-align" "center"]
                                            [
                                                span[class "modal_message"][text bankDetails.recipientAddress]
                                            ]

                                       ]]


                                    Nothing ->
                                        div[class "row"]
                                        [
                                            div[class "col", style "text-align" "center"]
                                            [
                                                span[class "modal_message"][text "Success"]
                                            ]
                                       ]

                       )
                      ,  div[class "row"]
                         [
                             div[class "col"]
                             [
                               button [type_ "button", style "width" "40%" , style "margin" "auto", style "padding" "10px 3px", onClick CloseModalResponse, class "btn btn-primary primary_button"][text "OK"]
                             ] 
                         ]
                      ]
                    )
              Nothing ->
                  case model.token of
                      Just token ->
                          Just(
                              div[class "container"]
                              [
                                  div[class "row"]
                                  [
                                      div[class "col"]
                                      [
                                          span[class "modal_header center-block"][ text "Two-factor Authenticator Please enter your one time password"]
                                      ]
                                  ]
                              ,   div[class "row"]
                                  [
                                      div[class "col"]
                                      [
                                        Html.form[]
                                        [
                                            div[class "form-group"]
                                            [
                                               input[class "form-control", id "token", onInput TokenLoginInput] []
                                            ,  small[class "form-text text-muted"][text "The token generated by your authenticator application"]
                                            ]
                                        ]
                                      ]
                                  ]
                              ,  div[class "row"]
                                 [
                                     div[class "col"]
                                     [
                                       button [type_ "button", style "width" "40%" , style "margin" "auto", style "padding" "10px 3px", onClick SendWithdrawTokens, class "btn btn-primary primary_button"][text "Confirm"]
                                     ] 
                                 ]
                              ]
                            )

                      Nothing ->
                          case model.modalAction of
                              1 ->
                                    Just(
                                          div[class "container"]
                                          [
                                              div[class "row"]
                                              [
                                                  div[class "col"]
                                                  [
                                                      span[class "modal_header center-block"][text "Proccessing your request please wait"]
                                                  ]
                                              ]
                                          ,   div[class "row"]
                                              [
                                                  div[class "col", style "text-align" "center"]
                                                  [
                                                        div[class "spinner-border", attribute "role" "status"]
                                                       [
                                                         span[class "sr-only"][text "Loading..."]
                                                       ] 
                                                  ]
                                              ]
                                          ]
                                        )
                              _ ->

                                    Just(
                                          div[class "container"]
                                          [
                                              div[class "row"]
                                              [
                                                  div[class "col"]
                                                  [
                                                      span[class "modal_header center-block"][text "Invalid Withdrawall information"]
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
                                                   button [type_ "button", style "width" "40%" , style "margin" "auto", style "padding" "10px 3px", onClick CloseModalResponse, class "btn btn-primary primary_button"][text "OK"]
                                                 ] 
                                             ]

                                          ]
                                        )



viewWallet : Model -> List (Html Msg)
viewWallet model =
         [
             div [ class "row", style "margin-top" "4vh", style "border" "2px solid rgb(239, 239, 239)", style "border-radius" "15px"]
            [ 
                div[class "col"]
                [
                  label [class "form-control", style "border" " 0px solid white"][text "Recipient's Wallet Address"]
                , input [ class "form-control", size 20, value model.wallet.public_key, onInput ChangeWalletKey, attribute "placeholder" "Withdraw to this wallet address", style "border" " 0px solid white", style "font-weight" "bold" ] []
                ]
            ]
        ]

viewBank : Model -> List (Html Msg)
viewBank model =
           [ 
             div[class "row", style "margin-top" "10px", style "border" "2px solid rgb(239, 239, 239)", style "border-radius" "15px" ]
               [
                 div[class "col"]
                 [
                   label [class "form-control", style "border" " 0px solid white", style "font-weight" "bold", style "color" "rgba(112,112,112,1)"][text "IBAN"]

                  , input [ class "form-control", size 20, Html.Attributes.value model.bankDetails.iban, onInput ChangeIban, attribute "placeholder" "e.g FD34200FFG3004", style "border" " 0px solid white", style "font-weight" "bold", style "color" "black", style "font-size" "1.25rem"] []
                 ]
               ]
            , div[class "row", style "margin-top" "10px"]
              [
                  div[class "col", style "padding" "4px", style "border" "2px solid rgb(239, 239, 239)", style "border-radius" "15px"]
                  [
                    label [class "form-control", style "border" " 0px solid white", style "font-weight" "bold", style "color" "rgba(112,112,112,1)"][text "Bank Name"]
                  , input [ class "form-control", size 20, Html.Attributes.value model.bankDetails.name, onInput ChangeBankName, attribute "placeholder" "e.g Deutche Bank" , style "border" " 0px solid white", style "font-weight" "bold", style "color" "black", style "font-size" "1.25rem"] []
                  ]
              ,   div[class "col",style "padding" "4px" ,style "border" "2px solid rgb(239, 239, 239)", style "border-radius" "15px", style "margin-left" "5px"]
                  [
                    label [class "form-control", style "border" " 0px solid white", style "font-weight" "bold", style "color" "rgba(112,112,112,1)"][text "BIC / SWIFT CODE"]
                  , input [ class "form-control", size 20, Html.Attributes.value model.bankDetails.swift_code, onInput ChangeSwift, attribute "placeholder" "e.g F32D400" , style "border" " 0px solid white", style "font-weight" "bold", style "color" "black", style "font-size" "1.25rem"] []
                  ]
              ]
            ,div[class "row", style "margin-top" "10px"]
             [
                div[class "col", style "padding" "4px", style "border" "2px solid rgb(239, 239, 239)", style "border-radius" "15px", style "margin-left" "5px"]
                 
                   (case model.user of 
                        Just user ->
                          [
                            label[class "form-control", style "border" " 0px solid white", style "font-weight" "bold", style "color" "rgba(112,112,112,1)"][text "Beneficial Owner"]
                            ,  input [ class "form-control", size 20, Html.Attributes.value model.bankDetails.beneficiaryName, attribute "placeholder" "e.g Mohamet Lee" , style "border" " 0px solid white", style "font-weight" "bold", style "color" "black", style "font-size" "1.25rem", value (user.firstName ++ " "++ user.lastName), attribute "readonly" "" ] []
                          ]
                        Nothing ->
                          [
                            label[class "form-control", style "border" " 0px solid white", style "font-weight" "bold", style "color" "rgba(112,112,112,1)"][text "Beneficiary name"]
                          , label[ class "form-control", size 20, Html.Attributes.value model.bankDetails.beneficiaryName , style "border" " 0px solid white", style "font-weight" "bold", style "color" "black", style "font-size" "1.25rem" , style "color" "red"] [text "Error user could not be fetched"]

                          ]
                   )
           ,  div[class "col", style "padding" "4px", style "border" "2px solid rgb(239, 239, 239)", style "border-radius" "15px"]
                 [
                    label [class "form-control", style "border" " 0px solid white", style "font-weight" "bold", style "color" "rgba(112,112,112,1)"][ text "Beneficiary Address"]

                  , input [ class "form-control", size 20, Html.Attributes.value model.bankDetails.recipientAddress, onInput ChangeRecipientAddress, attribute "placeholder" "" , style "border" " 0px solid white", style "font-weight" "bold", style "color" "black", style "font-size" "1.25rem"] []
                 ]

             ]
        ]       

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
    [
      Dropdown.subscriptions model.dropdownCurrencyState DropdownCurrencyToggle
    ]
