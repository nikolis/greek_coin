port module Main exposing (main)

import Api exposing (Cred)
import Avatar exposing (Avatar)
import Browser exposing (Document)
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onClick)
import Json.Decode as Decode exposing (Value)
import Page exposing (Page)
import Page.Article as Article
import Page.Exchange.TransactionsPage as TransactionsP
import Page.Prices as Prices
import Page.Home as Home
import Page.Login as Login
import Page.Empty as Empty
import Page.NotFound as NotFound
import Page.Profile.Profile as Profile
import Page.Register as Register
import Page.Settings as Settings
import Page.Transaction as Transaction
import Page.ContactUs as Contact
import Page.AboutUs as About
import Page.Payments.Payments as Payments
import Page.Withdraw as Withdraw
import Page.Company as Company
import Page.Faq as Faq
import Page.External.Verification as Verification
import Page.Exchange.Transactions

import Page.Legal.CookiesPolicy as Cookies
import Page.Legal.FeeTable as FeeTable
import Page.Legal.Kyc as Kyc
import Page.Legal.PrivacyNotice as Privacy
import Page.Legal.TermsOfService as Terms
import Page.Legal.Licenses as Licenses

import Route exposing (Route)
import Session exposing (Session)
import Task
import Time
import Url exposing (Url)
import Username exposing (Username)
import Viewer exposing (Viewer)
import Dict exposing (Dict)
import Task exposing (Task)
import Api.Data exposing (KrakenResponse, KrakenMetaResponse, decoderKrakenMeta, AssetMetaInfo)
import Http.Legacy
import Url.Builder
import Api.Endpoint as Endpoint
import Api.Data exposing (Treasury)
import Json.Encode as E
import Asset
import Json.Decode as Decode exposing (Decoder, decodeString, field, string)
import Json.Decode.Pipeline exposing (optional)
import Json.Encode as Encode
import Http
import Api2.Happy exposing (getBaseUrl)
import Api2.Data exposing (decoderUserFundBalance, UserFundBalance, Withdraw)
import Http.Detailed
import Loading
import Browser.Navigation as Navigat

port renderChatButton : String -> Cmd msg

type HelperModel
    = Redirect Session
    | NotFound Session
    | Home Home.Model
    | Settings Settings.Model
    | Login Login.Model
    | Profile Profile.Model
    | Article Article.Model
    | TransactionsP  TransactionsP.Model
    | Prices Prices.Model 
    | Transaction Transaction.Model
    | About About.Model
    | Payments Payments.Model
    | Contact Contact.Model
    | Withdraw Withdraw.Model
    | Faq Faq.Model
    | Company Company.Model
    | Cookies Cookies.Model
    | FeeTable FeeTable.Model
    | Kyc Kyc.Model
    | Privacy Privacy.Model
    | Terms Terms.Model
    | Licenses Licenses.Model
    | Verification (Maybe String) (Maybe String) Verification.Model


type alias Model  = 
    {
       funds : Maybe (List Treasury)
       , withdraws : Maybe (List Withdraw)
       , helperModel : HelperModel
       , selectedDropdownValue : Maybe String
       , initChannels : Bool
       , newsEmail : String
       , registerStatus : State
       , transactionsModel : Maybe Page.Exchange.Transactions.Model
       , viewCookies : Bool
    }

-- MODEL
type State = 
    Initial 
    | Proccessing
    | Error String
    | Done

init : Maybe Viewer -> Url -> Nav.Key -> ( Model, Cmd Msg )
init maybeViewer url navKey =
    case maybeViewer of 
        Just viewer ->
          let
            name = Username.toString (Viewer.username viewer)
            cookies = Viewer.cookiesGet viewer
            {--(partialModel, ccom) = changeRouteTo2 (Route.fromUrl url)--}
            (partialModel, ccom) =
              case String.isEmpty name of
                True ->
                   changeRouteTo (Route.fromUrl url)
                      (Redirect (Session.fromViewer navKey maybeViewer))

                False ->
                   changeRouteTo2 (Route.fromUrl url)
                      (Redirect (Session.fromViewer navKey maybeViewer))
  
            (modelTrans, transCommands) = Page.Exchange.Transactions.init (Session.fromViewer navKey maybeViewer) Nothing
          in
          ( Model Nothing Nothing partialModel Nothing False "" Initial (Just modelTrans) cookies, Cmd.batch [ccom, fetchDaBal (Just (Viewer.cred viewer)) "sadf"
                                                                                                     ,  (Cmd.map (\tr -> (GotTransactionInner tr)) transCommands)])

        Nothing ->
          let
            (partialModel, ccom) = changeRouteTo (Route.fromUrl url)
               (Redirect (Session.fromViewer navKey maybeViewer))
      
          in
          ( Model Nothing Nothing partialModel Nothing False "" Initial Nothing True, Cmd.batch [ccom, fetchDaBal Nothing "sadf"])


fetchBalance : Maybe Cred -> String -> Task Http.Legacy.Error (UserFundBalance)
fetchBalance cred userId =
    let
        request =
            Api.get (Endpoint.fund_balance [] ) cred decoderUserFundBalance
    in
    Http.Legacy.toTask request
     

fetchDaBal : Maybe Cred -> String -> Cmd Msg
fetchDaBal cred id =
    Task.attempt HelperMsg (fetchBalance cred id)

-- VIEW
maskStyle : List (Html.Attribute msg)
maskStyle =
    [ 
     style "position" "fixed"
    , style "top" "97%"
    , style "left" "50%"
    , style "height" "20%"
    , style "max-height" "80%"
    , style "width" "100%"
    , style "max-width" "100%"
    , id "o kippppp2322"
    , style "z-index" "35"
    ]

modalStyle : List (Html.Attribute msg)
modalStyle =
    [ style "background-color" "rgb(239, 239, 239)"
    , style "position" "absolute"
    , style "top" "0"
    , style "left" "0"
    , style "width" "100%"
    , style "padding" "10px"
    , style "box-shadow" "1px 1px 5px rgba(0,0,0,0.5)"
    , style "transform" "translate(-50%, -50%)"
    ]


view : Model -> Document Msg
view model =
    let
        viewer =
            Session.viewer (toSession model.helperModel)

        viewPage page toMsg config =
            let
                { title, body } =
                    Page.view model.transactionsModel viewer model.funds model.withdraws  page config
            in
            { title = title
            , body = (List.map (Html.map toMsg) body)
            }

        viewPageModal page  toMsg config modalContent=
            let
                { title, body } =
                    Page.viewModal model.transactionsModel  viewer model.funds model.withdraws page config modalContent 
            in
            { title = title
            , body = (List.map (Html.map toMsg) body)
            }

        viewCookies = 
               (
                case model.viewCookies of 
                    True ->
                      div  maskStyle 
                        [ div  modalStyle 
                         [  
                           div[class "container"]
                           [
                               div[class "row", style "margin-bottom" "20px"]
                               [
                                div[class "col"]
                                [
                                    p[]
                                    [
                                      span[style "font-weight" "bold", style "font-size" "1.10rem"][text "We use cookies to boost our security and improve user experience. If you continue to use this site we will assume that your are happy with it"]
                                    ,  button [type_ "button" ,  onClick CloseCookies , class "btn btn-primary primary_button2", style "font-size" "1.10rem"]
                                      [
                                        text "Accept" 
                                      ]
                                     , a[type_ "button" , href (Route.routeToString Route.Privacy ) , class "btn  btn-primary primary_button2", style "font-size" "1.10rem"]
                                     [  
                                       text "Privacy Notice" 
                                     ]
                                                                     ]
                                
                               ]

                                     
                                
                             ]  
                           ]
                         ]
                        ]

                    False ->
                        div[][]

                 )

        viewEndPage document = 
            let
                body = document.body ++ [viewCookies]++ [(viewFooterMain model)]
            in
            {title = document.title, body = body}
    in
    case model.helperModel of
        
        Redirect _ ->
            Page.view model.transactionsModel  viewer model.funds model.withdraws Page.Other Empty.view

        NotFound _ ->
            viewEndPage (Page.view model.transactionsModel viewer model.funds model.withdraws Page.Other NotFound.view)

        Settings settings ->
            viewEndPage (viewPage Page.Other GotSettingsMsg (Settings.view settings))

        Prices prices ->
            viewEndPage (viewPage Page.Prices GotPricesMsg (Prices.view prices))

        About about ->
            viewEndPage (viewPage Page.About GotAboutMsg (About.view about))

        Contact contact ->
            viewEndPage (viewPage Page.Contact GotContactMsg (Contact.view contact))

        Transaction  transaction ->
            viewEndPage (viewPage Page.Transaction  GotTransactionMsg (Transaction.view transaction))

        Company company ->
            viewEndPage (viewPage Page.Company GotCompanyMsg (Company.view company))

        Faq faq ->
            viewEndPage (viewPage Page.Faq GotFaqMsg (Faq.view faq))
 
        Home home ->
            viewEndPage (viewPage Page.Home GotHomeMsg (Home.view home))

        Payments payments ->
            viewEndPage (viewPageModal Page.Payments GotPaymentsMsg (Payments.view payments) (Payments.viewModal payments) )

        Login login ->
            viewEndPage (viewPageModal Page.Other GotLoginMsg (Login.view login) (Login.viewModal login))

        Withdraw withdraw ->
              viewEndPage( viewPage Page.Withdraw GotWithdrawMsg (Withdraw.view withdraw))

        Cookies cookies ->
              viewEndPage( viewPage Page.Cookies CookiesMsg (Cookies.view cookies))

        Licenses licenses ->
              viewEndPage( viewPage Page.Licenses LicensesMsg (Licenses.view licenses))

        Kyc kyc ->
              viewEndPage( viewPage Page.Kyc KycMsg (Kyc.view kyc))

        Privacy privacy ->
              viewEndPage( viewPage Page.Privacy PrivacyMsg (Privacy.view privacy))

        Terms terms ->
              viewEndPage( viewPage Page.Terms TermsMsg (Terms.view terms))

        FeeTable fee ->
              viewEndPage( viewPage Page.FeeTable FeeTableMsg (FeeTable.view fee))

        Profile  profile ->
            viewEndPage (viewPageModal Page.Profile  GotProfileMsg (Profile.view profile)          (Profile.viewModal profile))

        Article article ->
            viewEndPage (viewPage Page.Other GotArticleMsg (Article.view article))

        TransactionsP transactionsp ->
            viewEndPage (viewPageModal Page.NewArticle GotTransactionspMsg (TransactionsP.view transactionsp) (TransactionsP.viewModal transactionsp))
        
        Verification attrs parameter verification ->
            viewEndPage (viewPageModal Page.Verification GotVerificationMsg (Verification.view verification) (Verification.viewModal verification))




-- UPDATE
type Msg = 
      ChangedRoute (Maybe Route)
    | ChangedUrl Url
    | ClickedLink Browser.UrlRequest
    | GotHomeMsg Home.Msg
    | GotSettingsMsg Settings.Msg
    | GotLoginMsg Login.Msg
    | GotWithdrawMsg Withdraw.Msg
    | GotRegisterMsg Register.Msg
    | GotProfileMsg Profile.Msg
    | GotArticleMsg Article.Msg
    | GotTransactionspMsg TransactionsP.Msg
    | GotTransactionMsg Transaction.Msg
    | GotSession Session
    | GotPricesMsg  Prices.Msg
    | HelperMsg (Result Http.Legacy.Error UserFundBalance)
    | CompletedRegister (Result (Http.Detailed.Error String) ( Http.Metadata, String ))
    | DropDownChange (Maybe String)
    | GotAboutMsg About.Msg
    | GotContactMsg Contact.Msg
    | GotPaymentsMsg Payments.Msg
    | GotTransactionInner Page.Exchange.Transactions.Msg 
    | GotFaqMsg Faq.Msg
    | GotCompanyMsg Company.Msg
    | GotVerificationMsg Verification.Msg
    | CookiesMsg Cookies.Msg
    | FeeTableMsg FeeTable.Msg
    | KycMsg Kyc.Msg
    | PrivacyMsg Privacy.Msg
    | TermsMsg Terms.Msg
    | LicensesMsg Licenses.Msg
    | NewsEmail String
    | RegisterNewsLetter
    | RegisterRetry
    | CloseCookies

toSession : HelperModel -> Session
toSession page =
    case page of
        Redirect session ->
            session

        NotFound session ->
            session

        Home home ->
            Home.toSession home

        Transaction transaction ->
            Transaction.toSession transaction

        Withdraw withdraw ->
            Withdraw.toSession withdraw    

        Settings settings ->
            Settings.toSession settings

        Prices prices ->
            Prices.toSession prices

        Company company ->
            Company.toSession company

        Cookies cookies ->
            Cookies.toSession cookies 

        FeeTable feeTable ->
            FeeTable.toSession feeTable

        Kyc kyc ->
            Kyc.toSession kyc

        Privacy privacy ->
            Privacy.toSession privacy

        Terms terms ->
            Terms.toSession terms

        Licenses licenses ->
            Licenses.toSession licenses

        Faq faq ->
            Faq.toSession faq

        About about ->
            About.toSession about

        Payments payments ->
            Payments.toSession payments

        Contact contact ->
            Contact.toSession contact

        Login login ->
            Login.toSession login

        Profile  profile ->
            Profile.toSession profile

        Verification _ _ verification ->
            Verification.toSession verification

        Article article ->
            Article.toSession article

        TransactionsP  transactionsp ->
            TransactionsP.toSession transactionsp

changeRouteTo2 : Maybe Route -> HelperModel -> ( HelperModel, Cmd Msg )
changeRouteTo2 maybeRoute model =
    let
        session =
            toSession model
    in
    case maybeRoute of
        Nothing ->
            ( NotFound session, Cmd.none )

        Just Route.Root ->
            ( model, Cmd.batch [Route.replaceUrl (Session.navKey session) Route.NewArticle] )

        Just Route.Logout ->
            ( model, Api.logout )


        Just Route.Withdraw ->
            Withdraw.init session
              |> updateWith Withdraw GotWithdrawMsg model

        Just Route.NewArticle ->
            TransactionsP.init session
                |> updateWith (TransactionsP ) GotTransactionspMsg model

        Just Route.Company ->
            Company.init session
                |> updateWith (Company ) GotCompanyMsg model

        Just Route.Faq ->
            Faq.init session
                |> updateWith (Faq ) GotFaqMsg model

        Just (Route.EditArticlePre id ammount) ->
            TransactionsP.initPre session id ammount
                |> updateWith (TransactionsP ) GotTransactionspMsg model

        Just Route.Settings ->
            Settings.init session
                |> updateWith Settings GotSettingsMsg model

        Just Route.Payments ->
            Payments.init session
                |> updateWith Payments GotPaymentsMsg model
 
        Just Route.Home ->
            TransactionsP.init session
                |> updateWith (TransactionsP) GotTransactionspMsg model

        Just Route.Login ->
            Login.init session 1
                |> updateWith Login GotLoginMsg model

        Just Route.Register ->
            Login.init session 2
                |> updateWith Login GotLoginMsg model

        Just Route.Prices ->
            Prices.init session
                |> updateWith Prices GotPricesMsg model

        Just Route.About ->
            About.init session
                |> updateWith About GotAboutMsg model

        Just Route.Contact ->
            Contact.init session
                |> updateWith Contact GotContactMsg model

        Just Route.Transaction ->
            Transaction.init session
                |> updateWith Transaction GotTransactionMsg model
 
        Just (Route.Verification attrs parameter) ->
            Verification.init session attrs parameter
                |> updateWith (Verification attrs parameter) GotVerificationMsg model

        Just Route.Profile  ->
            Profile.init session 
                |> updateWith Profile GotProfileMsg model

        Just (Route.Article) ->
            Article.init session 
                |> updateWith Article GotArticleMsg model

        Just (Route.Cookies) ->
            Cookies.init session 
                |> updateWith (Cookies) CookiesMsg model

        Just (Route.FeeTable) ->
            FeeTable.init session 
                |> updateWith FeeTable FeeTableMsg model

        Just (Route.Kyc ) ->
            Kyc.init session 
                |> updateWith Kyc KycMsg model

        Just (Route.Privacy) ->
            Privacy.init session 
                |> updateWith Privacy PrivacyMsg model


        Just (Route.Terms) ->
            Terms.init session 
                |> updateWith Terms TermsMsg model

        Just (Route.Licenses) ->
            Licenses.init session 
                |> updateWith Licenses LicensesMsg model




changeRouteTo : Maybe Route -> HelperModel -> ( HelperModel, Cmd Msg )
changeRouteTo maybeRoute model =
    let
        session =
            toSession model
    in
    case maybeRoute of
        Nothing ->
            ( NotFound session, Cmd.none )

        Just Route.Root ->
            ( model, Cmd.batch [Route.replaceUrl (Session.navKey session) Route.NewArticle] )

        Just Route.Logout ->
            ( model, Api.logout )


        Just Route.Withdraw ->
            Withdraw.init session
              |> updateWith Withdraw GotWithdrawMsg model

        Just Route.NewArticle ->
            TransactionsP.init session
                |> updateWith (TransactionsP ) GotTransactionspMsg model

        Just Route.Company ->
            Company.init session
                |> updateWith (Company ) GotCompanyMsg model

        Just Route.Faq ->
            Faq.init session
                |> updateWith (Faq ) GotFaqMsg model

        Just (Route.EditArticlePre id ammount) ->
            TransactionsP.initPre session id ammount
                |> updateWith (TransactionsP ) GotTransactionspMsg model

        Just Route.Settings ->
            Settings.init session
                |> updateWith Settings GotSettingsMsg model

        Just Route.Payments ->
            Payments.init session
                |> updateWith Payments GotPaymentsMsg model
 
        Just Route.Home ->
            Home.init session
                |> updateWith Home GotHomeMsg model

        Just Route.Login ->
            Login.init session 1
                |> updateWith Login GotLoginMsg model

        Just Route.Register ->
            Login.init session 2
                |> updateWith Login GotLoginMsg model

        Just Route.Prices ->
            Prices.init session
                |> updateWith Prices GotPricesMsg model

        Just Route.About ->
            About.init session
                |> updateWith About GotAboutMsg model

        Just Route.Contact ->
            Contact.init session
                |> updateWith Contact GotContactMsg model

        Just Route.Transaction ->
            Transaction.init session
                |> updateWith Transaction GotTransactionMsg model
 
        Just Route.Profile ->
            Profile.init session
                |> updateWith Profile GotProfileMsg model

        Just (Route.Verification attrs par) ->
            Verification.init session attrs par
                |> updateWith (Verification attrs par) GotVerificationMsg model

        Just (Route.Article) ->
            Article.init session 
                |> updateWith Article GotArticleMsg model
       
        Just (Route.Cookies) ->
            Cookies.init session 
                |> updateWith (Cookies) CookiesMsg model

        Just (Route.FeeTable) ->
            FeeTable.init session 
                |> updateWith FeeTable FeeTableMsg model

        Just (Route.Kyc ) ->
            Kyc.init session 
                |> updateWith Kyc KycMsg model

        Just (Route.Privacy) ->
            Privacy.init session 
                |> updateWith Privacy PrivacyMsg model


        Just (Route.Terms) ->
            Terms.init session 
                |> updateWith Terms TermsMsg model

        Just (Route.Licenses) ->
            Licenses.init session 
                |> updateWith Licenses LicensesMsg model



update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.helperModel ) of
        ( ClickedLink urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    case url.fragment of
                        {--Nothing ->
                            -- If we got a link that didn't include a fragment,
                            -- it's from one of those (href "") attributes that
                            -- we have to include to make the RealWorld CSS work.
                            --
                            -- In an application doing path routing instead of
                            -- fragment-based routing, this entire
                            -- `case url.fragment of` expression this comment
                            -- is inside would be unnecessary.
                            ( model, Cmd.none )--}

                        Just "pageSubmenu" ->
                            (model, Cmd.none)

                        _  ->
                            ( model
                            , Nav.pushUrl (Session.navKey (toSession model.helperModel)) (Url.toString url)
                            )

                Browser.External href ->
                    ( model
                    , Nav.load href
                    )

        ( ChangedUrl url, _ ) ->
            case url.fragment of
                Just "pageSubmenu" ->
                    (model, Cmd.none)
                _ ->
                  let
                    (helperModel, cmnd) = changeRouteTo (Route.fromUrl url) model.helperModel
                    _ = Debug.log "Here:2 " url 

                  in
                  ({model | helperModel = helperModel}, Cmd.batch[cmnd, fetchDaBal Nothing "asdf"] )

        ( ChangedRoute route, _ ) ->
            let
              (helpModel, cmnd) =  changeRouteTo route model.helperModel
              _ = Debug.log "Here:1 " route 
            in
            ({model | helperModel = helpModel}, Cmd.batch [cmnd, fetchDaBal Nothing "sdfgsgdf"])
        (NewsEmail str, _) ->
            ({model | newsEmail = str}, Cmd.none)

        (RegisterNewsLetter, _ ) ->
            ( { model | registerStatus = Proccessing }, registerNewsLetter model.newsEmail)

        (RegisterRetry, _) ->
            ({model | registerStatus = Initial, newsEmail = ""}, Cmd.none)

        (CompletedRegister (Err error), _ )->
           case error of
               Http.Detailed.BadStatus metadata body ->
                 let
                   md =  
                     case Decode.decodeString decoderChangeset body of
                       Ok errorBody ->
                           let
                             dictComp = Dict.map (\k b -> List.map (\c -> (k,c)) b ) errorBody.error
                             values = Dict.values dictComp
                             listClean = List.concat values
                             list = List.map (\(a,b) -> a++": "++ b) listClean

                             listStr = List.map (\(a,b) -> a++": " ++b) listClean
                           in

                          {model | registerStatus = Error "Invalid email"}

                       Err error2 ->
                          {model | registerStatus = Error "Invalid email"}
                 in
                 (md, Cmd.none)

               Http.Detailed.Timeout ->
                  let
                   md = {model | registerStatus = (Error "Server timeout")}
                 in
                 (md, Cmd.none)
               _ ->
                 (model, Cmd.none)

        ( CompletedRegister (Ok (metadata, response)), _ ) ->
           let
             md = { model | registerStatus = Done} 
           in
           (md, Cmd.none)


        ( GotSettingsMsg subMsg, Settings settings ) ->
            let
             (helpModel, cmnd) = 
              Settings.update subMsg settings
                |> updateWith Settings GotSettingsMsg model.helperModel
            in
            ({ model | helperModel = helpModel}, cmnd)

        ( GotFaqMsg subMsg, Faq faq ) ->
            let
             (helpModel, cmnd) = 
              Faq.update subMsg faq
                |> updateWith Faq GotFaqMsg model.helperModel
            in
            ({ model | helperModel = helpModel}, cmnd)

        ( FeeTableMsg subMsg, FeeTable faq ) ->
            let
             (helpModel, cmnd) = 
              FeeTable.update subMsg faq
                |> updateWith FeeTable FeeTableMsg model.helperModel
            in
            ({ model | helperModel = helpModel}, cmnd)

        ( GotLoginMsg subMsg, Login login ) ->
            let
              (helpModel, cmnd) = 
                Login.update subMsg login
                    |> updateWith Login GotLoginMsg model.helperModel
            in
            ({model | helperModel = helpModel}, cmnd)

        ( GotWithdrawMsg subMsg, Withdraw withdraw ) ->
            let
              (helpModel, cmnd) = 
                Withdraw.update subMsg withdraw
                  |> updateWith Withdraw GotWithdrawMsg model.helperModel
            in
            ({model | helperModel = helpModel}, cmnd)

        ( GotPaymentsMsg subMsg, Payments payments ) ->
            let
              (helpModel, cmnd) = 
                Payments.update subMsg payments
                  |> updateWith Payments GotPaymentsMsg model.helperModel
            in
            ({model | helperModel = helpModel}, cmnd)


        ( GotTransactionMsg subMsg, Transaction transaction ) ->
            let
              (helpModel, cmnd) = 
                Transaction.update subMsg transaction
                  |> updateWith Transaction GotTransactionMsg model.helperModel
            in
            ({model | helperModel = helpModel}, cmnd)


        ( GotHomeMsg subMsg, Home home ) ->
            let
              (helpModel, cmnd) = 
               Home.update subMsg home
                |> updateWith Home GotHomeMsg model.helperModel
            in
            ({ model | helperModel = helpModel}, cmnd)

        ( GotPricesMsg subMsg, Prices prices ) ->
            let
              (helpModel, cmnd) = 
                Prices.update subMsg prices
                    |> updateWith Prices GotPricesMsg model.helperModel
            in
            ({ model | helperModel = helpModel}, cmnd)
 
        ( GotProfileMsg subMsg, Profile  profile ) ->
            let
              (helpModel, cmnd) = 
                Profile.update subMsg profile
                  |> updateWith Profile  GotProfileMsg model.helperModel
            in
            ({ model | helperModel = helpModel}, cmnd)

        ( GotVerificationMsg subMsg, Verification parameter argument mdVer) ->
            let
              (helpModel, cmnd) = 
                Verification.update subMsg mdVer
                  |> updateWith (Verification parameter argument) GotVerificationMsg model.helperModel
            in
            ({ model | helperModel = helpModel}, cmnd)

        ( GotArticleMsg subMsg, Article article ) ->
            let
              ( helpModel, cmnd) = 
                Article.update subMsg article
                  |> updateWith Article GotArticleMsg model.helperModel
            in
            ({ model | helperModel = helpModel}, cmnd)

        ( GotTransactionspMsg subMsg, TransactionsP transactionsp ) ->
            let
              (helpModel, cmnd) = 
                TransactionsP.update subMsg transactionsp
                  |> updateWith TransactionsP  GotTransactionspMsg model.helperModel
            in
            ({ model | helperModel = helpModel}, cmnd)

        ( GotSession session, Redirect _ ) ->
            let
              _ = Debug.log "session" "cjhagese ------->"
              cred = Session.cred session
              (helpModel, cmnd) = 
                  case cred of 
                      Just crd ->
                        let
                            _ = Debug.log "some " "some some n---------------------222"
                        in
                        ( Redirect session
                            , Route.replaceUrl (Session.navKey session) Route.Home
                        )
                      Nothing ->
                          let
                             _ = Debug.log "no cred" "n--------------------------->"
                          in
                        ( Redirect session, Cmd.none)
            in
            ({ model | helperModel = helpModel}, cmnd)

        (HelperMsg (Ok kserFundBalance), _)->
           ( {model | funds = Just kserFundBalance.funds, withdraws = Just kserFundBalance.withdraws}, Cmd.none)

        (CloseCookies, _) ->
            ({model | viewCookies = False}, Api.storeCredCook (Session.cred (toSession model.helperModel)) False)

        (GotTransactionInner inMsg, _  ) ->
           case model.transactionsModel of
               Just mdT ->
                 let
                   (modelInner, com) =Page.Exchange.Transactions.update  inMsg mdT 
                 in
                 ({model | transactionsModel = Just modelInner}, Cmd.map (\tr -> GotTransactionInner tr) com ) 
               Nothing ->
                   (model, Cmd.none)


        (HelperMsg (Err error), _) ->
            (model, Cmd.none)

        ( _, _ ) ->
            -- Disregard messages that arrived for the wrong page.
            ( model, Cmd.none )


updateWith : (subModel -> HelperModel) -> (subMsg -> Msg) -> HelperModel -> ( subModel, Cmd subMsg ) -> ( HelperModel, Cmd Msg )
updateWith toModel toMsg model ( subModel, subCmd ) =
    ( toModel subModel
    , Cmd.batch [(Cmd.map toMsg subCmd){--, (fetchDaBal "sadf")--}]
    )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.helperModel of
        NotFound _ ->
            Sub.none

        Redirect _ ->
            Session.changes GotSession (Session.navKey (toSession model.helperModel))

        Settings settings ->
            Sub.map GotSettingsMsg (Settings.subscriptions settings)

        Payments payments ->
            Sub.map GotPaymentsMsg (Payments.subscriptions payments)

        Company company ->
            Sub.map GotCompanyMsg (Company.subscriptions company)

        Faq faq ->
            Sub.map GotFaqMsg (Faq.subscriptions faq)

        Home home ->
            Sub.map GotHomeMsg (Home.subscriptions home)

        Login login ->
            Sub.map GotLoginMsg (Login.subscriptions login)

        Profile  profile ->
            Sub.map GotProfileMsg (Profile.subscriptions profile)

        Verification _ _ verification ->
            Sub.map GotVerificationMsg (Verification.subscriptions verification)

        Prices prices ->
            Sub.map GotPricesMsg (Prices.subscriptions prices)

        Transaction transaction ->
            Sub.map GotTransactionMsg (Transaction.subscriptions transaction)

        Article article ->
            Sub.map GotArticleMsg (Article.subscriptions article)

        TransactionsP  transactionsp ->
            Sub.map GotTransactionspMsg (TransactionsP.subscriptions transactionsp)

        Contact  contact ->
            Sub.map GotContactMsg (Contact.subscriptions contact)

        About about ->
            Sub.map GotAboutMsg (About.subscriptions about)

        Withdraw withdraw ->
            Sub.map GotWithdrawMsg (Withdraw.subscriptions withdraw)

        Cookies cookies ->
            Sub.map CookiesMsg (Cookies.subscriptions cookies)

        FeeTable feeTable ->
            Sub.map FeeTableMsg (FeeTable.subscriptions feeTable)

        Kyc  kyc ->
            Sub.map KycMsg (Kyc.subscriptions kyc)

        Privacy privacy ->
            Sub.map PrivacyMsg (Privacy.subscriptions privacy)

        Terms terms ->
            Sub.map TermsMsg (Terms.subscriptions terms)

        Licenses licenses ->
            Sub.map LicensesMsg (Licenses.subscriptions licenses)



-- MAIN


main : Program Value Model Msg
main =
    Api.application Viewer.decoder
        { init = init
        , onUrlChange = ChangedUrl
        , onUrlRequest = ClickedLink
        , subscriptions = subscriptions
        , update = update
        , view = view
        }


viewFooterMain : Model -> Html Msg
viewFooterMain model =
    footer []
        [ footer [ class "page-footer font-small blue pt-4" ,style "background-color" "white", style "width" "100%", style "background-color" "rgb(239, 239, 239)"]
          [ 
            div [class "container-fluid text-center text-md-left", style "margin-left" "50px"]
            [
              div[class "row  justify-content-between"]
              [
                
                div[class "col col-xs-2 col-sm-2 col-lg-1" ]
                  [
                   logoIcon2
                  ]
               , div[class "col-2 col-md-3 col-lg-2 col-xs-4 col-sm-4", style "margin-left" "2vw"]
                  [
                    span[class "footer_text_header"][text "Communication"]
                   ,   ul [class "list-unstyled", style "margin-top" "2vh"]
                        [
                          li [style "color" "white", style "margin-bottom" "1vh", class "row no-gutters"]
                          [
                           div[class "col-1 no-gutters", style "margin-top" "auto", style "margin-bottom" "auto", style "margin-right" "0.5vw"]
                           [
                            img[src "images/pin.svg", style "width" "100%", style "height" "50%"][]
                           ]
                          , div[class "col-10 no-gutters"]
                            [
                             span[class "footer_text"][text "ESTONIA Roseni 13, Tallinn Harju, 10111 "]
                            , br[][]
                            , span[class "footer_text"][text "GREECE L. V. Kon/nou 42, Athens, 11635"]
                            ]
                          ]
                         , li [style "color" "white", style "margin-bottom" "1vh", class "row no-gutters"]
                           [
                            div[class "col-1 no-gutters", style "margin-top" "auto", style "margin-bottom" "auto", style "margin-right" "0.5vw"]
                            [
                             img[src "images/email.svg", style "width" "100%", style "height" "50%"][]
                            ]
                          , div[class "col-10 no-gutters"]
                            [
                             span[class "footer_text"][text "info@greek-coin.gr"]
                            ]
                          ]
 
                         , li [style "color" "white", style "margin-bottom" "1vh", class "row no-gutters"]
                           [
                            div[class "col-1 no-gutters", style "margin-top" "auto", style "margin-bottom" "auto", style "margin-right" "0.5vw"]
                            [
                             img[src "images/mobile.svg", style "width" "100%", style "height" "50%"][]
                            ]
                          , div[class "col-10 no-gutters"]
                            [
                             span[class "footer_text"][text "+372 60 23 53 0"]
                            , br[][] 
                            , span[class "footer_text"][text "+30 211 40 33 211"] 
                            ]
                          ]
 
                         ] 
                        ]

                , div[class "col col-sm-5 col-xs-5 col-md-3  col-lg"]
                  [
                      span[class "footer_text_header"][text "Details"]
                  ,   ul [class "list-unstyled", style "font-weight" "bold", style "margin-top" "2vh"]
                        [
                          li []
                          [ a [style "color" "rgba(68,68,68,1)",Route.href Route.Company] 
                            [ 
                                span[class "footer_text"][text "Company"]
                            ]
                          ]
                         , li []
                          [ a [style "color" "rgba(68,68,68,1)",Route.href Route.Prices] 
                            [ 
                                span[class "footer_text"][text "Prices"]
                            ]
                          ]
                         , li []
                          [ a [style "color" "rgba(68,68,68,1)",Route.href Route.Faq] 
                            [ 
                                span[class "footer_text"][text "FAQ"]
                            ]
                          ]
                         , li []
                          [ a [style "color" "rgba(68,68,68,1)",Route.href Route.Contact] 
                            [
                               span[class "footer_text"][ text "Contact us"]
                            ]
                          ]
                        ]
                  ]
          , div[class "col col-sm-5 col-xs-5 col-md-4 col-lg"]
                  [
                      span[class "footer_text_header"][text "Legal"]  
                  ,   ul [class "list-unstyled", style "font-weight" "bold", style "margin-top" "2vh"]
                        [
                          li []
                          [ a [style "color" "rgba(68,68,68,1)",Route.href Route.Privacy] 
                             [
                                 span[class "footer_text"][ text "Privacy Notice"]
                             ]
                          ]
                         , li []
                          [ a [style "color" "rgba(68,68,68,1)",Route.href Route.Terms] 
                            [ 
                                span[class "footer_text"][text "Terms of Service"]
                            ]
                          ]
                         , li []
                          [ a [style "color" "rgba(68,68,68,1)",Route.href Route.Cookies]
                            [ 
                                span[class "footer_text"][ text "Cookies Policy"]
                            ]
                          ]
                         , li []
                          [ a [style "color" "rgba(68,68,68,1)",Route.href Route.Kyc]
                            [ 
                                span[class "footer_text"][ text "KYC/AML/CTF Policy"]
                            ]
                          ]

                         , li []
                          [ a [style "color" "rgba(68,68,68,1)",Route.href Route.FeeTable]
                            [ 
                                span[class "footer_text"][ text "Free Table"]
                            ]
                          ]
                         , li []
                          [ a [style "color" "rgba(68,68,68,1)",Route.href Route.Licenses]
                            [ 
                                span[class "footer_text"][ text "Licenses"]
                            ]
                          ]


                        ]
                  ]
                , div[class "col-3 col-sm-5 col-xs-5 col-md-5 col-lg-3", style "margin-right" "4vw"]
                  [
                     span[class "footer_text_header"][text "Newsletter"]
                   , div[class "input-group mb-3", style "margin-top" "20px", style "background-color" "white", style "border-radius" "160px", style "padding" "8px"]
                     [
                        ( case model.registerStatus of 
                            Initial ->
                               input[type_ "text", class "form-control footer_text", placeholder  "Enter your email address", style "border-style" "none", value model.newsEmail, onInput NewsEmail][]
                            Proccessing ->
                               input[disabled True, type_ "text", class "form-control footer_text", placeholder  "Enter your email address", style "border-style" "none", value model.newsEmail, onInput NewsEmail][]
                            Done ->
                               p[type_ "text", class "form-control footer_text", style "border-style" "none"][text "Successfull Registration"]
                            Error reason ->
                               p[type_ "text", class "form-control footer_text", style "border-style" "none"][text reason]
                           )


                      , div[class "input-group-append"]
                        [
                            ( case model.registerStatus of
                                Initial ->
                                  button[class "btn btn-secondary", style "width" "45px", style "height" "45px", style "background-color" "rgb(0, 99, 166)", style "border-radius" "50px"] [img [style "width" "100%",src "images/send.svg",style "height" "100%" ,style "margin" "auto", onClick RegisterNewsLetter][]]
                                Proccessing ->
                                    Loading.icon
                                Done -> 
                                    div[][]
                                _ ->
                                    button[class "btn btn-secondary", style "width" "45px", style "height" "45px", style "background-color" "rgb(0, 99, 166)", style "border-radius" "50px"] [img [style "width" "100%",src "images/retry.svg",style "height" "100%" ,style "margin" "auto", onClick RegisterRetry][]]
                              )
                        ]
                     ]
                    , div[class "row no-gutters"]
                     [
                         div[class "col-1", style "margin-right" "15px"]
                         [
                           input[type_ "checkbox",  name "genres", value "adventure", id "adventure_id", style "visible" "false"][]
                         , label[for "adventure_id" ][]
                         ]
                     ,   div[class "col"]
                        [
                           span[ style "font-size" "0.7rem", style "color" "rgba(112,112,112,1)"][text "I agree to receive news, offers, coin / token listings and other news or promotions from GREEKCOIN, and I have read and agreed to the Privacy Policy and Terms of Service."]
                        ]
                     ]

                  ]
                , div[class "col col-lg-3"]
                  [
                   span[class "footer_text_header"][text "Social Media"]
                  ,p[style "margin-top" "2vh"][a [href "https://www.facebook.com/Greek-Coin-2010949822452284" ][img [src "images/facebook.svg", style "width" "1.5vw", style "margin-right" "1.5vw"][] ] , a[href "https://twitter.com/greekcoin1"][img[src "images/twitter.svg", style "width" "1.5vw", style "margin-right" "1.5vw"][]], img[src "images/linkedin.svg", style "width" "1.5vw"][]]
                  , div[class "row"]
                    [
                       div[class "col no-gutters", style "max-width" "2vw"][img [src "images/certified.svg", style "width" "1.5vw", style "float" "left"][]]
                    ,  div[class "col-10 no-gutters"]
                        [
                            span[style "font-weight" "bold"][text "Licensed from"]
                            
                        ,   p[][span[][text """European Union, Republic of Estonia
Financial Intelligence Unit
FRK001080 - Exchange services
FRK001195 - Wallet services"""]]
                       ]
                    ]  

                  ]
                ]
                

            
           ]

          ]
        ]

logoIcon2 : Html msg
logoIcon2 =
    Html.img
        [ Asset.src Asset.logo2
        , style "width" "6vw"
        , style "align" "right"
        , class "text-center"
        ]
        []

registerNewsLetter : String -> Cmd Msg
registerNewsLetter email   =
    let
        user =
            Encode.object
                [ ( "email", Encode.string email )
                ]

        body =
            Encode.object [ ( "news_user", user ) ]
                |> Http.jsonBody
    in
    Http.request
    {
     headers =  []
    , method = "POST"
    , body = body
    , url = (getBaseUrl ++ "/api/v1/newsletter/users")
    , expect = Http.Detailed.expectString  CompletedRegister 
    , timeout = Nothing
    , tracker = Nothing
    }

decoderChangeset : Decoder ChangesetError
decoderChangeset =
    Decode.succeed ChangesetError
    |> Json.Decode.Pipeline.required "errors" (Decode.dict (Decode.list string))

type alias ChangesetError =
    {
        error : Dict String (List String)
    }

