module Page.External.Verification exposing (..)

import Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (class, classList, href, style, placeholder,attribute, tabindex, id, type_, align)
import Html.Events exposing (onClick)
import Http
import Json.Encode as Encode
import Json.Decode exposing (list, string, Decoder, field, map5, decodeString, errorToString, nullable)
import Json.Decode.Pipeline exposing (required, optional, hardcoded)
import Api2.Happy exposing (getBaseUrl)
import Browser.Navigation as Nav
import Route exposing (Route(..))

type alias Model =  
    {
        session : Session
    ,   argument : Maybe String
    ,   mode : Mode
    ,   message : String
    ,   responseTitle : String
    ,   modalVisibility : Bool
    ,   reason : String
    }

init : Session -> Maybe String -> Maybe String-> (Model, Cmd Msg)
init session attrs par= 
    let
        md = 
            {
                session = session
            ,   modalVisibility = False
            ,   responseTitle = ""
            ,   mode = 
                   case attrs of
                       Just str ->
                           case str of 
                               "vemail" ->
                                   EmailVer
                               "vwithdraw" ->
                                   WithdrawVer 
                               "vnewsletter"->
                                   NewsletterVer
                               "dnewsletter" ->
                                   NewsletterD
                               "dnewsletterv" ->
                                   NewsletterDV
                               _ ->
                                   NoContent
                       Nothing ->
                           NoContent
             ,   argument = par
             ,   message = ""
             ,   reason = ""
            }
        _ = Debug.log "attrs" attrs
        _ = Debug.log "pars" par
        
    in
    (md, Cmd.batch [Cmd.none])

type Mode =
    EmailVer
    | WithdrawVer
    | NewsletterVer
    | NewsletterD
    | NewsletterDV
    | NoContent

type Msg = 
  GotSession Session
  | VerificationCompleted (Result (DetailedError String) ( Http.Metadata, String ))
  | Verify
  | ToggleModal Bool


expectJson : (Result (DetailedError String) ( Http.Metadata, a ) -> msg) -> Json.Decode.Decoder a -> Http.Expect msg
expectJson toMsg decoder =
    Http.expectStringResponse toMsg (responseToJson decoder)


responseToJson : Json.Decode.Decoder a -> Http.Response String -> Result (DetailedError String) ( Http.Metadata, a )
responseToJson decoder responseString =
    resolve
        (\( metadata, body ) ->
            Result.mapError Json.Decode.errorToString
                (Json.Decode.decodeString (Json.Decode.map (\res -> ( metadata, res )) decoder) body)
        )
        responseString

verify : Model -> Cmd Msg
verify model =
   case model.argument of
       Just argument ->
          Http.get
          { url = (getBaseUrl ++ "/verify/newsletter/"++argument)
          , expect = expectJson  VerificationCompleted string
          }
       Nothing ->
           Cmd.none


verifyEmail : Model -> Cmd Msg
verifyEmail model =
   case model.argument of
       Just argument ->
          Http.get
          { url = (getBaseUrl ++ "/verify/email/"++argument)
          , expect = expectJson  VerificationCompleted string
          }
       Nothing ->
           Cmd.none


verifyWithdraw : Model -> Cmd Msg
verifyWithdraw model =
   case model.argument of
       Just argument ->
          Http.get
          { url = (getBaseUrl ++ "/verify/withdrawall/"++argument)
          , expect = expectJson  VerificationCompleted string
          }
       Nothing ->
           Cmd.none

verifyDeRegister : Model -> Cmd Msg
verifyDeRegister model =
   case model.argument of
       Just argument ->
          Http.get
          { url = (getBaseUrl ++ "/verify/deregisternews/"++argument)
          , expect = expectJson  VerificationCompleted string
          }
       Nothing ->
           Cmd.none

deRegister : Model -> Cmd Msg
deRegister model =
   case model.argument of
       Just argument ->
          Http.get
          { url = (getBaseUrl ++ "/deregister/newsletter/"++argument)
          , expect = expectJson  VerificationCompleted string
          }
       Nothing ->
           Cmd.none

resolve : (( Http.Metadata, body ) -> Result String a) -> Http.Response body -> Result (DetailedError body) a
resolve toResult response =
    case response of
        Http.BadUrl_ url ->
            Err (BadUrll url)

        Http.Timeout_ ->
            Err Timeoutt

        Http.NetworkError_ ->
            Err NetworkErrorr

        Http.BadStatus_ metadata body ->
            Err (BadStatuss metadata body)

        Http.GoodStatus_ metadata body ->
            Result.mapError (BadBodys metadata body) (toResult ( metadata, body ))


type DetailedError body
    = BadUrll String
    | Timeoutt
    | NetworkErrorr
    | BadStatuss Http.Metadata body
    | BadBodys Http.Metadata body String


view : Model -> {title : String, content: Html Msg}
view model = 
    { title = "Contact Us"
    , content = 
        div[]
        [
           viewSteper model
        ]
     }

viewModal : Model -> Maybe (Html Msg)
viewModal model =
    case model.modalVisibility of 
        True ->
          Just (div[class "container-sm"]
          [
            div[class "row"]
            [ 
              div[class "col", align "center", style "margin-bottom" "20px"]
              [
                span[class "modal_header"][text model.responseTitle]
              ]
            ]
          , div[class "row justify-content-center", style "margin-bottom" "5px"]
            [
                div[class "col-10", align "center"]
                [
                   span[class "modal_body"][text model.message]
                ]
            ]
          , div[class "row justify-content-center", style "margin-bottom" "40px"]
            [
                div[class "col-10", align "center"]
                [
                   span[class "modal_info"][text model.reason]
                ]
            ]

          , div[class "row"]
            [
                div[class "col", align "center"]
                [
                   button [onClick (ToggleModal False), class "greek_button"] [text "OK"]
                ]
            ]
          ])
        False ->
            Nothing

getHeader : Model -> String
getHeader model = 
    case model.mode of
        EmailVer ->
            "Email Verification"
        WithdrawVer ->
            "Withdraw Verification"
        NewsletterVer ->
            "Newsletter Registration verfication"
        NewsletterD ->
            "Unregister yoursefl from our newsletter"
        NewsletterDV ->
            "Verify newsletter deregistration"
        _ ->
            "Other"

viewSteper : Model -> Html Msg
viewSteper model=
       div[class "container-xxl", style "padding-bottom" "5vh", style "margin-top" "5vh", style "margin-left" "10%", style "margin-right" "10%"] 
          [
            div[class "row"]
            [
              div[class "col"]
              [
                 span[style "color" "rgba(0,99,166,1)", style "font-size" "3.5rem", style "font-weight" "bolder", style "text-shadow" "1px 0 rgba(0,99,166,1)"][text (getHeader model)]
              ,  br[][]
              ,  img[Html.Attributes.src "/images/line.svg"][]
              ]
            ]
          , div[class "row"]
              [div[class "col"] [viewContent model]]
          ]


getClass : String
getClass  =
    "panel_button active"


getClassCol:  String
getClassCol =
    "panel_col active"

getLabel : Model -> String
getLabel model = 
    case model.mode of
        NewsletterD ->
            "Email address to be unregistered"
        _ ->
            "Verification Token"

getButton : Model -> String
getButton model = 
    case model.mode of
        NewsletterD ->
            "UN REGISTER"

        WithdrawVer ->
            "Confirm Withdrawall"
        _ ->
            "VERIFY"

getHeaderText : Model -> String
getHeaderText model =
    case model.mode of
        WithdrawVer ->
            "Withdrawall"
        _ ->
            "Email"

viewContent : Model -> Html Msg
viewContent model = 
    div[class "container", style "background-color" "white", style "border-radius" "10px", style "padding-top" "2.5vh", style "padding-bottom" "3vh", style "box-shadow" "8px 8px 16px 8px rgba(0.2,0.2,0.2,0.2)", style "margin-top" "5vh"]
    [
      div[class "row"]
      [
           div[class ("col "++ getClassCol )][a[href "#pageSubmenu", class getClass][span[style "align" "center"][text (getHeaderText model)]]]
      ]
     , div[class "row", style "padding-top" "4vh"]
      [
        div[class "col"]
        [
              div[class "container"]
               [
                      {--
                            div[style "border" "1px solid rgba(239,239,239,1)", style "border-radius" "10px", class "form-row", style "margin-top" "2vh"]
                            [
                               div[class "form-group col", style "margin" "0px"] 
                               [
                                 label[style "padding-left" "0.5rem", style "padding-top" "0.5rem", style "margin-bottom" "0px", style "color" "rgba(112,112,112,1)", style "font-size" "1.25rem", style "font-weight" "bold", style "text-shadow" "1px 0 rgba(112,112,112,1)"][text (getLabel model)]
                               , input[class "form-control", style "padding-top" "0rem", style "width" "100%",style "font-size" "1.5rem", style "color" "rgba(0,99,166,1)" ,style "font-weight" "bold"{--,Html.Attributes.value  model.fromNumberString, onInput ChangeFromNumbHand--}, style "border-style" "none", style "text-shadow" "1px 0 rgba(0,99,166,1)", Html.Attributes.value   ( case model.argument of
                                    Just str ->
                                        str
                                    Nothing ->
                                        ""
                                  )][]
                               ]
                            ]--}
               ]
        ]
       ]
       ,  div[style "pading-bottom" "4vh", style "padding-top" "4vh", style "width" "30%", style "margin" "auto"]
                       [
                         button [ style "width" "100%" , style "margin" "auto", style "padding-left" "2vw", class "btn btn-primary", style "border-radius" "25px", style "font-size" "1.5rem", style "font-weight" "bold", style "background-color" "rgb(0, 99, 166)", style "line-height" "4vh", onClick Verify, attribute "data-toggle" "modal", attribute "data-target" "exampleModal"] [text (getButton model)]
                       ]
   ]

getResponseTitle : Model -> String
getResponseTitle model =
    case model.mode of
        EmailVer ->
            "Successfull Verification"

        WithdrawVer ->
            "Successfull Withdrawal"

        NewsletterVer ->
            "Successfull Registration"

        NewsletterD ->
            "Deregistration"

        NewsletterDV ->
            "Successfull Deregistration"
        _ ->
            "No comment"

getSuccessMessage : Model -> String
getSuccessMessage model =
    case model.mode of

        EmailVer ->
            "Congratulations you have successfully verified your email"

        WithdrawVer ->
            "Your withdrawal request is being processed and sool you will receive your assets"

        NewsletterVer ->
            "Congratulations you have successfully registered to GreekCoin's newsletter list"

        NewsletterD ->
            "You not enlisted anymore to our mail list"

        NewsletterDV ->
            "You have successfully been unsubscribed from the Greek Coin mailing list"
        _ ->
            "No comment"


update : Msg -> Model -> (Model, Cmd Msg)
update msg model = 
    case msg of

        ToggleModal param ->
           (model, Nav.load (Route.routeToString Route.Home)) 

        GotSession session ->
         ( { model | session = session }, Cmd.none
         )

        VerificationCompleted (Ok new_user) ->
            let
                _ = Debug.log "the user ret: " (Debug.toString new_user)
                (meta, message) = new_user
            in
            ({model | message =  getSuccessMessage model, responseTitle = getResponseTitle model, modalVisibility = True}, Cmd.none)

        Verify ->
            let
                _ = Debug.log "verify" "sdafasdf"
                md = { model |
                       message = ""
                     , reason = ""
                     , responseTitle = ""
                     }
            in
            case model.mode of 

               NewsletterVer -> 
                 (md, verify md)

               EmailVer ->
                 (md, verifyEmail md)

               WithdrawVer ->
                 (md, verifyWithdraw md)

               NewsletterD ->
                 (md, deRegister md)

               NewsletterDV ->
                 (md, verifyDeRegister md) 
               
               _ ->
                 (md, Cmd.none)


        VerificationCompleted (Err httpError) ->
            case httpError of
                BadStatuss metadata body ->
                    let
                        result = (Json.Decode.decodeString string  body)
                    in
                    case result of
                        Err error ->
                            let
                               _ = Debug.log "the error" "error"
                               _ = Debug.log (Json.Decode.errorToString error)
                            in
                            ( {model | modalVisibility = True,reason = "Unknown" ,message = "Verification Failure", responseTitle = "Failure"}, Cmd.none)
                        Ok userError ->
                            let
                                _ = Debug.log "the errors: " (Debug.toString userError)
                            in
                            ({model | reason = (Debug.toString userError), message = "Verification Failure" , responseTitle = "Failure", modalVisibility = True}, Cmd.none)

                BadUrll url ->
                    ( model, Cmd.none)

                Timeoutt ->
                    ( model, Cmd.none)

                NetworkErrorr ->
                    ( model, Cmd.none)

                BadBodys a b c ->
                    ( model, Cmd.none)



toSession : Model -> Session
toSession model = 
    model.session


subscriptions : Model -> Sub Msg
subscriptions model =
    Session.changes GotSession (Session.navKey model.session)
