port module Page.Profile.Profile exposing (Model, Msg, init, subscriptions, toSession, update, view, viewModal)

{-| An Author's profile.
-}

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (style, class, type_, href, src, alt) 
import Http
import Route
import Session exposing (Session)
import Username exposing (Username(..) )
import Asset
import Page.Profile.TestPage as TestPage
import Page.Profile.Security as Security
import Page.Profile.Limits as LimitsP
import Page.Profile.Address as AddressP
import Api2.Data exposing (User, Address, decoderUser)
import Http.Legacy
import Task exposing (Task)
import Api.Endpoint as Endpoint
import Api exposing (Cred)
import Api2.Happy exposing (getBaseUrl)
import Json.Decode exposing (string)
import Http.Detailed
import Svg exposing (svg, g, circle) 
import Svg.Attributes exposing (id, version, d, viewBox,x, y, fill, r, cy, cx)

-- MODEL
port renderCaptchaProfile : String -> Cmd msg
port setRecaptchaTokenProfile : (String -> msg) -> Sub msg

type ActionWindow 
    = Profile
    | Security
    | Addresses
    | Limits


type alias Model =
    { session : Session
    , window : ActionWindow
    , testModel : TestPage.Model
    , securityModel : Security.Model
    , addressModel : AddressP.Model
    , limitsModel : LimitsP.Model
    , user :  StatusUser
    , recaptchaToken : Maybe String
    , verification : EmailStatus
    }


type EmailStatus = 
    Initial 
    | Sent
    | Failure
    | CaptchaNeeded


type StatusUser = 
    Loaded User
    | Error String
    | Loading 


viewModal : Model -> Maybe (Html Msg)
viewModal model =
    case model.window of
        Profile ->
            case TestPage.viewModal model.testModel of
               Nothing ->
                  Nothing 
               Just  htmlView ->
                  Just (Html.map (\testMsg -> (TestMessage testMsg)) htmlView)
        Security ->
            case Security.viewModal model.securityModel of
               Nothing ->
                  Nothing 
               Just  htmlView ->
                  Just (Html.map (\testMsg -> (SecurityMessage testMsg)) htmlView)
        _ ->
            Nothing


login :  String  -> Model -> Cmd Msg
login token model= 
   Http.request
    {
     headers = 
            case Session.cred model.session of
                Just cred ->
                    let
                        _ =
                            Debug.log "cred" (Api.credHeader cred)
                    in
                    [ Api.credHeader cred ]

                Nothing ->
                    []

    , method = "GET"
    , url = (getBaseUrl ++ "/api/v1/user/resend/vermail")
    , body =  Http.emptyBody
    , expect = Http.Detailed.expectJson  CompletedLogin string
    , timeout = Nothing
    , tracker = Nothing
    }


init : Session -> ( Model, Cmd Msg )
init session  =
    let
        _ = Debug.log "init" "function" 
        maybeCred =
            Session.cred session
        (testModel, cmnd) = TestPage.init session
        (securityModel, cmndSec) = Security.init session
        (limitsModel, limCmd) = LimitsP.init session
        (addressModel, addrCmd) = AddressP.init session
    in
    ( { session = session
      , testModel = testModel
      , securityModel = securityModel
      , addressModel =  addressModel 
      , limitsModel = limitsModel
      , recaptchaToken = Nothing
      , window = Profile
      , user = Loading
      , verification = Initial
      }
    , Cmd.batch
        [ 
          Cmd.map (\testM -> (TestMessage testM)) cmnd
        , Cmd.map (\secM -> (SecurityMessage secM)) cmndSec
        , Cmd.map (\limM -> (LimitsMessage limM)) limCmd
        , Cmd.map (\addrM -> (AddressMessage addrM)) addrCmd
        , Task.attempt GotUser (fetchUser session)
        ]
    )

fetchUser :  Session -> Task Http.Legacy.Error (User)
fetchUser  session =
    let
        request =
            Api.get Endpoint.user  (Session.cred session) decoderUser
    in
    Http.Legacy.toTask request




tickSign : Html Msg
tickSign = 
  svg [ version "1.1", id "Layer_1", x "0px", y "0px", viewBox "0 0 512 512", Svg.Attributes.style "enable-background:new 0 0 512 512;" ] [ Svg.style [] [ text ".st1{fill:#FFFFFF;} " ], Svg.path [ Svg.Attributes.fill "rgba(214,214,214,1)", d "M502,256c0,135.9-110.1,246-246,246S10,391.9,10,256S120.1,10,256,10S502,120.1,502,256z" ] [], Svg.path [Svg.Attributes.class "st1", d "M341.7,139.8L222.5,259l-52.2-52.2l-56.6,56.6l52.2,52.2l56.6,56.6l175.7-175.7L341.7,139.8z" ] [] ]

tickSignActive : Html Msg
tickSignActive = 
  svg [ version "1.1", id "Layer_1", x "0px", y "0px", viewBox "0 0 512 512", Svg.Attributes.style "enable-background:new 0 0 512 512;" ] [ Svg.style [] [ text ".st1{fill:#FFFFFF;} " ], Svg.path [ Svg.Attributes.fill "rgba(58,213,160,1)", d "M502,256c0,135.9-110.1,246-246,246S10,391.9,10,256S120.1,10,256,10S502,120.1,502,256z" ] [], Svg.path [Svg.Attributes.class "st1", d "M341.7,139.8L222.5,259l-52.2-52.2l-56.6,56.6l52.2,52.2l56.6,56.6l175.7-175.7L341.7,139.8z" ] [] ]


svgOwl : Html Msg
svgOwl = 
    svg [ version "1.1", id "Layer_1", x "0px", y "0px", viewBox "0 0 800 800", Svg.Attributes.style "enable-background:new 0 0 800 800;" ] 
    [ Svg.style [] [ text "" ]
    , g [] [ Svg.path [Svg.Attributes.fill "rgb(214, 214, 214)", Svg.Attributes.class "st0", d "M610.1,275.7c36.9-54,23.1-127.8-31-164.7c-16.8-11.5-36.3-18.5-56.6-20.2l63.5-42.6l-15-22.1L408.5,135.5 L246,26l-14.6,22.1l63.5,42.6c-65.2,5.7-113.5,63.1-107.8,128.3c1.8,20.3,8.7,39.8,20.2,56.6C92.2,387,89.2,570.6,200.5,685.7 s294.9,118.1,410,6.8s118.1-294.9,6.8-410c-2.2-2.3-4.5-4.5-6.8-6.8H610.1z M600.5,208.9c0,16.5-4.7,32.7-13.4,46.7 c-2.6,4.3-5.7,8.4-9,12.2c-3.4,3.9-7.1,7.4-11.2,10.6c-33.6,26.8-81.6,25.4-113.6-3.3l-3.8-3.4c-4.6-4.6-8.7-9.7-12.2-15.2 c-3.1-4.8-5.6-9.8-7.7-15.1c-2.1-5.4-3.7-10.9-4.7-16.5c-0.9-5-1.4-10.1-1.5-15.2l0,0c0-4.9,0.5-9.8,1.3-14.6 c7.6-48.2,52.9-81,101.1-73.4c43.2,6.9,74.9,44.3,74.5,88L600.5,208.9z M411.3,271.4c7.2,11.5,16.3,21.6,26.9,30.1l-1.8,3 l-8.2,14.2l-8.4,14.5l-11.1,19.2l-11.1-19.2l-8.2-14.5l-8.2-14.2l-1.8-3c10.5-8.5,19.5-18.6,26.6-30.1H411.3z M408.5,412.9l42.7-74 c64.1,18.9,108.3,77.6,108.7,144.4l0,0c0,83.5-67.6,151.2-151,151.2c-83.5,0-151.2-67.6-151.2-151c0-0.1,0-0.1,0-0.2l0,0 c0.1-67,44.2-125.9,108.4-144.9L408.5,412.9z M305,120.9c43.2,0.1,79.9,31.3,87.1,73.9c0.8,4.8,1.3,9.7,1.3,14.6l0,0 c-0.1,5.1-0.6,10.2-1.5,15.2c-1.1,5.7-2.7,11.2-4.7,16.5c-2,5.3-4.6,10.3-7.7,15.1c-3.5,5.5-7.6,10.6-12.2,15.2l-3.8,3.4 c-3.8,3.4-7.9,6.4-12.2,9.1c-4.3,2.7-8.8,5-13.5,6.9c-29.4,12.1-63,7.5-88-12.2c-4.1-3.1-7.8-6.7-11.2-10.6 c-3.3-3.8-6.4-7.9-9-12.2c-25.8-41.5-13.1-96,28.4-121.8c14-8.7,30.2-13.3,46.7-13.3L305,120.9z M408.5,744.1 c-143.7-0.2-260-116.8-259.8-260.5c0-0.1,0-0.2,0-0.2l0,0c0-69.9,28.2-136.9,78.2-185.7c21.6,19,49.3,29.4,78,29.4 c4.1,0,8.1-0.3,12.2-0.7c-55.8,32.6-90.1,92.3-90,157l0,0C229.7,583.5,313,662.6,413.2,660c96.5-2.5,174.2-80.1,176.7-176.7l0,0 c-0.2-64.6-34.8-124.2-90.8-156.5c4.3,0.5,8.6,0.7,12.9,0.7c28.7,0,56.4-10.5,78-29.4c50,48.7,78.2,115.4,78.4,185.2l0,0 c0.1,143.6-116.2,260.1-259.8,260.3L408.5,744.1z" ] []
           , Svg.path [Svg.Attributes.fill "rgb(214, 214, 214)", Svg.Attributes.class "st0", d "M282.5,240c5.8,4.2,12.8,6.8,20,7.3h2.6c2.4-0.1,4.9-0.3,7.3-0.7c4.6-1,8.9-2.7,12.9-5.2 c2.5-1.6,4.9-3.5,7.1-5.6c4.9-5.1,8.4-11.5,10-18.5c0.5-2.7,0.8-5.4,0.9-8.2c0-2.5-0.2-5-0.7-7.4c-4.4-20.6-24.7-33.8-45.4-29.4 c-17.4,3.7-29.9,19-30.2,36.8C266.9,221.3,272.7,232.7,282.5,240z" ] []
           , Svg.path [Svg.Attributes.fill "rgb(214, 214, 214)", Svg.Attributes.class "st0", d "M408.5,449.4v-30.2c-38.3,0.3-71.3,26.8-79.8,64.1c-1.3,5.8-1.9,11.8-1.9,17.8c0.1,45.5,37,82.3,82.5,82.3 c33,0,62.8-19.8,75.7-50.1c4.3-10.2,6.4-21.1,6.4-32.1v-14.6H409v30.2h50c0,1.8-1.2,3.5-1.9,5.2c-11.2,26.5-41.9,38.9-68.4,27.7 c-19.3-8.2-31.8-27.1-31.8-48c0-6.1,1.1-12.1,3.2-17.8C367.4,463.4,386.8,449.7,408.5,449.4z" ] []
           , Svg.path [Svg.Attributes.fill "rgb(214, 214, 214)", Svg.Attributes.class "st0", d "M474.7,201.5c-0.5,2.4-0.7,4.9-0.7,7.4c0,2.7,0.3,5.5,0.9,8.2c3.4,14.7,15,26.2,29.8,29.3 c2.5,0.4,4.9,0.7,7.4,0.7h2.6c7.2-0.6,14.1-3.1,20-7.3c9.7-7.2,15.5-18.6,15.7-30.7c-0.3-21.1-17.7-37.9-38.8-37.6 c-17.8,0.3-33.1,12.8-36.8,30.2V201.5z" ] [] ] ]

svgOwlActive : Html Msg
svgOwlActive = 
    svg [ version "1.1", id "Layer_1", x "0px", y "0px", viewBox "0 0 800 800", Svg.Attributes.style "enable-background:new 0 0 800 800;" ] 
    [ Svg.style [] [ text "" ]
    , g [] [ Svg.path [Svg.Attributes.fill "rgba(58,213,160,1)", Svg.Attributes.class "st0", d "M610.1,275.7c36.9-54,23.1-127.8-31-164.7c-16.8-11.5-36.3-18.5-56.6-20.2l63.5-42.6l-15-22.1L408.5,135.5 L246,26l-14.6,22.1l63.5,42.6c-65.2,5.7-113.5,63.1-107.8,128.3c1.8,20.3,8.7,39.8,20.2,56.6C92.2,387,89.2,570.6,200.5,685.7 s294.9,118.1,410,6.8s118.1-294.9,6.8-410c-2.2-2.3-4.5-4.5-6.8-6.8H610.1z M600.5,208.9c0,16.5-4.7,32.7-13.4,46.7 c-2.6,4.3-5.7,8.4-9,12.2c-3.4,3.9-7.1,7.4-11.2,10.6c-33.6,26.8-81.6,25.4-113.6-3.3l-3.8-3.4c-4.6-4.6-8.7-9.7-12.2-15.2 c-3.1-4.8-5.6-9.8-7.7-15.1c-2.1-5.4-3.7-10.9-4.7-16.5c-0.9-5-1.4-10.1-1.5-15.2l0,0c0-4.9,0.5-9.8,1.3-14.6 c7.6-48.2,52.9-81,101.1-73.4c43.2,6.9,74.9,44.3,74.5,88L600.5,208.9z M411.3,271.4c7.2,11.5,16.3,21.6,26.9,30.1l-1.8,3 l-8.2,14.2l-8.4,14.5l-11.1,19.2l-11.1-19.2l-8.2-14.5l-8.2-14.2l-1.8-3c10.5-8.5,19.5-18.6,26.6-30.1H411.3z M408.5,412.9l42.7-74 c64.1,18.9,108.3,77.6,108.7,144.4l0,0c0,83.5-67.6,151.2-151,151.2c-83.5,0-151.2-67.6-151.2-151c0-0.1,0-0.1,0-0.2l0,0 c0.1-67,44.2-125.9,108.4-144.9L408.5,412.9z M305,120.9c43.2,0.1,79.9,31.3,87.1,73.9c0.8,4.8,1.3,9.7,1.3,14.6l0,0 c-0.1,5.1-0.6,10.2-1.5,15.2c-1.1,5.7-2.7,11.2-4.7,16.5c-2,5.3-4.6,10.3-7.7,15.1c-3.5,5.5-7.6,10.6-12.2,15.2l-3.8,3.4 c-3.8,3.4-7.9,6.4-12.2,9.1c-4.3,2.7-8.8,5-13.5,6.9c-29.4,12.1-63,7.5-88-12.2c-4.1-3.1-7.8-6.7-11.2-10.6 c-3.3-3.8-6.4-7.9-9-12.2c-25.8-41.5-13.1-96,28.4-121.8c14-8.7,30.2-13.3,46.7-13.3L305,120.9z M408.5,744.1 c-143.7-0.2-260-116.8-259.8-260.5c0-0.1,0-0.2,0-0.2l0,0c0-69.9,28.2-136.9,78.2-185.7c21.6,19,49.3,29.4,78,29.4 c4.1,0,8.1-0.3,12.2-0.7c-55.8,32.6-90.1,92.3-90,157l0,0C229.7,583.5,313,662.6,413.2,660c96.5-2.5,174.2-80.1,176.7-176.7l0,0 c-0.2-64.6-34.8-124.2-90.8-156.5c4.3,0.5,8.6,0.7,12.9,0.7c28.7,0,56.4-10.5,78-29.4c50,48.7,78.2,115.4,78.4,185.2l0,0 c0.1,143.6-116.2,260.1-259.8,260.3L408.5,744.1z" ] []
           , Svg.path [Svg.Attributes.fill "rgba(58,213,160,1)", Svg.Attributes.class "st0", d "M282.5,240c5.8,4.2,12.8,6.8,20,7.3h2.6c2.4-0.1,4.9-0.3,7.3-0.7c4.6-1,8.9-2.7,12.9-5.2 c2.5-1.6,4.9-3.5,7.1-5.6c4.9-5.1,8.4-11.5,10-18.5c0.5-2.7,0.8-5.4,0.9-8.2c0-2.5-0.2-5-0.7-7.4c-4.4-20.6-24.7-33.8-45.4-29.4 c-17.4,3.7-29.9,19-30.2,36.8C266.9,221.3,272.7,232.7,282.5,240z" ] []
           , Svg.path [Svg.Attributes.fill "rgba(58,213,160,1)", Svg.Attributes.class "st0", d "M408.5,449.4v-30.2c-38.3,0.3-71.3,26.8-79.8,64.1c-1.3,5.8-1.9,11.8-1.9,17.8c0.1,45.5,37,82.3,82.5,82.3 c33,0,62.8-19.8,75.7-50.1c4.3-10.2,6.4-21.1,6.4-32.1v-14.6H409v30.2h50c0,1.8-1.2,3.5-1.9,5.2c-11.2,26.5-41.9,38.9-68.4,27.7 c-19.3-8.2-31.8-27.1-31.8-48c0-6.1,1.1-12.1,3.2-17.8C367.4,463.4,386.8,449.7,408.5,449.4z" ] []
           , Svg.path [Svg.Attributes.fill "rgba(58,213,160,1)", Svg.Attributes.class "st0", d "M474.7,201.5c-0.5,2.4-0.7,4.9-0.7,7.4c0,2.7,0.3,5.5,0.9,8.2c3.4,14.7,15,26.2,29.8,29.3 c2.5,0.4,4.9,0.7,7.4,0.7h2.6c7.2-0.6,14.1-3.1,20-7.3c9.7-7.2,15.5-18.6,15.7-30.7c-0.3-21.1-17.7-37.9-38.8-37.6 c-17.8,0.3-33.1,12.8-36.8,30.2V201.5z" ] [] ] ]


-- VIEW
binanceView : Model -> Html Msg
binanceView model=
    div[class "col"]
    [
      div[class "container-xxl"]
      [
      div[class "row"]
      [
           div[class ("col "++ getClassCol model Profile)][a[href "#pageSubmenu", class (getClass model Profile), type_ "button",onClick (ChangeWindow Profile)][text "Profile"]]
         , div[class ("col "++ getClassCol model Security)][ a[href "#pageSubmenu", class (getClass model Security), type_ "button",onClick (ChangeWindow Security)][text "Security"]]
         , div[class ("col "++ getClassCol model Addresses)][ a[href "#pageSubmenu", class (getClass model Addresses), type_ "button",onClick (ChangeWindow Addresses)][text "Addresses"]]
         , div[class ("col "++ getClassCol model Limits)][ a[href "#pageSubmenu", class (getClass model Limits), type_ "button",onClick (ChangeWindow Limits)][text "Limits"]]
      ]
     , div[class "row", style "padding-top" "4vh", style "padding-bottom" "5vh"]
      [
           case model.window of
               Profile ->
                   Html.map (\testMsg -> (TestMessage testMsg)) (TestPage.view model.testModel)
               Security ->
                   Html.map (\secMsg -> (SecurityMessage secMsg)) (Security.view model.securityModel)    
               Addresses  ->
                   Html.map (\addrM -> (AddressMessage addrM)) (AddressP.view model.addressModel)
               Limits ->
                   Html.map (\limitsM -> (LimitsMessage limitsM)) (LimitsP.view model.limitsModel)
       ]
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


view : Model -> { title : String, content : Html Msg }
view model =
    { title = ""
    , content =
           div[class "container-xxl"]
               (case model.user of
                   Loaded user ->
                       if String.isEmpty user.status || user.status == "created" then
                         (viewNotVerified model)
                       else
                         (viewRegular model)
                   Error sthing ->
                       [div[][]]
                   Loading ->
                       [div[][]]
                   )
    }


viewNotVerified : Model -> List (Html Msg)
viewNotVerified model = 
    [
        case model.verification of 
            CaptchaNeeded ->
               div[class "container-md", style "background-color" "white", style "border-radius" "10px", style "padding-top" "2.5vh",style "margin-top" "6vh", style "padding-bottom" "3vh", style "box-shadow" "8px 8px 16px 8px rgba(0.2,0.2,0.2,0.2)", style "margin-bottom" "200px"]
               [
                  span[class "modal_header center-block"][text "Verification Problem"]
               ,   span[class "modal_message center-block"][text "you failed to verify you email please search your email account and verify your email address to continue"]
               ,   span[class "center-block"][text "Robot test not passed"]

               ,   div [class "",style "margin" "auto",style "width" "50%",id "recaptcha"][]
               ,   button [ type_ "button", style "width" "30%" , style "margin" "auto", class "btn btn-primary primary_button center-block", onClick SendEmail ]
                   [ text "Resend email" ]
               ]

            Initial ->
               div[class "container-md", style "background-color" "white", style "border-radius" "10px", style "padding-top" "2.5vh",style "margin-top" "6vh", style "padding-bottom" "3vh", style "box-shadow" "8px 8px 16px 8px rgba(0.2,0.2,0.2,0.2)", style "margin-bottom" "200px"]
               [
                  span[class "modal_header center-block"][text "Verification Problem"]
               ,   span[class "modal_message center-block"][text "You failed to verify you email please search your email account and verify your email address to continue"]
               ,   div [class "",style "margin" "auto",style "width" "50%",id "recaptcha"][]
               ,   button [ type_ "button", style "width" "30%" , style "margin" "auto", class "btn btn-primary primary_button center-block" , onClick SendEmail]
                   [ text "Resend email" ]
               ]
            Failure ->
               div[class "container-md", style "background-color" "white", style "border-radius" "10px", style "padding-top" "2.5vh",style "margin-top" "6vh", style "padding-bottom" "3vh", style "box-shadow" "8px 8px 16px 8px rgba(0.2,0.2,0.2,0.2)", style "margin-bottom" "200px"]
               [
                  span[class "modal_header center-block"][text "Email failed "]
               ,   span[class "modal_message center-block"][text "If you see more than 3 times the same message please contact system admins"]
               ,   button [ type_ "button", style "width" "30%" , style "margin" "auto", class "btn btn-primary primary_button center-block", onClick Retry ]
                   [ text "Retry" ]
               ]
            Sent ->
               div[class "container-md", style "background-color" "white", style "border-radius" "10px", style "padding-top" "2.5vh",style "margin-top" "6vh", style "padding-bottom" "3vh", style "box-shadow" "8px 8px 16px 8px rgba(0.2,0.2,0.2,0.2)", style "margin-bottom" "200px"]
               [
                  span[class "modal_header center-block"][text "Success"]
               ,   span[class "modal_message center-block"][text "We have just send you a new verification email please search your account"]
               ]


    ]

viewRegular : Model -> List (Html Msg)
viewRegular model = 
            [        div[class "container"]
                       [
                         div[class "row"]
                          [
                             div[class "col text-center"]
                             [
                               div[style "width" "75px", class "mx-auto"]
                               [ (if String.contains "created" model.testModel.user.status then
                                  tickSign
                                 else 
                                   tickSignActive)
                               ]
                               , br[][]
                               , span[style "margin" "auto", style "font-weight" "bold", style "color" (getColorText Created model.testModel.user.status )][text "Update Personal Details"]
                              ]

                         ,  div[class "col text-center"]
                             [
                               div[style "width" "75px", class "mx-auto"]
                               [
                                 (if String.contains "admin_susbended"  model.testModel.user.status || model.testModel.user.clearanceLevel > 0 then
                                   tickSignActive
                                 else
                                   tickSign)
                               ]
                             , br[][]
                             , span[style "margin" "auto", style "font-weight" "bold", style "color" (getColorText Verified model.testModel.user.status )][text "ID Verification"]
                             ]
                         ,  div[class "col text-center"]
                             [
                               div[style "width" "75px", class "mx-auto"]
                               [ 
                                 (if  model.testModel.user.clearanceLevel >0 then
                                    svgOwlActive
                                  else if  model.testModel.user.clearanceLevel < 0 then
                                    img[src "/images/notification.svg"][]
                                  else
                                   svgOwl)

                               ]

                             , br[][]
                             , span[style "margin" "auto", style "font-weight" "bold", style "color" (getColorText Kyc model.testModel.user.status )]
                               [ 
                                 (if String.contains "admin_susbended" model.testModel.user.status then
                                    text "Admin Suspended"
                                 else 
                                    text "Ready"
                                )
                               ]
                             ]                         
                          ]

                      ]
                   
              ,div[class "container-xxl"]
               [
                 div[class "row", style "margin-left" "10%"]
                  [
                    div[class "col",style "margin-top" "50px", style "margin-bottom" "5px"]
                    [
                      span[style "color" "rgba(0,99,166,1)", style "font-size" "3.5rem", style "font-weight" "bolder", style "text-shadow" "1px 0 rgba(0,99,166,1)"][text "MY PROFILE"]
                    , br[][]
                    , img[src "/images/line.svg"][]
                    ]
                  ]
                , div[class "row", style "margin-left" "10%", style "margin-right" "10%"]
                 [
                  binanceView model
                 ]
               ]
           ]


getColorText : UserStatus -> String -> String
getColorText userStatus parameter= 
    case userStatus of
        Kyc ->
            if String.contains "kyc_complient" parameter then
               "rgba(58,213,160,1)"
            else if String.contains  "admin_susbended" parameter then 
                "#dc3545"    
            else
               "rgba(214,214,214,1)"
        Verified ->
            if String.contains "kyc_complient" parameter || String.contains "admin_susbended" parameter then
               "rgba(58,213,160,1)"
            else
               "rgba(214,214,214,1)" 

        Created ->
            if String.contains "created" parameter then
               "rgba(214,214,214,1)"
            else
               "rgba(58,213,160,1)"


type UserStatus =
      Kyc
    | Verified
    | Created


viewSteper : Model -> Html msg
viewSteper model= 
    div[class "" ]
    [
        div [style "margin-left" "10vw"]
        [
          iconProfile
          ,p [style "margin-left" "3vw"][text "Edit Profile"]
        ]
    ]

-- PAGE TITLE

iconProfile : Html msg
iconProfile =
    Html.img
        [ Asset.src Asset.profile
        , style "width" "20vw"
        , style "height"  "18vh"
        , alt "Loading..."
        ]
        []

type Msg
    = 
      GotSession Session
    | ChangeWindow ActionWindow
    | TestMessage TestPage.Msg
    | SecurityMessage Security.Msg
    | LimitsMessage LimitsP.Msg
    | AddressMessage AddressP.Msg
    | GotUser (Result Http.Legacy.Error User)
    | SetRecaptchaToken String
    | CompletedLogin (Result (Http.Detailed.Error String) (Http.Metadata, String))
    | Retry
    | SendEmail

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SendEmail ->
            case model.recaptchaToken of 
                Just token ->
                  (model, login token model)
                Nothing ->
                  ({model | verification = CaptchaNeeded}, renderCaptchaProfile "recaptcha")
        Retry ->
            ({ model | verification = Initial}, renderCaptchaProfile "recaptcha")

        CompletedLogin (Err error) ->
            let
                _ = Debug.log "error:" error
            in
            ({ model | verification = Failure}, Cmd.none)

        CompletedLogin (Ok (metadata, resp)) ->
            ({model | verification = Sent}, Cmd.none)

        GotUser (Ok new_user) ->
            if String.isEmpty new_user.status then
              ({model | user = Loaded new_user}, renderCaptchaProfile "recaptcha")
            else 
              ({model | user = Loaded new_user}, Cmd.none)

        SetRecaptchaToken token ->
            ({model | recaptchaToken = Just token}, Cmd.none)

        GotUser (Err error) ->
            ({model | user = Error "Could not get user from server please contact admin"}, Cmd.none)

        SecurityMessage secMesg ->
            let
                (secModel, cmnd) = Security.update secMesg model.securityModel
            in
            ({ model | securityModel =secModel}, Cmd.map(\secM -> (SecurityMessage secM)) cmnd)

        TestMessage testMessage ->
            let
              (testModel, cmnd) = TestPage.update testMessage model.testModel
            in
            ({model |testModel = testModel}, Cmd.map (\testM -> (TestMessage testM)) cmnd)

        AddressMessage addressMessage ->
            let
              (addressModel, cmnd) = AddressP.update addressMessage model.addressModel
            in
            ({model | addressModel = addressModel}, Cmd.map (\testM -> (AddressMessage testM)) cmnd)

        LimitsMessage limitsMessage ->
            let
              (limitsModel, cmnd) = LimitsP.update limitsMessage model.limitsModel
            in
            ({model |limitsModel = limitsModel}, Cmd.map (\limitsM -> (LimitsMessage limitsM)) cmnd)

        ChangeWindow window ->
            ({model | window = window}, Cmd.none)

        GotSession session ->
            ( { model | session = session }
            , Route.replaceUrl (Session.navKey session) Route.Home
            )

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch 
    [
        Sub.map(\testMsg -> (TestMessage testMsg)) (TestPage.subscriptions model.testModel)
    ,   setRecaptchaTokenProfile SetRecaptchaToken
    ]

-- EXPORT

toSession : Model -> Session
toSession model =
    model.session
